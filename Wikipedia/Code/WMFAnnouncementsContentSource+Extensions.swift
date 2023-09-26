import Foundation
import WKData

extension WMFAnnouncementsContentSource {
    @objc func fetchDonateConfigsForCountryCode(_ countryCode: String) {
        
        guard FeatureFlags.fundraisingImprovementsEnabled else {
            return
        }
        
        let dataController = WKDonateDataController()
        dataController.fetchConfigs(for: countryCode) { result in
            print(WKDonateDataController.donateConfig)
            print(WKDonateDataController.paymentMethods)
        }
    }
}
