//
//  PharmacyModel.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 9.01.2025.
//

import Foundation
import MapKit


// Ana model
struct PharmacyResponse: Codable {
    let success: Bool
    let result: [Pharmacy]
}

// Nöbetçi eczane modeli
struct Pharmacy: Codable {
    let name: String
    var dist: String
    let address: String
    let phone: String
    let loc: String
    
    var coordinate: CLLocationCoordinate2D? {
            let components = loc.split(separator: ",")
            if components.count == 2,
               let lat = Double(components[0]),
               let lon = Double(components[1]) {
                return CLLocationCoordinate2D(latitude: lat, longitude: lon)
            }
            return nil
        }
}
