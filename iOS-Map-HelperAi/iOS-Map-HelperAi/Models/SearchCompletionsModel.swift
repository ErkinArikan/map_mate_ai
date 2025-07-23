//
//  SearchCompletionsModel.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 11.11.2024.
//
import MapKit
import Foundation

struct SearchCompletionsModel: Identifiable {
    let id = UUID()
    let title: String
    let subTitle: String
    // New property to hold the URL if it exists
    var url: URL?
    var location: String // Konumu string olarak saklayacak
}
