//
//  MapiOSViewModel.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 20.09.2024.
//

import Foundation
import SwiftUI
import MapKit
import Combine





class RouteViewModel:  ObservableObject {
    @Published var stopNavigationAlert:Bool = false
    @Published var selectedRouteArrivalTime: String = ""
//    @Published var selectedRoute: RouteModel?
    var selectedRoute: RouteModel? {
        didSet {
            if let selectedRoute = selectedRoute {
                let arrivalDate = Date().addingTimeInterval(selectedRoute.travelTimeMinutes * 60)
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .none
                dateFormatter.timeStyle = .short
                self.selectedRouteArrivalTime = dateFormatter.string(from: arrivalDate)
            }
        }
    }
    @Published var carEstimatedArrival: String = ""
      @Published var walkEstimatedArrival: String = ""
      
      private var updateTimer: Timer? // Süre güncelleme için zamanlayıcı

    
    // MARK: - CAMERA POSITION
        @Published var cameraPosition: MapCameraPosition
        

        @Published var selectedLocation: SearchResultModel?


        // MARK: - Route Information
        @Published var routes: [MKRoute] = []
        @Published var routeDisplaying = false
        @Published var route: MKRoute?
        @Published var routeDestination: MKMapItem?
        @Published var travelTime: TimeInterval = 0
        @Published var travelTimeMinutes: Double = 0
        @Published var distance: Double = 0
        @Published var readableTime: String = ""
        @Published var arrivalDateString: String = ""
        @Published var polyLineMidPoint: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 37.334_900, longitude: -122.009_020)
        @Published var routeModelArray: [RouteModel] = []

        // MARK: - Pedestrian Route Variables
        @Published var walkRouteInfos: [RouteModel] = []
        @Published var walkRoute: MKRoute?
        @Published var walkRouteDestination: MKMapItem?
        @Published var walkTravelTime: TimeInterval = 0
        @Published var walkTravelTimeMinutes: Double = 0
        @Published var walkDistance: Double = 0
        @Published var walkArrivalDateString: String = ""
        @Published var walkReadableTime: String = ""
        @Published var walkRoutes: [MKRoute] = []

 
    
    // MARK: - Location Manager
