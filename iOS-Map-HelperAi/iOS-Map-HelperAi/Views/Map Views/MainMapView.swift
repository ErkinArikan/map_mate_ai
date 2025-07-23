//
//  MainMapView.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 20.09.2024.
//

import SwiftUI
import MapKit

//MARK: - TASKS

struct MainMapView: View {
    //MARK: - VARIABLES
    @EnvironmentObject var languageManager:LanguageManager
    @AppStorage("isDarkMode") private var isDarkMode = false
    @EnvironmentObject var locationManager:LocationManagerDummy
    @EnvironmentObject var vm:MapViewModel
    @EnvironmentObject var routeVm:RouteViewModel
    @EnvironmentObject var loginVm:LoginViewModel
    @EnvironmentObject var sideMenuVm:SideMenuViewModel
    @EnvironmentObject var uiStateVm:UIStateViewModel
    @EnvironmentObject var searchVm:SearchViewModel
    @EnvironmentObject var settingsVm:SettingsViewModel
    @StateObject private var mapMateVm = MapMateViewModel(api: ChatGPTAPI(apiKey: Constants.API_KEY, locationManager: LocationManagerDummy())) // ViewModel üst düzeyde tanımlandı
    // Toast görünümü için state
        @State private var showToast: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var favoritesVm:FavoritesViewModel
    //MARK: - BODY
    var body: some View {
        ZStack{
            MapView()
                .sheet(item: $uiStateVm.activeSheet){ activePage in
                    switch activePage {
                    case .search:
                        //MARK: - SEARCH VIEW CASE
                        SearchView()
                            .presentationDetents([.height(60),.height(310),.height(500)],selection:$uiStateVm.selectedDetent)
                            .presentationBackgroundInteraction(.enabled(upThrough: .height(500)))
                            .presentationDragIndicator(.visible)
                            .interactiveDismissDisabled(true)
                            .presentationCornerRadius(20)
                  
                        
                    case .details:
                       
                        //MARK: - DETAILS CASE
                        DestinationDetailsView(show: $uiStateVm.showDetails,
                                               getDirections: $uiStateVm.getDirections
                        )
                            .presentationDetents([.height(60),.height(300)],selection:$uiStateVm.selectedDetent)
                            .presentationBackgroundInteraction(.enabled(upThrough: .height(300)))
                            .presentationDragIndicator(.visible)
                            .interactiveDismissDisabled(true)
                            .presentationCornerRadius(20)
                      
                            
                            
                            
                        
                    case .direction:
                        //MARK: -DIRECTION CASE
                            DirectionsViewDummy()
                            .presentationDetents([.height(100),.height(400)],selection:$uiStateVm.selectedDetent)
                                .presentationBackgroundInteraction(.enabled(upThrough: .height(400)))
                                .presentationDragIndicator(.visible)
                                .interactiveDismissDisabled(true)
                                .presentationCornerRadius(20)
                              
                               
                        
                                
                        
                    case .favorites:
                        //MARK: - FAVORITES CASE
                        FavoritesView(searchResultsFav: $searchVm.searchResultsFav, showDetails: $uiStateVm.showDetails, getDirections: $uiStateVm.getDirections, mapSelectionPlace: .constant(searchVm.selectedLocationFav?.mapItem ?? MKMapItem()))
                            .presentationDetents([.height(450)],selection:$uiStateVm.selectedDetent)
                            .presentationBackgroundInteraction(.enabled(upThrough: .height(500)))
                            .presentationDragIndicator(.visible)
                            .interactiveDismissDisabled(true)
                            .presentationCornerRadius(20)
                            .ignoresSafeArea(.keyboard)
                        //MARK: - MAP STYLE
                    case .mapStyle:
                        MapStyleView(mapStyleConfig: $vm.mapStyleConfig)
                            .presentationDetents([.height(300)],selection:$uiStateVm.selectedDetent)
                                .presentationBackgroundInteraction(.enabled(upThrough: .height(300)))
                                .presentationDragIndicator(.visible)
                                .interactiveDismissDisabled(true)
                                .presentationCornerRadius(20)
                        
                        
                        //MARK: - CHAT
                    case .chat:
                        MapMateChatView(cameraPosition: $routeVm.cameraPosition/*, searchResults: $routeVm.searchResults*/)
                            .presentationDetents([.height(600)],selection:$uiStateVm.selectedDetent)
                            .presentationBackgroundInteraction(.enabled(upThrough: .height(600)))
                            .interactiveDismissDisabled(true)
                            .presentationCornerRadius(20)
                            .presentationDragIndicator(.visible)
                            .onAppear(){
                                print("search results: \(searchVm.searchResults)")
                            }
                        
                    case .startedNavigation:
                        StartingRouteView()
                            .presentationDetents([.height(150)],selection:$uiStateVm.selectedDetent)
                            .presentationBackgroundInteraction(.enabled(upThrough: .height(150)))
                            .interactiveDismissDisabled(true)
                            .presentationCornerRadius(20)
                            .presentationDragIndicator(.visible)
                        
                    case .pharmacyView:
                        PharmacySearchView()
                            .presentationDetents([.height(700)],selection:$uiStateVm.selectedDetent)
                            .presentationBackgroundInteraction(.enabled(upThrough: .height(700)))
                            .presentationDragIndicator(.visible)
                            .interactiveDismissDisabled(true)
                            .presentationCornerRadius(20)
                        
        
                        
                    case .empty:
                        EmptyView()
                    } //:Switch
                   
                    
                    
                } //:Sheet
            //MARK: - SIDE MENU
                .overlay(alignment: .topLeading) {
                    Button {
                        withAnimation{
                            if uiStateVm.activeSheet == .startedNavigation {
                                routeVm.stopNavigationAlert.toggle()
                                showToast = true // Toast tetikleniyor
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    showToast = false // 3 saniye sonra toast gizleniyor
                                    
                                }
                                hapticImpact.impactOccurred()
                            } else {
                                sideMenuVm.sideMenuShow.toggle()
                                hapticImpact.impactOccurred()
                                uiStateVm.lastActiveSheet = uiStateVm.activeSheet
                                uiStateVm.activeSheet = nil
                            }
                            
                        

//                            uiStateVm.lastActiveSheet = uiStateVm.activeSheet
//                           
//                            uiStateVm.activeSheet = nil
//                            hapticImpact.impactOccurred()
                                
                        }
                       
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22,height: 22)
                            .padding()
                            
                            .background(colorScheme == .light ? Color.hex("0C7B93").opacity(0.8) : Color("NewBlack1"))
                            .clipShape(Circle())
                            .foregroundStyle(colorScheme == .light ? Color.hex("#F2F2F7"):Color.hex("#F2F2F7"))
                            .padding()
                            .shadow(color: .gray.opacity(0.4), radius: 20, x: 0, y: 20)
                            
                         
                    } //:Button

                } //:Overlay
                .onAppear {
                    Task{
                        await loginVm.fetchUser()
                    }
                  
                }
             
