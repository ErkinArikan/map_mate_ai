//
//  EquatableCoordinateRegion.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 11.11.2024.
//

import Foundation


import Foundation
import MapKit
import SwiftUI

struct EquatableCoordinateRegion: Equatable {
    let region: MKCoordinateRegion

    static func == (lhs: EquatableCoordinateRegion, rhs: EquatableCoordinateRegion) -> Bool {
        return lhs.region.center.latitude == rhs.region.center.latitude &&
               lhs.region.center.longitude == rhs.region.center.longitude &&
               lhs.region.span.latitudeDelta == rhs.region.span.latitudeDelta &&
               lhs.region.span.longitudeDelta == rhs.region.span.longitudeDelta
    }
}
