//
//  DistrubutionMap.swift
//  AI-HelperMap
//
//  Created by Erkin Arikan on 5.09.2024.
//

import SwiftUI


struct FinalMapView: View {
    //    @EnvironmentObject var searchViewModel:SearchViewModel
    //    @EnvironmentObject var directionsViewModel:DirectionViewModel
    //
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var vm:MapViewModel
    @EnvironmentObject var locationManager:LocationManagerDummy
    @EnvironmentObject var searchVm:SearchViewModel
    @EnvironmentObject var loginVm:LoginViewModel
    @Environment(\.modelContext) var context
    @EnvironmentObject var sideMenuVm:SideMenuViewModel
    @EnvironmentObject var uiStateVm:UIStateViewModel
    @EnvironmentObject var mapMateVm: MapMateViewModel
    @EnvironmentObject var routeVm:RouteViewModel
    @EnvironmentObject var settingsVm:SettingsViewModel
    @EnvironmentObject var favoritesVm:FavoritesViewModel
    @AppStorage("log_status") private var logStatus:Bool = false
    var body: some View {
        
        ZStack{
            
            MainMapView()
            
            VStack{
                Spacer()
                
                if uiStateVm.activeSheet != .search && uiStateVm.activeSheet != .direction && uiStateVm.activeSheet != .details && uiStateVm.activeSheet != .startedNavigation{
                    TabBarView1(isShow: $uiStateVm.isSearchViewShow)
                        .padding()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeInOut, value: uiStateVm.isSearchViewShow)
                        .opacity(sideMenuVm.sideMenuShow ? 0:1)
                        .disabled(sideMenuVm.sideMenuShow ? true:false)
                }
                else{
                    TabBarView1(isShow: $uiStateVm.isSearchViewShow)
                        .padding()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeInOut, value: uiStateVm.isSearchViewShow)
                        .hidden()
                        .opacity(sideMenuVm.sideMenuShow ? 0:1)
                        .disabled(sideMenuVm.sideMenuShow ? true:false)
                }
                
                
                
            }
            
            if sideMenuVm.sideMenuShow {
                SideMenuView(isShowing: $sideMenuVm.sideMenuShow, searchResults: $searchVm.searchResults)
                
            }
            
            
            
            if settingsVm.isShow{
                SettingsDummy(isShowing: $settingsVm.isShow)
                    .transition(.move(edge: .bottom))
            }
            
            
            
        }
        .onAppear {
            print("log statu: \(logStatus)")
            mapMateVm.checkPormptLimit()
            
            Task{
                await authService.fetchUser()
                await loginVm.fetchUser()
                await mapMateVm.fetchUser()
                
                
                await  mapMateVm.fetchMessagesForCurrentUser()
                
            }
            loginVm.updateLogInStyle()
            favoritesVm.fetchUserFavorites()
        }
        
    }
}

#Preview {
    FinalMapView()
        .environmentObject(LocationManagerDummy())
        .environmentObject(MapViewModel(locationManager: LocationManagerDummy()))
        .environmentObject(RouteViewModel( locationManager: LocationManagerDummy()))
        .environmentObject(SearchViewModel())
        .environmentObject(SideMenuViewModel())
        .environmentObject(UIStateViewModel())
        .environmentObject(MapMateViewModel(api: ChatGPTAPI(apiKey: Constants.API_KEY, locationManager: LocationManagerDummy())))
        .environmentObject(LanguageManager())
        .environmentObject(UIStateViewModel())
        .environmentObject(LoginViewModel())
    //        .environmentObject(MapStyleConfig())
        .environmentObject(SettingsViewModel())
    
}