//       var locationManager = LocationManagerDummy()
    
    
    
    private var locationUpdateCancellable: AnyCancellable?
       let locationManager: LocationManagerDummy
    
    init(cameraPosition: MapCameraPosition = .automatic, locationManager: LocationManagerDummy) {
            self.cameraPosition = cameraPosition
            self.locationManager = locationManager
            setupLocationUpdates()
        }
    
    
    private func setupLocationUpdates() {
        locationManager.onLocationUpdate = { [weak self] newLocation in
            guard let self = self, let newLocation = newLocation, let selectedRoute = self.selectedRoute else { return }

            // Yeni konum ile eski konumu karşılaştır
            let distanceMoved = CLLocation(latitude: newLocation.latitude, longitude: newLocation.longitude)
                .distance(from: CLLocation(latitude: selectedRoute.source.placemark.coordinate.latitude, longitude: selectedRoute.source.placemark.coordinate.longitude))

            // Eğer hareket 10 metreden azsa güncellemeyi atla
            if distanceMoved < 10 { return }

            self.updateRouteInformation(for: newLocation, route: selectedRoute)
        }
    }
    
    private func updateRouteInformation(for location: CLLocationCoordinate2D, route: RouteModel) {
        let userLocation = MKMapItem(placemark: MKPlacemark(coordinate: location))
        let request = MKDirections.Request()
        request.source = userLocation
        request.destination = route.destination
        request.transportType = .automobile // veya .automobile

        Task {
            do {
                let result = try await MKDirections(request: request).calculate()
                if let updatedRoute = result.routes.first {
                    DispatchQueue.main.async {
                        // Yalnızca yeni rota bilgileri geçerliyse güncelle
                        if updatedRoute.distance > 0 {
                            self.updateRouteDetails(for: updatedRoute, originalRoute: route)
                        }
                    }
                }
            } catch {
                print("Hata: \(error.localizedDescription)")
            }
        }
    }


    
    private func updateRouteDetails(for updatedRoute: MKRoute, originalRoute: RouteModel) {
        self.selectedRoute = RouteModel(
            route: updatedRoute,
            source: originalRoute.source,
            destination: originalRoute.destination,
            travelTimeMinutes: updatedRoute.expectedTravelTime / 60,
            distanceKm: updatedRoute.distance / 1000,
            readableTime: {
                let hours = Int(updatedRoute.expectedTravelTime / 3600)
                let minutes = Int(updatedRoute.expectedTravelTime / 60) % 60
                return hours > 0 ? "\(hours) h \(minutes) min" : "\(minutes) min"
            }()
        )
    }
    func fetchPedestrianRoute() {
        if let selectedLocation = selectedLocation {
            let request = MKDirections.Request()
            let userLocation = MKMapItem(placemark: MKPlacemark(coordinate: locationManager.currentLocation ?? CLLocationCoordinate2D(latitude: 39.88276624445194, longitude: 32.68572294962696)))
            let destination = selectedLocation.mapItem
            
            request.source = userLocation
            request.destination = destination
            request.transportType = .walking
            request.requestsAlternateRoutes = true
            request.tollPreference = .avoid
            request.departureDate = Date()
            
            Task {
                let result = try? await MKDirections(request: request).calculate()
                let routes = result?.routes ?? []
                
                DispatchQueue.main.async {
                    if !routes.isEmpty {
                        self.walkRoute = routes.first
                        self.walkRouteDestination = destination
                        self.routeDisplaying = true
                        self.walkTravelTime = self.walkRoute!.expectedTravelTime
                        self.walkDistance = self.walkRoute!.distance / 1000
                        self.travelTimeMinutes = self.walkTravelTime / 60
                        
                        let arrivalDate = Date().addingTimeInterval(self.walkTravelTime)
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateStyle = .medium
                        dateFormatter.timeStyle = .short
                        self.walkArrivalDateString = dateFormatter.string(from: arrivalDate)
                        
                        let hours = Int(self.walkTravelTimeMinutes) / 60
                        let minutes = Int(self.walkTravelTimeMinutes) % 60
                        self.walkReadableTime = hours > 0 ? "\(hours) h \(minutes) min" : "\(minutes) min"
                        
                        // Map routes to RouteModel
                        self.walkRouteInfos = routes.map { route in
                            let travelTimeMinutes = route.expectedTravelTime / 60
                            let distanceKm = route.distance / 1000
                            let hours = Int(travelTimeMinutes) / 60
                            let minutes = Int(travelTimeMinutes) % 60
                            let readableTime = hours > 0 ? "\(hours) h \(minutes) min" : "\(minutes) min"
                            
                            return RouteModel(
                                route: route,
                                source: userLocation,
                                destination: destination,
                                travelTimeMinutes: travelTimeMinutes,
                                distanceKm: distanceKm,
                                readableTime: readableTime
                            )
                        }
                        
                        // Update camera position
                        withAnimation(.snappy) {
                            if let rect = self.route?.polyline.boundingMapRect {
                                let zoomFactor: Double = 1.3
                                let verticalOffset: Double = -0.7 * rect.size.height
                                let adjustedRect = MKMapRect(
                                    x: rect.origin.x - (rect.size.width * (zoomFactor - 1) / 2),
                                    y: rect.origin.y - (rect.size.height * (zoomFactor - 1) / 2) - verticalOffset,
                                    width: rect.size.width * zoomFactor,
                                    height: rect.size.height * zoomFactor
                                )
                                self.cameraPosition = .rect(adjustedRect)
                            }
                        }
                    }
                    
                    // Save all routes
                    self.walkRoutes = routes
                }
            }
        }
    }


    
    func fetchCarRoute() {
        if let selectedLocation = selectedLocation {
            let request = MKDirections.Request()
            
            // Kullanıcının mevcut konumu
            let userLocation = MKMapItem(placemark: MKPlacemark(coordinate: locationManager.currentLocation ?? CLLocationCoordinate2D(latitude: 39.88276624445194, longitude: 32.68572294962696)))
            let destination = selectedLocation.mapItem
            
            request.source = userLocation
            request.destination = destination
            request.transportType = .automobile
            request.requestsAlternateRoutes = true
            request.tollPreference = .avoid
            request.departureDate = Date()
            
            Task {
                do {
                    let result = try await MKDirections(request: request).calculate()
                    let routes = result.routes
                    
                    DispatchQueue.main.async {
                        if !routes.isEmpty {
                            // Ana rotayı seç
                            self.route = routes.first
                            self.routeDestination = destination
                            self.routeDisplaying = true
                            self.travelTime = self.route!.expectedTravelTime
                            self.distance = self.route!.distance / 1000
                            self.travelTimeMinutes = self.travelTime / 60
                            
                            let arrivalDate = Date().addingTimeInterval(self.travelTime)
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateStyle = .medium
                            dateFormatter.timeStyle = .short
                            self.arrivalDateString = dateFormatter.string(from: arrivalDate)
                            
                            let hours = Int(self.travelTimeMinutes) / 60
                            let minutes = Int(self.travelTimeMinutes) % 60
                            self.readableTime = hours > 0 ? "\(hours) h \(minutes) min" : "\(minutes) min"
                            
                            // RouteModel nesnelerini oluştur
                            self.routeModelArray = routes.map { route in
                                let travelTimeMinutes = route.expectedTravelTime / 60
                                let distanceKm = route.distance / 1000
                                let hours = Int(travelTimeMinutes) / 60
                                let minutes = Int(travelTimeMinutes) % 60
                                let readableTime = hours > 0 ? "\(hours) h \(minutes) min" : "\(minutes) min"
                                
                                return RouteModel(
                                    route: route,
                                    source: userLocation,
                                    destination: destination,
                                    travelTimeMinutes: travelTimeMinutes,
                                    distanceKm: distanceKm,
                                    readableTime: readableTime
                                )
                            }
                            
                            // Kamera pozisyonunu güncelle
                            withAnimation(.snappy) {
                                if let rect = self.route?.polyline.boundingMapRect {
                                    let zoomFactor: Double = 1.3
                                    let verticalOffset: Double = -0.7 * rect.size.height
                                    let adjustedRect = MKMapRect(
                                        x: rect.origin.x - (rect.size.width * (zoomFactor - 1) / 2),
                                        y: rect.origin.y - (rect.size.height * (zoomFactor - 1) / 2) - verticalOffset,
                                        width: rect.size.width * zoomFactor,
                                        height: rect.size.height * zoomFactor
                                    )
                                    self.cameraPosition = .rect(adjustedRect)
                                }
                            }
                        }
                        
                        // Tüm rotaları kaydet
                        self.routes = routes
                    }
                } catch {
                    print("Hata: \(error.localizedDescription)")
                }
            }
        }
    }

    

    //MARK: - UPDATE ESTIMATED ARRIVAL TIME
    func updateEstimatedArrivalTime(for travelTime: TimeInterval, transportType: TransportType) {
        let arrivalDate = Date().addingTimeInterval(travelTime)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        let formattedTime = dateFormatter.string(from: arrivalDate)

        DispatchQueue.main.async {
            switch transportType {
            case .car:
                self.carEstimatedArrival = formattedTime
            case .walk:
                self.walkEstimatedArrival = formattedTime
            }
        }
    }

    //MARK: - UPDATE LOCATION DETAILS
    func updateLocationDetails(_ location: SearchResultModel?) {
        guard let location = location else { return }
        print("Seçilen adres: \(location.mapItem.name ?? "Bilinmiyor")")
        print("Koordinatlar: \(location.mapItem.placemark.coordinate)")
    }
    
    
    
    
    
    
}






