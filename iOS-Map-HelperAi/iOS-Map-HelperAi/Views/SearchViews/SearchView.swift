//
//  SearchView.swift
//  AI-HelperMap
//
//  Created by Erkin Arikan on 5.09.2024.
//

import SwiftUI
import SwiftData
import MapKit

struct SearchView: View {
    

    @EnvironmentObject var routeVm :RouteViewModel
    @EnvironmentObject var locationManager:LocationManagerDummy
    @EnvironmentObject var vm:MapViewModel
    @EnvironmentObject var searchViewModel:SearchViewModel
    @EnvironmentObject var uiStateVm:UIStateViewModel
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var languageManager:LanguageManager

    var body: some View {
        ZStack {
//          Color("DarkBg2")
//                .ignoresSafeArea(.all)
            VStack(alignment:.leading) {


                //MARK: - SEARCH BAR
                SearchBarView(
                    searchResults: $searchViewModel.searchResults,
                    showDetails: $uiStateVm.showDetails,
                    cameraPosition: $routeVm.cameraPosition, getDirections: $uiStateVm.getDirections
                )
                .padding(.top,30)
                
                withAnimation {
                    VStack(alignment:.leading){
                        if !uiStateVm.showDropdown {
                            if !uiStateVm.isFavoritesShowing  {
                             
                                if uiStateVm.isGridActive  {
                                    VStack{
                                        
                                        NearBySearchViewHorizontal()
                                            .padding(.top,10)
                                        
                                        RecentSearhView()
                                            .frame(maxHeight:.infinity)
                                    }
                                    
                                }
                            }
                            
                            
                            if !uiStateVm.isGridActive || uiStateVm.selectedDetent == .height(310){
                                // eğer favoriler true ise
                                if uiStateVm.isFavoritesShowing  {
                                    
                                    if uiStateVm.selectedDetent != .height(60){
                                        VStack(alignment:.leading) {
                                            FavoritesButtonsView() //:VStack
                                                .padding(.top,8)
                                                
                                            
                                            VStack(alignment:.leading){
                                                NearBySearchView()
                                                    
                                            }
                                            
                                            
                                        }
                                        
                                       
                                      
                                    }else{
                                       
                                        EmptyView()
                                            
                                        
                                    }
                                    
                                   
                                    
                                }else{
                                    
                                    // eğer tıkladım ve aratma yapıcam ve yazıcaksam son arananları kapatmak için condition
                                   
                                        VStack{
                                            RecentSearhView()

                                                .frame(maxHeight:.infinity)
                                          
//                                            NearBySearchView()
//                                                .padding(.top,8)

                                            Spacer()
                                        }
                                        
                                    
                                    
                                }
                        }
                       
                        }
                    }

                }

                
                Spacer()
            }
        }
        .background{
            colorScheme == .light ?  Color.hex("F2F2F7").ignoresSafeArea(.all):Color("NewBlack1").ignoresSafeArea(.all)
        }
//        Color.hex("F2F2F7")Color.hex("0C7B93")
        .ignoresSafeArea(.keyboard)
        .ignoresSafeArea()
    
    }
}

#Preview {
    SearchView()
        .environmentObject(LocationManagerDummy())
        .environmentObject(MapViewModel(locationManager: LocationManagerDummy()))
        .environmentObject(RouteViewModel( locationManager: LocationManagerDummy()))
        .environmentObject(SearchViewModel())
        .environmentObject(UIStateViewModel())
}