            if showToast {
                VStack {
                    HStack {
                        Spacer()
                        Text("End the ride first".addLocalizableString(str: languageManager.language))
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(8)
                            .shadow(radius: 10)
                        Spacer()
                    }
                    .padding()
                    
                    .cornerRadius(10)
                    Spacer()
                }
                .padding(.top, 50) // Toast’u ekranın tepesine taşır
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.easeInOut, value: showToast)
            }

            favoritesToastView
            favoritesToastViewError
            
    }//:ZStack
        
  }
    

    @ViewBuilder
    private var favoritesToastView:some View{
        if favoritesVm.isShowFavToast{
            VStack {
                if favoritesVm.favEnum == .success{
                    HStack {
                        Spacer()
                        Text(favoritesVm.favoritesToastString)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background( Color.green)
                            .cornerRadius(8)
                            .shadow(radius: 10)
                        Spacer()
                    }
                    .padding()
                    
                    .cornerRadius(10)
                    Spacer()
                }
                
               
            }
            
        }
    }
    
    @ViewBuilder
    private var favoritesToastViewError:some View{
        VStack{
            if favoritesVm.favEnum == .error{
                HStack {
                    Spacer()
                    Text(favoritesVm.favoritesToastString)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(8)
                        .shadow(radius: 10)
                    Spacer()
                }
                .padding()
                
                .cornerRadius(10)
                Spacer()
            }
        }.padding(.top, 50) // Toast’u ekranın tepesine taşır
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.easeInOut, value: favoritesVm.isShowFavToast)
    }
}

//MARK: - PREVIEW
#Preview {
    MainMapView()
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
    
//        .environmentObject(MapStyleConfig())
}


