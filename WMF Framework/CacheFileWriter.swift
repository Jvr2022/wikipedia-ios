
import Foundation

enum CacheFileWriterError: Error {
    case missingTemporaryFileURL
    case missingHeaderItemKey
    case missingHTTPResponse
    case unableToDetermineSiteURLFromMigration
    case unexpectedFetcherTypeForBundledMigration
    case unableToDetermineBundledOfflineURLS
    case failureToSaveBundledFiles
}

enum CacheFileWriterResult {
    case success
    case failure(Error)
}

final class CacheFileWriter: CacheTaskTracking {

    private let fetcher: CacheFetching
    private let cacheKeyGenerator: CacheKeyGenerating.Type
    private let cacheBackgroundContext: NSManagedObjectContext
    
    lazy private var baseCSSFileURL: URL = {
        URL(fileURLWithPath: WikipediaAppUtils.assetsPath())
            .appendingPathComponent("pcs-html-converter", isDirectory: true)
            .appendingPathComponent("baseCSS.css", isDirectory: false)
    }()

    lazy private var pcsCSSFileURL: URL = {
        URL(fileURLWithPath: WikipediaAppUtils.assetsPath())
            .appendingPathComponent("pcs-html-converter", isDirectory: true)
            .appendingPathComponent("pcsCSS.css", isDirectory: false)
    }()

    lazy private var pcsJSFileURL: URL = {
        URL(fileURLWithPath: WikipediaAppUtils.assetsPath())
            .appendingPathComponent("pcs-html-converter", isDirectory: true)
            .appendingPathComponent("pcsJS.js", isDirectory: false)
    }()

    lazy private var siteCSSFileURL: URL = {
        URL(fileURLWithPath: WikipediaAppUtils.assetsPath())
            .appendingPathComponent("pcs-html-converter", isDirectory: true)
            .appendingPathComponent("siteCSS.css", isDirectory: false)
    }()
    
    var groupedTasks: [String : [IdentifiedTask]] = [:]
    
    init?(fetcher: CacheFetching,
                       cacheBackgroundContext: NSManagedObjectContext,
                       cacheKeyGenerator: CacheKeyGenerating.Type) {
        self.fetcher = fetcher
        self.cacheBackgroundContext = cacheBackgroundContext
        self.cacheKeyGenerator = cacheKeyGenerator
        
        do {
            try FileManager.default.createDirectory(at: CacheController.cacheURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            assertionFailure("Failure to create article cache directory")
            return nil
        }
    }
    
    func add(groupKey: String, urlRequest: URLRequest, completion: @escaping (CacheFileWriterResult) -> Void) {
        
        guard let url = urlRequest.url,
            let itemKey = urlRequest.allHTTPHeaderFields?[Session.Header.persistentCacheItemKey] else {
            completion(.failure(CacheFileWriterError.missingHeaderItemKey))
            return
        }
        
        let variant = urlRequest.allHTTPHeaderFields?[Session.Header.persistentCacheItemVariant]
        let fileName = cacheKeyGenerator.uniqueFileNameForItemKey(itemKey, variant: variant)
        let headerFileName = cacheKeyGenerator.uniqueHeaderFileNameForItemKey(itemKey, variant: variant)
        
        let untrackKey = UUID().uuidString
        let task = fetcher.downloadData(urlRequest: urlRequest) { (error, _, response, temporaryFileURL, mimeType) in
            
            defer {
                self.untrackTask(untrackKey: untrackKey, from: groupKey)
            }
            
            if let error = error {
                switch error as? RequestError {
                case .notModified:
                    completion(.success)
                default:
                    DDLogError("Error downloading data for offline: \(error)\n\(String(describing: response))")
                    completion(.failure(error))
                }
                return
            }
            
            guard let responseHeader = response as? HTTPURLResponse else {
                completion(.failure(CacheFileWriterError.missingHTTPResponse))
                return
            }
            
            let dispatchGroup = DispatchGroup()
            
            dispatchGroup.enter()
            var responseHeaderSaveError: Error? = nil
            var responseSaveError: Error? = nil
            
            CacheFileWriterHelper.saveResponseHeader(urlResponse: responseHeader, toNewFileName: headerFileName) { (result) in
                
                defer {
                    dispatchGroup.leave()
                }
                
                switch result {
                case .success, .exists:
                    break
                case .failure(let error):
                    responseHeaderSaveError = error
                }
            }
            
            if let temporaryFileURL = temporaryFileURL {
                //file needs to be moved
                dispatchGroup.enter()
                CacheFileWriterHelper.moveFile(from: temporaryFileURL, toNewFileWithKey: fileName, mimeType: mimeType) { (result) in
                    
                    defer {
                        dispatchGroup.leave()
                    }
                    
                    switch result {
                    case .success, .exists:
                        break
                    case .failure(let error):
                        responseSaveError = error
                    }
                }
            }
            
            dispatchGroup.notify(queue: DispatchQueue.global(qos: .default)) { [responseHeaderSaveError, responseSaveError] in
                
                if let responseSaveError = responseSaveError {
                    self.remove(fileName: fileName) { (_) in
                        completion(.failure(responseSaveError))
                    }
                    return
                }
                
                if let responseHeaderSaveError = responseHeaderSaveError {
                    self.remove(fileName: fileName) { (_) in
                        completion(.failure(responseHeaderSaveError))
                    }
                    return
                }
                
                completion(.success)
            }
        }
        
        if let task = task {
            trackTask(untrackKey: untrackKey, task: task, to: groupKey)
        }
    }
    
    func remove(fileName: String, completion: @escaping (CacheFileWriterResult) -> Void) {
        
        var responseHeaderRemoveError: Error? = nil
        var responseRemoveError: Error? = nil

        //remove response from file system
        let responseCachedFileURL = CacheFileWriterHelper.fileURL(for: fileName)
        do {
            try FileManager.default.removeItem(at: responseCachedFileURL)
        } catch let error as NSError {
            if !(error.code == NSURLErrorFileDoesNotExist || error.code == NSFileNoSuchFileError) {
               responseRemoveError = error
            }
        }
        
        //remove response header from file system
        let responseHeaderCachedFileURL = CacheFileWriterHelper.fileURL(for: fileName)
        do {
            try FileManager.default.removeItem(at: responseHeaderCachedFileURL)
        } catch let error as NSError {
            if !(error.code == NSURLErrorFileDoesNotExist || error.code == NSFileNoSuchFileError) {
               responseHeaderRemoveError = error
            }
        }
        
        if let responseHeaderRemoveError = responseHeaderRemoveError {
            completion(.failure(responseHeaderRemoveError))
            return
        }
        
        if let responseRemoveError = responseRemoveError {
            completion(.failure(responseRemoveError))
            return
        }
        
        completion(.success)
    }
}

//MARK: Migration

extension CacheFileWriter {
    
