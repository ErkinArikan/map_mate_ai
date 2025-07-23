//
//  iOS_Map_HelperAiApp.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 20.09.2024.
//

import SwiftUI
import SwiftData
import FirebaseCore
import GoogleSignIn


#warning("Rota başlatma görüntüsünü güzelleştir.")
#warning("Her kullanıcının favorileri olsun eklemeler yaptıkça yapay zeka da bunu bilsin zaten her kullanıcının favoriler boşluğu mecvut Fb'de")



#warning("Map Style kaldırıldı onu haritanın üstüne ekle oradan açabilsin kullanıcı :)")
#warning("Chat içinde yardımcı kelimeler ekleyebiliriz horizontal bir şekilde akan.")
#warning("Chat içine en alta gidebilen buton ve bir info butonu koyup kullanıcının nasıl kullanabileceğini anlat.")






@main
struct iOS_Map_HelperAiApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // MARK: - View Models
    @StateObject var mapViewModel = MapViewModel(locationManager: LocationManagerDummy())
    @StateObject var locationManagerDummy = LocationManagerDummy()
    @StateObject var routeViewModel = RouteViewModel( locationManager: LocationManagerDummy())
    @StateObject var searchViewModel = SearchViewModel()
    @StateObject var sideMenuViewModel = SideMenuViewModel()
    @StateObject var uiStateVm = UIStateViewModel()
    @StateObject private var mapMateVm = MapMateViewModel(api: ChatGPTAPI(apiKey: Constants.API_KEY, locationManager: LocationManagerDummy()))
    @ObservedObject var languageManager = LanguageManager()
    @StateObject var loginViewModel = LoginViewModel()
    @StateObject var settingsVm = SettingsViewModel()
    @StateObject var authService =  AuthService()
    
   
    @AppStorage("isOnTutorial") var isOnTutorial:Bool = true
    @AppStorage("isUserAgreementAccepted") var isUserAgreementAccepted:Bool = false
    // MARK: - User Preferences
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("log_status") private var logStatus:Bool = false
    @StateObject var updateChecker = UpdateChecker()
    @StateObject var favoritesVm = FavoritesViewModel()
    var body: some Scene {
        WindowGroup {
//            SplashScreenView()
            LandingPage().onOpenURL { url in
                //Handle Google Oauth URL
                GIDSignIn.sharedInstance.handle(url)
            }
                // MARK: - Environment Objects
            .environmentObject(authService)
                .environmentObject(mapViewModel)
                .environmentObject(locationManagerDummy)
                .environmentObject(routeViewModel)
                .environmentObject(searchViewModel)
                .environmentObject(sideMenuViewModel)
                .environmentObject(uiStateVm)
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .environmentObject(mapMateVm)
                .environmentObject(LanguageManager())
                .environmentObject(loginViewModel)
                .environmentObject(settingsVm)
                .environmentObject(updateChecker)
                .environmentObject(favoritesVm)
        }
        // MARK: - Model Container
        .modelContainer(for: [LastSearchedPlaces.self,StarredPlacesDB.self])
      
        
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
    let gcmMessageIDKey = "gcm.message_id"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()

      

        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
         

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        return true
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }

      print(userInfo)

      completionHandler(UIBackgroundFetchResult.newData)
    }
}
