//
//  SearchResultModel.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 11.11.2024.
//

import Foundation
import MapKit


struct SearchResultModel: Identifiable, Hashable {
    let id = UUID()
    let mapItem: MKMapItem
//    let address: String? // Yeni bir özellik eklendi

    static func == (lhs: SearchResultModel, rhs: SearchResultModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