    func addMobileHtmlContentForMigration(content: String, urlRequest: URLRequest, mimeType: String, success: @escaping () -> Void, failure: @escaping (Error) -> Void) {
        
        guard let itemKey =  urlRequest.allHTTPHeaderFields?[Session.Header.persistentCacheItemKey] else {
                failure(CacheFileWriterError.missingHeaderItemKey)
                return
        }
        
        let variant = urlRequest.allHTTPHeaderFields?[Session.Header.persistentCacheItemVariant]
        let fileName = cacheKeyGenerator.uniqueFileNameForItemKey(itemKey, variant: variant)

        CacheFileWriterHelper.saveContent(content, toNewFileName: fileName, mimeType: mimeType) { (result) in
            switch result {
            case .success, .exists:
                success()
            case .failure(let error):
                failure(error)
            }
        }
    }
    
    func addBundledResourcesForMigration(desktopArticleURL: URL, urlRequests:[URLRequest], success: @escaping ([URLRequest]) -> Void, failure: @escaping (Error) -> Void) {
        guard let siteURL = desktopArticleURL.wmf_site else {
            failure(CacheFileWriterError.unableToDetermineSiteURLFromMigration)
            return
        }
        
        guard let articleFetcher = fetcher as? ArticleFetcher else {
            failure(CacheFileWriterError.unexpectedFetcherTypeForBundledMigration)
            return
        }
        
        guard let bundledOfflineResources = articleFetcher.bundledOfflineResourceURLs(with: siteURL) else {
            failure(CacheFileWriterError.unableToDetermineBundledOfflineURLS)
            return
        }
        
        var failedURLRequests: [URLRequest] = []
        var succeededURLRequests: [URLRequest] = []
        
        for urlRequest in urlRequests {
            
            guard let itemKey = urlRequest.allHTTPHeaderFields?[Session.Header.persistentCacheItemKey] else {
                continue
            }
            
            let fileName = cacheKeyGenerator.uniqueFileNameForItemKey(itemKey, variant: nil)
            
            switch itemKey {
            case bundledOfflineResources.baseCSS.absoluteString:
                CacheFileWriterHelper.copyFile(from: baseCSSFileURL, toNewFileWithKey: fileName, mimeType: "text/css") { (result) in
                    switch result {
                    case .success, .exists:
                        succeededURLRequests.append(urlRequest)
                    case .failure:
                        failedURLRequests.append(urlRequest)
                    }
                }
            case bundledOfflineResources.siteCSS.absoluteString:
                CacheFileWriterHelper.copyFile(from: siteCSSFileURL, toNewFileWithKey: fileName, mimeType: "text/css") { (result) in
                    switch result {
                    case .success, .exists:
                        succeededURLRequests.append(urlRequest)
                    case .failure:
                        failedURLRequests.append(urlRequest)
                    }
                }
            case bundledOfflineResources.pcsCSS.absoluteString:
                CacheFileWriterHelper.copyFile(from: pcsCSSFileURL, toNewFileWithKey: fileName, mimeType: "text/css") { (result) in
                    switch result {
                    case .success, .exists:
                        succeededURLRequests.append(urlRequest)
                    case .failure:
                        failedURLRequests.append(urlRequest)
                    }
                }
            case bundledOfflineResources.pcsJS.absoluteString:
            CacheFileWriterHelper.copyFile(from: pcsJSFileURL, toNewFileWithKey: fileName, mimeType: "application/javascript") { (result) in
                switch result {
                case .success, .exists:
                    succeededURLRequests.append(urlRequest)
                case .failure:
                    failedURLRequests.append(urlRequest)
                }
            }
            default:
                failedURLRequests.append(urlRequest)
            }
        }
        
        if succeededURLRequests.count == 0 {
            failure(CacheFileWriterError.failureToSaveBundledFiles)
            return
        }

        success(succeededURLRequests)
    }
}
