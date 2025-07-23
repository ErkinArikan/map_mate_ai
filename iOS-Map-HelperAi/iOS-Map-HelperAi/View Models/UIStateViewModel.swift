//
//  UiStateViewModel.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 12.11.2024.
//

import Foundation
import MapKit
import SwiftUI


class UIStateViewModel:ObservableObject{
    
    // MARK: - Sheet and View State Variables
    @Published var selectedDetent: PresentationDetent = .height(310)
    @Published var activeSheet: ActiveSheet?
    @Published var lastActiveSheet: ActiveSheet?
    @Published var showDestinationDetailsView: Bool = false
    @Published var showAnnotation:Bool = false
    @Published var isFavoritesShowing: Bool = true  // Favoriler her zaman açık başlasın
    @Published var showDropdown: Bool = false
    @Published var showToast: Bool = false
    @Published var isDirectionsShow: Bool = false
    
    // MARK: - UI State Variables
    @Published var isShowNearByPlaces: Bool = false
    @Published var isWalkRouteShowing: Bool = false
    @Published var isSheetPresented: Bool = false
    @Published var shouldCenterMapOnUser: Bool = false
    @Published var showDetails: Bool = false
    @Published var getDirections: Bool = false
    
    // MARK: - View State Variables
    @Published var isSearchViewShow: Bool = false
    @Published var isGridActive: Bool = false
    @Published var isSecondViewSearchView: Bool = false
    
    
}
