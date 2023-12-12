import Foundation
import UIKit
import ComponentsObjC

/// This class facilitates communication between WKSourceEditorViewController and the underlying TextKit (1 and 2) frameworks, so that WKSourceEditorViewController is unaware of which framework is used.
/// When we need to drop TextKit 1, the goal is for all the adjustments to be in this one class

fileprivate var needsTextKit2: Bool {
    if #available(iOS 17, *) {
        return true
    } else {
        return false
    }
}

@objc final class WKSourceEditorSelectionState: NSObject {
    let isBold: Bool
    let isItalics: Bool
    let isHorizontalTemplate: Bool
    let isHeading: Bool
    let isSubheading1: Bool
    let isSubheading2: Bool
    let isSubheading3: Bool
    let isSubheading4: Bool
    
    init(isBold: Bool, isItalics: Bool, isHorizontalTemplate: Bool, isHeading: Bool, isSubheading1: Bool, isSubheading2: Bool, isSubheading3: Bool, isSubheading4: Bool) {
        self.isBold = isBold
        self.isItalics = isItalics
        self.isHorizontalTemplate = isHorizontalTemplate
        self.isHeading = isHeading
        self.isSubheading1 = isSubheading1
        self.isSubheading2 = isSubheading2
        self.isSubheading3 = isSubheading3
        self.isSubheading4 = isSubheading4
        
    }
}

final class WKSourceEditorTextFrameworkMediator: NSObject {
    
    private let viewModel: WKSourceEditorViewModel
    private let textKit1Storage: WKSourceEditorTextStorage?
    private let textKit2Storage: NSTextContentStorage?
    
    let textView: UITextView
    private(set) var formatters: [WKSourceEditorFormatter] = []
    private(set) var boldItalicsFormatter: WKSourceEditorFormatterBoldItalics?
    private(set) var templateFormatter: WKSourceEditorFormatterTemplate?
    private(set) var headingFormatter: WKSourceEditorFormatterHeading?
    
    var isSyntaxHighlightingEnabled: Bool = true {
        didSet {
            updateColorsAndFonts()
        }
    }
    
    
    init(viewModel: WKSourceEditorViewModel) {

        self.viewModel = viewModel
        
        let textView: UITextView
        if needsTextKit2 {
            if #available(iOS 16, *) {
                textView = UITextView(usingTextLayoutManager: true)
                textKit2Storage = textView.textLayoutManager?.textContentManager as? NSTextContentStorage
            } else {
                fatalError("iOS 15 cannot handle TextKit2")
            }
            textKit1Storage = nil
        } else {
            textKit1Storage = WKSourceEditorTextStorage()
            
            let layoutManager = NSLayoutManager()
            let container = NSTextContainer()

            container.widthTracksTextView = true

            layoutManager.addTextContainer(container)
            textKit1Storage?.addLayoutManager(layoutManager)

            textView = UITextView(frame: .zero, textContainer: container)
            textKit2Storage = nil
        }
        
        self.textView = textView
        
        textView.textContainerInset = .init(top: 16, left: 8, bottom: 16, right: 8)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.smartQuotesType = .no
        textView.smartDashesType = .no
        textView.keyboardDismissMode = .interactive
        textView.accessibilityIdentifier = WKSourceEditorAccessibilityIdentifiers.current?.textView
        
        // Note: There is improved selection performance / fixed console constraint errors with these next two lines. Leaving them commented out for now.
        
        // textView.autocorrectionType = .no
        // textView.spellCheckingType = .no
        
        super.init()
        
