//
//  SearchViewTop.swift
//  AI-HelperMap
//
//  Created by Erkin Arikan on 5.09.2024.
//

import SwiftUI
import MapKit
struct DirectionsTopView: View {
//    @EnvironmentObject var searchViewModel:SearchViewModel
//    @EnvironmentObject var directionsViewModel:DirectionViewModel
    
    @EnvironmentObject var vm:MapViewModel
    @EnvironmentObject var locationManager:LocationManagerDummy
    @EnvironmentObject var routeVm:RouteViewModel
    @EnvironmentObject var searchViewModel:SearchViewModel
    @EnvironmentObject var uiStateVm:UIStateViewModel
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        Spacer()
        Button {
            withAnimation(.spring) {
                
                DispatchQueue.main.async {
                    uiStateVm.selectedDetent = .height(300)
//                                vm.endingOffSetY = 0
                    uiStateVm.isSecondViewSearchView = false
                    
                    uiStateVm.isDirectionsShow = false
                 
                   
                    uiStateVm.getDirections = false
                   
                  
//                    searchViewModel.exSearchResul.removeAll(keepingCapacity: false)
                    uiStateVm.activeSheet = .details
                    
                    
                    #warning("Burayı değiştirdim. 9 ocak 14:16")
                    if let lat = routeVm.selectedLocation?.mapItem.placemark.coordinate.latitude,
                       let lon = routeVm.selectedLocation?.mapItem.placemark.coordinate.longitude {
                        // Yeni bir hedef bölge oluştur
                        let targetRegion = MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005) // Daha yakın bir görünüm için dar delta
                        )

                        // Animasyonu biraz daha yumuşak hale getirmek için bir `easeInOut` animasyonu kullan
                        withAnimation(.easeInOut(duration: 1.2)) { // Daha uzun süreli ve akıcı animasyon
                            routeVm.cameraPosition = .region(targetRegion)
                        }
                    }

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
        .background(colorScheme == .light ? Color.hex("0C7B93") : Color(.systemGray6))
        .clipShape(Circle())
        
        
    }
}

