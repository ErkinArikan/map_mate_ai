//
//  SearchManager.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 11.11.2024.
//

import Foundation
import MapKit




@Observable
class SearchManager: NSObject, MKLocalSearchCompleterDelegate {
    private let completer: MKLocalSearchCompleter

    var completions = [SearchCompletionsModel]()

    init(completer: MKLocalSearchCompleter) {
        self.completer = completer
        super.init()
        self.completer.delegate = self
    }

    func update(queryFragment: String) {
        completer.resultTypes = .pointOfInterest
        completer.queryFragment = queryFragment
    }


    
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completions = completer.results.map { completion in
            let mapItem = completion.value(forKey: "_mapItem") as? MKMapItem
            let coordinate = mapItem?.placemark.coordinate
            let locationString = coordinate != nil ? "\(coordinate!.latitude), \(coordinate!.longitude)" : "N/A"
            
            return .init(
                title: completion.title,
                subTitle: completion.subtitle,
                url: mapItem?.url,
                location: locationString // Konumu string olarak sakla
            )
        }
    }
    
    
    
    // Direkt aratmalara bastıktan sonra gelenler. Gerçek aratma yapıyor
    
    func search(with query: String, coordinate: CLLocationCoordinate2D? = nil) async throws -> [SearchResultModel] {
        let mapKitRequest = MKLocalSearch.Request()
        mapKitRequest.naturalLanguageQuery = query
        mapKitRequest.resultTypes = .pointOfInterest
        if let coordinate {
            mapKitRequest.region = .init(.init(origin: .init(coordinate), size: .init(width: 1, height: 1)))
        }
        let search = MKLocalSearch(request: mapKitRequest)

        let response = try await search.start()

        return response.mapItems.map { mapItem in
            SearchResultModel(mapItem: mapItem)
        }
    }
    
    
    
    func searchAddress(for coordinate: CLLocationCoordinate2D) async throws -> [SearchResultModel] {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        // Ters geocoding ile adres bilgilerini al
        let placemarks: [CLPlacemark] = try await withCheckedThrowingContinuation { continuation in
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let placemarks = placemarks {
                    continuation.resume(returning: placemarks)
                } else {
                    continuation.resume(returning: [])
                }
            }
        }

        // Geocoding sonuçlarından ilkini al
        guard let firstPlacemark = placemarks.first else {
            return []
        }

        // Detaylı arama için bir istek oluştur
        let mapKitRequest = MKLocalSearch.Request()
        mapKitRequest.naturalLanguageQuery = firstPlacemark.name
        mapKitRequest.region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

        // MKLocalSearch kullanarak detaylı sonuçları ara
        let search = MKLocalSearch(request: mapKitRequest)
        let response = try await search.start()

        // Detaylı bilgileri içeren sonuçları döndür
        return response.mapItems.map { mapItem in
            SearchResultModel(mapItem: mapItem)
        }
    }



}





//    func sortedCompletions(userLocation: CLLocationCoordinate2D) -> [SearchCompletionsModel] {
//        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
//
//        return completions.sorted { completion1, completion2 in
//            guard let loc1 = coordinateFromString(completion1.location),
//                  let loc2 = coordinateFromString(completion2.location) else {
//                return false
//            }
//            let distance1 = userCLLocation.distance(from: CLLocation(latitude: loc1.latitude, longitude: loc1.longitude))
//            let distance2 = userCLLocation.distance(from: CLLocation(latitude: loc2.latitude, longitude: loc2.longitude))
//            return distance1 < distance2
//        }
//    }
//
//    // String'den CLLocationCoordinate2D'ye dönüştürme
//    private func coordinateFromString(_ locationString: String) -> CLLocationCoordinate2D? {
//        let components = locationString.split(separator: ",").compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
//        guard components.count == 2 else { return nil }
//        return CLLocationCoordinate2D(latitude: components[0], longitude: components[1])
//    }
//
//
    
//    func search(with query: String, coordinate: CLLocationCoordinate2D? = nil) async throws -> [SearchResultModel] {
//        let mapKitRequest = MKLocalSearch.Request()
//        mapKitRequest.naturalLanguageQuery = query
//        mapKitRequest.resultTypes = .pointOfInterest
//
//        if let coordinate {
//            // Daha dar bir bölge için ayar yapılıyor
//            let regionSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1) // Yakınlık bölgesi
//            mapKitRequest.region = MKCoordinateRegion(center: coordinate, span: regionSpan)
//        }
//
//        let search = MKLocalSearch(request: mapKitRequest)
//        let response = try await search.start()
//
//        return response.mapItems.map { mapItem in
//            SearchResultModel(mapItem: mapItem)
//        }
//    }

