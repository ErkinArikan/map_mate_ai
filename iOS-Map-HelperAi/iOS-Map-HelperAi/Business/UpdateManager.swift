import SwiftUI
import FirebaseRemoteConfig

class UpdateChecker: ObservableObject {
    @Published var isUpdateRequired = false
    @Published var latestVersion: String = ""

    init() {
        checkForUpdate()
    }

    func checkForUpdate() {
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0 // Cache'i sıfırlamak için 0 saniye
        remoteConfig.configSettings = settings

        // Remote Config verisini çek ve aktifleştir
        remoteConfig.fetchAndActivate { status, error in
            if let error = error {
                print("Firebase Remote Config fetch error: \(error.localizedDescription)")
                return
            }
            
            let latestVersion = remoteConfig["force_update_version"].stringValue ?? "0.0"
            let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0"

            print("Firebase’den gelen sürüm: \(latestVersion), Uygulama sürümü: \(currentVersion)")

            DispatchQueue.main.async {
                self.latestVersion = latestVersion
                self.isUpdateRequired = self.compareVersions(currentVersion, latestVersion)
            }
        }
    }


    func compareVersions(_ currentVersion: String, _ latestVersion: String) -> Bool {
        return currentVersion.compare(latestVersion, options: .numeric) == .orderedAscending
    }
}
