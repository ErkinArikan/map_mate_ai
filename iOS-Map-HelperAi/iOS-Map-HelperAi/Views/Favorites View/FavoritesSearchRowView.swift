//
//  FavoritesSearchRowView.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 24.10.2024.
//

import SwiftUI

struct FavoritesSearchRowView: View {
    
    @EnvironmentObject var locationManager: LocationManagerDummy
    @EnvironmentObject var vm: MapViewModel
    @EnvironmentObject var searchViewModel: SearchViewModel
    @Binding var searchResultsFav: [SearchResultModel]
    @EnvironmentObject var routeVm:RouteViewModel
    @EnvironmentObject var uiStateVm:UIStateViewModel
    @EnvironmentObject var languageManager:LanguageManager
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var favoritesVm:FavoritesViewModel
    @Binding var getDirections:Bool
    var body: some View {
        HStack {
            //MARK: - TEXT FIELD
            InfoField(searchResults: $searchResultsFav, getDirections: $getDirections, title: "Search Address", text: $searchViewModel.searchText)
            
                .onChange(of: searchViewModel.searchText, { _, newValue in
                    uiStateVm.showDropdown = !newValue.isEmpty
                    searchViewModel.locationService.update(queryFragment: newValue)
                    print("show dropdown\(uiStateVm.showDropdown)")
                })
                .submitLabel(.search)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done".addLocalizableString(str: languageManager.language)) { hideKeyboard() }
                    
                    }
                }
            
            //MARK: - X BUTTON
           
            Button {
                withAnimation(.easeInOut){
                    uiStateVm.selectedDetent = .height(310)
                    uiStateVm.isSearchViewShow = false
                    searchViewModel.searchText = ""
                    searchViewModel.searchResultsFav.removeAll()
                    print("current detent: \(uiStateVm.selectedDetent)")
                    
                    
                    uiStateVm.isShowNearByPlaces = false
                    uiStateVm.isSecondViewSearchView = false
                    uiStateVm.isFavoritesShowing = true
                    uiStateVm.activeSheet = .search
                    favoritesVm.fetchUserFavorites()
                }
                
            } label: {
                ZStack {
                   
                    Circle()
                        .fill(colorScheme == .light ?  Color.hex("0C7B93").opacity(0.7): Color(.systemGray6))
                        .frame(width: 35, height: 35)
                        .padding(.leading)
    //
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 17, height: 17)
                        .padding(.leading)
                        .foregroundStyle( colorScheme == .light ? Color.hex("F2F2F7"): Color.hex("F2F2F7"))
                        .fontWeight(.medium)
                }
            } //:Xmark Button
            
        } //:HStack
        .padding()
        .ignoresSafeArea(.keyboard)
    }
}



