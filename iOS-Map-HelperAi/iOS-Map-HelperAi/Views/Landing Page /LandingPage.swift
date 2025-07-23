//
//  LandingPage.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 4.12.2024.
//

import SwiftUI
import FirebaseAuth

struct LandingPage: View {
   
    
    @EnvironmentObject var loginVm:LoginViewModel
    @AppStorage("isOnTutorial") var isOnTutorial:Bool = true
    @AppStorage("log_status") private var logStatus:Bool = false
    @State var isActive:Bool = false
    
    @State private var userLoggedIn = (Auth.auth().currentUser != nil)
    
    var body: some View {
        VStack{
            if isActive{
                if logStatus && Auth.auth().currentUser?.isEmailVerified == true{
                    FinalMapView()
                } else {
                    if isOnTutorial {
                        IllusturationListView()
                    } else {
                        WelcomeView()
                    }
                }
            }else{
                SplashScreenView(isActive: $isActive)
                    
            }
        }

        
    }
}

#Preview {
    LandingPage()
        .environmentObject(LocationManagerDummy())
        .environmentObject(MapViewModel(locationManager: LocationManagerDummy()))
        .environmentObject(RouteViewModel( locationManager: LocationManagerDummy()))
        .environmentObject(SearchViewModel())
        .environmentObject(SideMenuViewModel())
        .environmentObject(UIStateViewModel())
        .environmentObject(MapMateViewModel(api: ChatGPTAPI(apiKey: Constants.API_KEY, locationManager: LocationManagerDummy())))
        .environmentObject(LanguageManager())
        .environmentObject(LanguageManager())
        .environmentObject(LoginViewModel())
}
