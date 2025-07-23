//
//  MapViewModel.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 20.09.2024.
//

import Foundation
import MapKit
import SwiftUI


class MapViewModel: ObservableObject {
    
    // MARK: - Map and Directions Configurations
    @Published var mapStyleConfig = MapStyleConfig()
    
    @Published var cameraRegion: EquatableCoordinateRegion = EquatableCoordinateRegion(
        region: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )
    
    
    // MARK: - Location Manager
    private var locationManager: LocationManagerDummy
    
    
    
    // Constructor
    init(locationManager: LocationManagerDummy,cameraPosition: MapCameraPosition = MapCameraPosition.automatic) {
  
        self.locationManager = locationManager
        self.cameraRegion = EquatableCoordinateRegion(region: locationManager.region)
        setupBindings()
    }
    
    
    
    
  
    
    
    // Set up bindings between locationManager and cameraRegion
    //setupBindings() fonksiyonu, locationManager ile cameraRegion arasında bir bağlantı (binding) kurar. Bu sayede konum güncellendiğinde harita da otomatik olarak güncellenir.
    private func setupBindings() {
        locationManager.$region
            .map { EquatableCoordinateRegion(region: $0) }
            .assign(to: &$cameraRegion)
    }
    
    
    
    
    
    /// Bu burda olmayabilir veya olabilir bu class adı altında olması mantıklı mı
    /// Verilen searchName'e göre PlaceType dönen fonksiyon
    func getPlaceType(for searchName: String) -> PlaceType {
           switch searchName {
           case "Hastane":
               return .hospital
           case "Kafe":
               return .coffee
           case "Alışveriş Merkezi":
               return .shoppingMall
           case "Market":
               return .market
           case "Metro İstasyonu":
               return .metroStation
           case "Şarj İstasyonu":
               return .chargingStation
           case "Eczane":
               return .pharmacy
           case "ATM":
               return .atm
           case "Otel":
               return .hotel
           case "Benzinlik":
               return .gasStation
           default:
               return .hospital // Varsayılan bir ikon döndürmek için
           }
       }
    
    
    
    
    
    
    
    
    
}
