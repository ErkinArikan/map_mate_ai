//
//  SearchViewTop.swift
//  AI-HelperMap
//
//  Created by Erkin Arikan on 5.09.2024.
//

import SwiftUI
import MapKit
struct DestinationDetailTopView: View {
//    @EnvironmentObject var searchViewModel:SearchViewModel
//    @EnvironmentObject var directionsViewModel:DirectionViewModel
    
    @EnvironmentObject var vm:MapViewModel
    @EnvironmentObject var locationManager:LocationManagerDummy
    @EnvironmentObject var routeVm:RouteViewModel
    @EnvironmentObject var searchViewModelVm:SearchViewModel
    @EnvironmentObject var uiStateVm:UIStateViewModel
    @Environment(\.modelContext) var context
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var favoritesVm:FavoritesViewModel
    var body: some View {
        Spacer()
        Button {
            uiStateVm.activeSheet = .search
            uiStateVm.selectedDetent = .height(310)
            withAnimation(.spring) {
                
                DispatchQueue.main.async {
                    
//                                vm.endingOffSetY = 0
                    print("selectedDetent :\(uiStateVm.selectedDetent)")
                    print("isGridActive : \(uiStateVm.isGridActive)")
                    print("favorites showing :\(uiStateVm.isFavoritesShowing)")
                    uiStateVm.isFavoritesShowing = true
                    uiStateVm.isSecondViewSearchView = false
                    uiStateVm.showDestinationDetailsView = false
                    uiStateVm.showAnnotation = false
                    uiStateVm.isDirectionsShow = false
                    routeVm.selectedLocation = nil
                    
                   uiStateVm.getDirections = false
                    uiStateVm.isShowNearByPlaces = false /// nearby closing
                    routeVm.cameraPosition = MapCameraPosition.region(locationManager.region)
                    searchViewModelVm.searchResults.removeAll()
                    searchViewModelVm.exSearchResul.removeAll(keepingCapacity: false)
                    favoritesVm.fetchUserFavorites()
                   
                    
                }
                print("camera Region updated: \(vm.cameraRegion)")
               
                
            }
        } label: {
            Image(systemName: "xmark")
                .resizable()
                .scaledToFit()
                .fontWeight(.bold)
                .foregroundStyle(Color.hex("F2F2F7"))
            
                
        }
        .frame(width: 14, height: 14)
        .padding(10)
        .background(colorScheme == .light ? Color.hex("0C7B93"): Color(uiColor: .systemGray6))
        .clipShape(Circle())
        
        
    }
}

//HStack {
//            Spacer()
//            RoundedRectangle(cornerRadius: 12)
//                .frame(width: 60, height: 4)
//                .padding(.top, 4)
//                .padding(.leading, 45)
//                .foregroundStyle(Color(.systemGray2))
//            Spacer()
//            Button {
//                withAnimation(.spring) {
//
//                    DispatchQueue.main.async {
//                        vm.selectedDetent = .height(300)
//                        vm.endingOffSetY = 0
//                        vm.showDestinationDetailsView = false
//                        vm.isDirectionsShow = false
//                        vm.showPolyline = false
//                        vm.destinationSelected = false
//                        iosVm.getDirections = false
//
//                        iosVm.cameraPosition = MapCameraPosition.region(locationManager.region)
//                        iosVm.exSearchResul.removeAll(keepingCapacity: false)
//
//                    }
//                    print("camera Region updated: \(vm.cameraRegion)")
//
//
//                }
//            } label: {
//                Image(systemName: "xmark")
//                    .resizable()
//                    .scaledToFit()
//                    .fontWeight(.bold)
//                    .foregroundStyle(Color.black)
//            }
//            .frame(width: 20, height: 20)
//            .padding(.top, 4)
//            .padding(.trailing, 20)
//
//        }
//        .padding(.top)