//    func fetchPedestrianRoute(){
//        if let selectedLocation = selectedLocation{
//            let request = MKDirections.Request()
//            request.source = MKMapItem(placemark: MKPlacemark(coordinate: locationManager.currentLocation ?? CLLocationCoordinate2D(latitude: 39.88276624445194, longitude: 32.68572294962696)))
//            request.destination = selectedLocation.mapItem
//            request.transportType = .walking
//            request.requestsAlternateRoutes = true
//            request.tollPreference = .avoid
//            request.departureDate = Date()
//
//            Task{
//                let result = try? await MKDirections(request: request).calculate()
//                let routes = result?.routes ?? []
//
//                DispatchQueue.main.async {
//                    if !routes.isEmpty {
//                        // Use the first route as the main route
//                        self.walkRoute = routes.first
//                        self.walkRouteDestination = selectedLocation.mapItem
//                        self.routeDisplaying = true
//                        self.walkTravelTime = self.walkRoute!.expectedTravelTime
//                        self.walkDistance = self.walkRoute!.distance / 1000
//                        self.travelTimeMinutes = self.walkTravelTime / 60
//
//                        let arrivalDate = Date().addingTimeInterval(self.travelTime)
//                        let dateFormatter = DateFormatter()
//                        dateFormatter.dateStyle = .medium
//                        dateFormatter.timeStyle = .short
//                        self.walkArrivalDateString = dateFormatter.string(from: arrivalDate)
//
//                        let hours = Int(self.walkTravelTimeMinutes) / 60
//                        let minutes = Int(self.walkTravelTimeMinutes) % 60
//                        if hours > 0 {
//                            self.walkReadableTime = "\(hours) h \(minutes) min"
//                        } else {
//                            self.walkReadableTime = "\(minutes) min"
//                        }
//
//
//                        self.walkRouteInfos = routes.map { route in
//                            let travelTimeMinutes = route.expectedTravelTime / 60
//                            let distanceKm = route.distance / 1000
//                            let hours = Int(travelTimeMinutes) / 60
//                            let minutes = Int(travelTimeMinutes) % 60
//                            let readableTime: String
//                            if hours > 0 {
//                                readableTime = "\(hours) h \(minutes) min"
//                            } else {
//                                readableTime = "\(minutes) min"
//                            }
//
//
//
//                            return RouteModel(route: route, travelTimeMinutes: travelTimeMinutes, distanceKm: distanceKm, readableTime: readableTime)
//                        }
//
//
//
////                        // Ana thread üzerinde cameraPosition'ı güncelle
//                        DispatchQueue.main.async {
//                            withAnimation(.snappy) {
//                                if let rect = self.route?.polyline.boundingMapRect {
//                                    // Uzaklaştırma ve yukarı kaydırma işlemi
//                                    let zoomFactor: Double = 1.3 // Daha fazla uzaklaştırma faktörü (arttırılmış)
//
//                                    // Alttaki sheet'in kapanması için yukarı doğru kaydırma
//                                    let verticalOffset: Double = -0.7 * rect.size.height // Haritayı yukarı kaydırmak için %10'luk bir offset
//
//                                    let adjustedRect = MKMapRect(
//                                        x: rect.origin.x - (rect.size.width * (zoomFactor - 1) / 2),
//                                        y: rect.origin.y - (rect.size.height * (zoomFactor - 1) / 2) - verticalOffset, // Yukarı kaydırma
//                                        width: rect.size.width * zoomFactor,
//                                        height: rect.size.height * zoomFactor
//                                    )
//
//                                    self.cameraPosition = .rect(adjustedRect)
//                                }
//                            }
//                        }
//
//                        Task {
//                                  let result = try? await MKDirections(request: request).calculate()
//                                  let routes = result?.routes ?? []
//
//                                  DispatchQueue.main.async {
//                                      if let mainRoute = routes.first {
//                                          self.route = mainRoute
//                                          self.travelTime = mainRoute.expectedTravelTime
//                                          self.updateEstimatedArrivalTime(for: mainRoute.expectedTravelTime, transportType: .car)
//                                      }
//                                      self.routes = routes
//                                  }
//                              }
//                    }
//
//                    // Save all the routes
//                    self.walkRoutes = routes
//                }
//            }
//        }
//    }


