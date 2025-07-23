////
////  StartingRouteView.swift
////  iOS-Map-HelperAi
////
////  Created by Erkin Arikan on 1.01.2025.
////

import SwiftUI
import MapKit

struct StartingRouteView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var uiStateVm: UIStateViewModel
    @EnvironmentObject var locationManager: LocationManagerDummy
    @EnvironmentObject var routeVm: RouteViewModel

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 16) {
                
                // Başlık
                Text("Route Information")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.leading, 16)

                // Yol Bilgisi Kartı
                if let selectedRoute = routeVm.selectedRoute {
                    RouteInfoCard(
                        icon: selectedTransportIcon(),
                        travelTime: selectedRoute.readableTime,
                        distance: String(format: "%.2f", selectedRoute.distanceKm),
                        arrivalTime: routeVm.selectedRouteArrivalTime
                    )
                } else {
                    Text("Please select a route to see the details.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.leading, 16)
                }
                
                Spacer()
            }
            .padding(.top, 16)
            
            // Sağ üstte X işareti
            topRightCloseButton
        }
    }
    
    // İkonu seçili ulaşım tipine göre ayarlayın
    private func selectedTransportIcon() -> Image {
        if uiStateVm.isWalkRouteShowing {
            return Image(systemName: "figure.walk")
        } else {
            return Image(systemName: "car.fill")
        }
    }

    private var topRightCloseButton: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        uiStateVm.getDirections = false
                        uiStateVm.selectedDetent = .height(310)
                        uiStateVm.isFavoritesShowing = true
                        uiStateVm.isGridActive = false
                        uiStateVm.showDestinationDetailsView = false
                        
                        uiStateVm.isDirectionsShow = false
                        uiStateVm.isShowNearByPlaces = false
                        uiStateVm.activeSheet = nil
                        resetCameraToDefault()
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(Color.red))
                        .foregroundColor(.white)
                }
                .padding(.trailing, 16)
                .padding(.top, 16)
            }
            Spacer()
        }
    }

    private var backgroundColor: Color {
        colorScheme == .light ? Color.hex("F2F2F7") : Color("NewBlack1")
    }
    
    private func resetCameraToDefault() {
        let userLocation = locationManager.region.center
        
        // Varsayılan kamera konumunu tanımla
        let defaultRegion = MapCamera(
            centerCoordinate: CLLocationCoordinate2D(latitude: userLocation.latitude, longitude: userLocation.longitude),
            distance: 1000, // Kameranın yüksekliği
            heading: 0,     // Kuzey yönü
            pitch: 0        // Dik açıyla yukarıdan bakış
        )
        
        // Kamerayı sıfırla
        withAnimation(.easeInOut(duration: 1)) {
            routeVm.cameraPosition = .camera(defaultRegion)
        }
    }
}

struct RouteInfoCard: View {
    var icon: Image
    var travelTime: String
    var distance: String
    var arrivalTime: String

    var body: some View {
        HStack(spacing: 16) {
            // İkon
            icon
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)

            // Bilgiler
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(travelTime)")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)

                    Spacer()

                    Text("\(distance) km")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                }

                Text("Arrival Time: \(arrivalTime)")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal, 16)
    }
}




//import SwiftUI
//import MapKit
//struct StartingRouteView: View {
//    
//    @Environment(\.colorScheme) private var colorScheme
//    @EnvironmentObject var uiStateVm:UIStateViewModel
//    @EnvironmentObject var languageManager:LanguageManager
//    @EnvironmentObject var locationManager:LocationManagerDummy
//    @EnvironmentObject var  routeVm:RouteViewModel
//    // Örnek tahmini varış süresi ve kilometre verisi
//    let estimatedTime = "20 dk"
//    let distance = "5.2 km"
//    
//    // MARK: - BODY
//    var body: some View {
//        ZStack {
//            backgroundColor
//                .ignoresSafeArea()
//            
//            VStack(alignment: .leading) {
//                Text("Estimated Time of Arrival")
//                    .font(.headline)
//                    .foregroundColor(.gray)
//
//                if let selectedRoute = routeVm.selectedRoute {
//                    Text("\(selectedRoute.readableTime) | \(String(format: "%.2f", selectedRoute.distanceKm)) km")
//                        .font(.title3)
//                        .fontWeight(.bold)
//                        .foregroundColor(colorScheme == .light ? .black : .white)
//
//                    Text("Arrival Time: \(routeVm.selectedRouteArrivalTime)")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                } else {
//                    Text("Select a route to see details.")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                }
//            }
//            .padding(.leading, 16)
//
//
//            
//            // Sağ üst köşede kırmızı X butonu
//            VStack {
//                HStack {
//                    Spacer()
//                    
//                    Button {
//                        // Buton aksiyonu
//                        withAnimation {
//                           
//                            uiStateVm.getDirections = false
//                            uiStateVm.selectedDetent = .height(310)
//                            uiStateVm.isFavoritesShowing = true
//                            uiStateVm.isGridActive = false
//                            uiStateVm.showDestinationDetailsView = false
//                            
//                            uiStateVm.isDirectionsShow = false
//                            uiStateVm.isShowNearByPlaces = false
//                            uiStateVm.activeSheet = nil
//                            resetCameraToDefault()
//                        }
//                       
//                        print("Xmark button tapped!")
//                    } label: {
//                        Image(systemName: "xmark")
//                            .font(.headline)
//                            .frame(width: 44, height: 44)
//                            .background(Capsule().fill(Color.red))
//                            .foregroundColor(.white)
//                    }
//                    .padding(.trailing, 16)
//                    .padding(.top, 16)
//                }
//                
//                Spacer()
//            }
//        }
//    }
//    private func resetCameraToDefault() {
//            let userLocation = locationManager.region.center
//            
//            // Varsayılan kamera konumunu tanımla
//            let defaultRegion = MapCamera(
//                centerCoordinate: CLLocationCoordinate2D(latitude: userLocation.latitude, longitude: userLocation.longitude),
//                distance: 1000, // Kameranın yüksekliği
//                heading: 0,     // Kuzey yönü
//                pitch: 0        // Dik açıyla yukarıdan bakış
//            )
//            
//            // Kamerayı sıfırla
//            withAnimation(.easeInOut(duration: 1)) {
//                routeVm.cameraPosition = .camera(defaultRegion)
//            }
//        }
//    private var backgroundColor: Color {
//        colorScheme == .light ? Color.hex("F2F2F7") : Color("NewBlack1")
//    }
//}
//
// MARK: - PREVIEW
#Preview {
    StartingRouteView()
        .environmentObject(UIStateViewModel())
        .environmentObject(LocationManagerDummy())
        .environmentObject(LanguageManager())
        .environmentObject(RouteViewModel( locationManager: LocationManagerDummy()))
}
