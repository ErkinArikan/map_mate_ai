//
//  SearchBarView.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 11.11.2024.
//
import SwiftUI
import MapKit
struct SearchBarTextView: View {
    @EnvironmentObject var locationManager: LocationManagerDummy
    @EnvironmentObject var vm: MapViewModel
    @EnvironmentObject var searchViewModel: SearchViewModel
    @EnvironmentObject var uiStateVm:UIStateViewModel
    @Binding var searchResults: [SearchResultModel]
    @Binding var getDirections:Bool
    @EnvironmentObject var languageManager:LanguageManager
    var body: some View {
        InfoField(searchResults: $searchResults, getDirections: $getDirections, title: "Search Address".addLocalizableString(str: languageManager.language), text: $searchViewModel.searchText)
            .onChange(of: searchViewModel.searchText, { _, newValue in
                uiStateVm.showDropdown = !newValue.isEmpty
                searchViewModel.exSearchResul.removeAll(keepingCapacity: false)
                searchViewModel.locationService.update(queryFragment: newValue)
                print("show dropdown\(uiStateVm.showDropdown)")
                
            })
            .ignoresSafeArea(.keyboard)
            .submitLabel(.search)
            .simultaneousGesture(
                   TapGesture().onEnded {
                       withAnimation(.spring(duration: 0.3)) {
                           hapticImpact.impactOccurred()
                           uiStateVm.isFavoritesShowing = false
                           uiStateVm.selectedDetent = .height(500)
                          
                       }
                   }
               )
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done".addLocalizableString(str: languageManager.language)) { hideKeyboard() }
                
                }
            }
    }
}