//    func fetchCarRoute() {
//        if let selectedLocation = selectedLocation {
//
//            let request = MKDirections.Request()
//
//            request.source = MKMapItem(placemark: MKPlacemark(coordinate: locationManager.currentLocation ?? CLLocationCoordinate2D(latitude: 39.88276624445194, longitude: 32.68572294962696)))
//            request.destination = selectedLocation.mapItem
//            request.transportType = .automobile
//            request.requestsAlternateRoutes = true
//            request.tollPreference = .avoid
//            request.departureDate = Date()
//
//            Task {
//                let result = try? await MKDirections(request: request).calculate()
//                let routes = result?.routes ?? []
//
//                DispatchQueue.main.async {
//                    if !routes.isEmpty {
//                        // Use the first route as the main route
//                        self.route = routes.first
//                        self.routeDestination = selectedLocation.mapItem
//                        self.routeDisplaying = true
//                        self.travelTime = self.route!.expectedTravelTime
//                        self.distance = self.route!.distance / 1000
//                        self.travelTimeMinutes = self.travelTime / 60
//
//                        let arrivalDate = Date().addingTimeInterval(self.travelTime)
//                        let dateFormatter = DateFormatter()
//                        dateFormatter.dateStyle = .medium
//                        dateFormatter.timeStyle = .short
//                        self.arrivalDateString = dateFormatter.string(from: arrivalDate)
//
//                        let hours = Int(self.travelTimeMinutes) / 60
//                        let minutes = Int(self.travelTimeMinutes) % 60
//                        if hours > 0 {
//                            self.readableTime = "\(hours) h \(minutes) min"
//                        } else {
//                            self.readableTime = "\(minutes) min"
//                        }
//
//
//
//                        self.routeModelArray = routes.map { route in
//                            let travelTimeMinutes = route.expectedTravelTime / 60
//                            let distanceKm = route.distance / 1000
//                            let hours = Int(travelTimeMinutes) / 60
//                            let minutes = Int(travelTimeMinutes) % 60
//                            let readableTime: String
//                            if hours > 0 {
//                                readableTime = "\(hours) h \(minutes) min"
//                            } else {
//                                readableTime = "\(minutes) min"
//                            }
//
//                            return RouteModel(route: route, travelTimeMinutes: travelTimeMinutes, distanceKm: distanceKm, readableTime: readableTime)
//                        }
//
////                         Ana thread üzerinde cameraPosition'ı güncelle
//                        DispatchQueue.main.async {
//                            withAnimation(.snappy) {
//                                if let rect = self.route?.polyline.boundingMapRect {
//                                    // Uzaklaştırma ve yukarı kaydırma işlemi
//                                    let zoomFactor: Double = 1.3 // Daha fazla uzaklaştırma faktörü (arttırılmış)
//
//                                    // Alttaki sheet'in kapanması için yukarı doğru kaydırma
//                                    let verticalOffset: Double = -0.7 * rect.size.height // Haritayı yukarı kaydırmak için %10'luk bir offset
//
//                                    let adjustedRect = MKMapRect(
//                                        x: rect.origin.x - (rect.size.width * (zoomFactor - 1) / 2),
//                                        y: rect.origin.y - (rect.size.height * (zoomFactor - 1) / 2) - verticalOffset, // Yukarı kaydırma
//                                        width: rect.size.width * zoomFactor,
//                                        height: rect.size.height * zoomFactor
//                                    )
//
//                                    self.cameraPosition = .rect(adjustedRect)
//                                }
//                            }
//                        }
//
//                        Task {
//                                  let result = try? await MKDirections(request: request).calculate()
//                                  let routes = result?.routes ?? []
//
//                                  DispatchQueue.main.async {
//                                      if let mainRoute = routes.first {
//                                          self.route = mainRoute
//                                          self.travelTime = mainRoute.expectedTravelTime
//                                          self.updateEstimatedArrivalTime(for: mainRoute.expectedTravelTime, transportType: .walk)
//                                      }
//                                      self.routes = routes
//                                  }
//                              }
//                    }
//
//                    // Save all the routes
//                    self.routes = routes
//                }
//            }
//
//        }
//    }
