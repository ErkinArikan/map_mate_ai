//
//  ContentView.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 20.09.2024.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    @EnvironmentObject var vm: MapViewModel
    @EnvironmentObject var searchViewModel: SearchViewModel
    @EnvironmentObject var routeVm: RouteViewModel
    @Namespace private var favoritesMap
    @EnvironmentObject var locationManager:LocationManagerDummy
    @State private var selection: SearchResultModel?
    
    var body: some View {
        VStack {
            Map(position: $routeVm.cameraPosition) {
                
            }
            .mapScope(favoritesMap)
            .ignoresSafeArea(.all)
        }
        .padding()
    }
    
    
}

#Preview {
    ContentView()
        .environmentObject(MapViewModel(locationManager: LocationManagerDummy()))
        .environmentObject(RouteViewModel( locationManager: LocationManagerDummy()))
        .environmentObject(LocationManagerDummy())
        .environmentObject(SearchViewModel())
}