        if needsTextKit2 {
            textKit2Storage?.delegate = self
        } else {
            textKit1Storage?.storageDelegate = self
        }
    }
    
    // MARK: Internal
    
    func updateColorsAndFonts() {
        
        let colors = self.colors
        let fonts = self.fonts
        
        let boldItalicsFormatter = WKSourceEditorFormatterBoldItalics(colors: colors, fonts: fonts)
        let templateFormatter = WKSourceEditorFormatterTemplate(colors: colors, fonts: fonts)
        let headingFormatter = WKSourceEditorFormatterHeading(colors: colors, fonts: fonts)
        self.formatters = [WKSourceEditorFormatterBase(colors: colors, fonts: fonts, textAlignment: viewModel.textAlignment),
                templateFormatter,
                boldItalicsFormatter,
                headingFormatter]
        self.boldItalicsFormatter = boldItalicsFormatter
        self.templateFormatter = templateFormatter
        self.headingFormatter = headingFormatter
        
        if needsTextKit2 {
            if #available(iOS 16.0, *) {
                let textContentManager = textView.textLayoutManager?.textContentManager
                textContentManager?.performEditingTransaction({
                    
                    guard let attributedString = (textContentManager as? NSTextContentStorage)?.textStorage else {
                        return
                    }
                    
                    let colors = self.colors
                    let fonts = self.fonts
                    let range = NSRange(location: 0, length: attributedString.length)
                    for formatter in formatters {
                        formatter.update(colors, in: attributedString, in: range)
                        formatter.update(fonts, in: attributedString, in: range)
                    }
                })
            }
        } else {
            textKit1Storage?.updateColorsAndFonts()
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(debouncedEnsureLayoutTextkit1), object: nil)
            perform(#selector(debouncedEnsureLayoutTextkit1), with: nil, afterDelay: 0.1)
        }
    }
    
    @objc private func debouncedEnsureLayoutTextkit1() {
        
        guard !needsTextKit2 else {
            return
        }
        
       textView.layoutManager.ensureLayout(forCharacterRange: NSRange(location: 0, length: textView.attributedText.length))
    }
    
    func selectionState(selectedDocumentRange: NSRange) -> WKSourceEditorSelectionState {
        
        if needsTextKit2 {
            guard let textKit2Data = textkit2SelectionData(selectedDocumentRange: selectedDocumentRange) else {
                return WKSourceEditorSelectionState(isBold: false, isItalics: false, isHorizontalTemplate: false, isHeading: false, isSubheading1: false, isSubheading2: false, isSubheading3: false, isSubheading4: false)
            }
            
            let isBold = boldItalicsFormatter?.attributedString(textKit2Data.paragraphAttributedString, isBoldIn: textKit2Data.paragraphSelectedRange) ?? false
            let isItalics = boldItalicsFormatter?.attributedString(textKit2Data.paragraphAttributedString, isItalicsIn: textKit2Data.paragraphSelectedRange) ?? false
            let isHorizontalTemplate = templateFormatter?.attributedString(textKit2Data.paragraphAttributedString, isHorizontalTemplateIn: textKit2Data.paragraphSelectedRange) ?? false
            let isHeading = headingFormatter?.attributedString(textKit2Data.paragraphAttributedString, isHeadingIn: textKit2Data.paragraphSelectedRange) ?? false
            let isSubheading1 = headingFormatter?.attributedString(textKit2Data.paragraphAttributedString, isSubheading1In: textKit2Data.paragraphSelectedRange) ?? false
            let isSubheading2 = headingFormatter?.attributedString(textKit2Data.paragraphAttributedString, isSubheading2In: textKit2Data.paragraphSelectedRange) ?? false
            let isSubheading3 = headingFormatter?.attributedString(textKit2Data.paragraphAttributedString, isSubheading3In: textKit2Data.paragraphSelectedRange) ?? false
            let isSubheading4 = headingFormatter?.attributedString(textKit2Data.paragraphAttributedString, isSubheading4In: textKit2Data.paragraphSelectedRange) ?? false
            
            return WKSourceEditorSelectionState(isBold: isBold, isItalics: isItalics, isHorizontalTemplate: isHorizontalTemplate, isHeading: isHeading, isSubheading1: isSubheading1, isSubheading2: isSubheading2, isSubheading3: isSubheading3, isSubheading4: isSubheading4)
        } else {
            guard let textKit1Storage else {
                return WKSourceEditorSelectionState(isBold: false, isItalics: false, isHorizontalTemplate: false, isHeading: false, isSubheading1: false, isSubheading2: false, isSubheading3: false, isSubheading4: false)
            }
                        
            let isBold = boldItalicsFormatter?.attributedString(textKit1Storage, isBoldIn: selectedDocumentRange) ?? false
            let isItalics = boldItalicsFormatter?.attributedString(textKit1Storage, isItalicsIn: selectedDocumentRange) ?? false
            let isHorizontalTemplate = templateFormatter?.attributedString(textKit1Storage, isHorizontalTemplateIn: selectedDocumentRange) ?? false
            let isHeading = headingFormatter?.attributedString(textKit1Storage, isHeadingIn: selectedDocumentRange) ?? false
            let isSubheading1 = headingFormatter?.attributedString(textKit1Storage, isSubheading1In: selectedDocumentRange) ?? false
            let isSubheading2 = headingFormatter?.attributedString(textKit1Storage, isSubheading2In: selectedDocumentRange) ?? false
            let isSubheading3 = headingFormatter?.attributedString(textKit1Storage, isSubheading3In: selectedDocumentRange) ?? false
            let isSubheading4 = headingFormatter?.attributedString(textKit1Storage, isSubheading4In: selectedDocumentRange) ?? false
            
            return WKSourceEditorSelectionState(isBold: isBold, isItalics: isItalics, isHorizontalTemplate: isHorizontalTemplate, isHeading: isHeading, isSubheading1: isSubheading1, isSubheading2: isSubheading2, isSubheading3: isSubheading3, isSubheading4: isSubheading4)
        }
    }
    
    func textkit2SelectionData(selectedDocumentRange: NSRange) -> (paragraphAttributedString: NSMutableAttributedString, paragraphSelectedRange: NSRange)? {
        guard needsTextKit2 else {
            return nil
        }
        
        // Pulling the paragraph element that contains the selection will have an attributed string with the populated attributes
        if #available(iOS 16.0, *) {
            guard let textKit2Storage,
                  let layoutManager = textView.textLayoutManager,
                  let selectedDocumentTextRange = textKit2Storage.textRangeForDocumentNSRange(selectedDocumentRange),
                  let paragraphElement = layoutManager.textLayoutFragment(for: selectedDocumentTextRange.location)?.textElement as? NSTextParagraph,
                  let paragraphRange = paragraphElement.elementRange else {
                return nil
            }
            
            guard let selectedParagraphRange = textKit2Storage.offsetDocumentNSRangeWithParagraphRange(documentNSRange: selectedDocumentRange, paragraphRange: paragraphRange) else {
                return nil
            }
            
            return (NSMutableAttributedString(attributedString: paragraphElement.attributedString), selectedParagraphRange)
        }
        
        return nil
    }
}

