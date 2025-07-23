//
//  RouteModel.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 11.11.2024.
//

import Foundation
import MapKit

/// Deneme alanı
//struct RouteModel: Identifiable {
//    let id = UUID()
//    let route: MKRoute
//    let travelTimeMinutes: Double
//    let distanceKm: Double
//    let readableTime: String
//}
struct RouteModel: Identifiable {
    let id = UUID()
    let route: MKRoute
    let source: MKMapItem
    let destination: MKMapItem
    var travelTimeMinutes: Double
    var distanceKm: Double
    var readableTime: String
}