extension WKSourceEditorTextFrameworkMediator: WKSourceEditorStorageDelegate {
    
    var colors: WKSourceEditorColors {
        let colors = WKSourceEditorColors()
        colors.baseForegroundColor = WKAppEnvironment.current.theme.text
        colors.orangeForegroundColor = isSyntaxHighlightingEnabled ? WKAppEnvironment.current.theme.editorOrange : WKAppEnvironment.current.theme.text
        colors.purpleForegroundColor = isSyntaxHighlightingEnabled ?  WKAppEnvironment.current.theme.editorPurple : WKAppEnvironment.current.theme.text
        return colors
    }
    
    var fonts: WKSourceEditorFonts {
        let fonts = WKSourceEditorFonts()
        let traitCollection = UITraitCollection(preferredContentSizeCategory: WKAppEnvironment.current.articleAndEditorTextSize)
        let baseFont = WKFont.for(.body, compatibleWith: traitCollection)
        fonts.baseFont = baseFont
        
        fonts.boldFont = isSyntaxHighlightingEnabled ? WKFont.for(.boldBody, compatibleWith: traitCollection) : baseFont
        fonts.italicsFont = isSyntaxHighlightingEnabled ? WKFont.for(.italicsBody, compatibleWith: traitCollection) : baseFont
        fonts.boldItalicsFont = isSyntaxHighlightingEnabled ? WKFont.for(.boldItalicsBody, compatibleWith: traitCollection) : baseFont
        fonts.headingFont = isSyntaxHighlightingEnabled ? WKFont.for(.editorHeading, compatibleWith: traitCollection) : baseFont
        fonts.subheading1Font = isSyntaxHighlightingEnabled ? WKFont.for(.editorSubheading1, compatibleWith: traitCollection) : baseFont
        fonts.subheading2Font = isSyntaxHighlightingEnabled ? WKFont.for(.editorSubheading2, compatibleWith: traitCollection) : baseFont
        fonts.subheading3Font = isSyntaxHighlightingEnabled ? WKFont.for(.editorSubheading3, compatibleWith: traitCollection) : baseFont
        fonts.subheading4Font = isSyntaxHighlightingEnabled ? WKFont.for(.editorSubheading4, compatibleWith: traitCollection) : baseFont
        return fonts
    }
}

 extension WKSourceEditorTextFrameworkMediator: NSTextContentStorageDelegate {

    func textContentStorage(_ textContentStorage: NSTextContentStorage, textParagraphWith range: NSRange) -> NSTextParagraph? {
        
        guard needsTextKit2 else {
            return nil
        }
        
        guard let originalText = textContentStorage.textStorage?.attributedSubstring(from: range),
              originalText.length > 0 else {
            return nil
        }
        let attributedString = NSMutableAttributedString(attributedString: originalText)
        let paragraphRange = NSRange(location: 0, length: originalText.length)
        
        for formatter in formatters {
            formatter.addSyntaxHighlighting(to: attributedString, in: paragraphRange)
        }
        
        return NSTextParagraph(attributedString: attributedString)
    }
}

fileprivate extension NSTextContentStorage {
    func textRangeForDocumentNSRange(_ documentNSRange: NSRange) -> NSTextRange? {
        guard let start = location(documentRange.location, offsetBy: documentNSRange.location),
                let end = location(start, offsetBy: documentNSRange.length) else {
            return nil
        }
        
        return NSTextRange(location: start, end: end)
    }
    
    func offsetDocumentNSRangeWithParagraphRange(documentNSRange: NSRange, paragraphRange: NSTextRange) -> NSRange? {
        let startOffset = offset(from: documentRange.location, to: paragraphRange.location)
        let newNSRange = NSRange(location: documentNSRange.location - startOffset, length: documentNSRange.length)
        
        guard newNSRange.location >= 0 else {
            return nil
        }
        
        return newNSRange
    }
}
