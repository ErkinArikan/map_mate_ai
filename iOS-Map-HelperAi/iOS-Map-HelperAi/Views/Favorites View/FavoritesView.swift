//
//  FavoritesView.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 19.10.2024.
//

import SwiftUI
import MapKit


struct FavoritesView: View {
    //MARK: - VARIABLES
    @EnvironmentObject var locationManager: LocationManagerDummy
    @EnvironmentObject var vm: MapViewModel
    @EnvironmentObject var searchViewModel: SearchViewModel
    @Environment(\.modelContext) var context
    @EnvironmentObject var routeVm:RouteViewModel
    
    @Binding var searchResultsFav: [SearchResultModel]
    @Binding var showDetails: Bool
    //    @Binding var cameraPosition: MapCameraPosition
    @Binding var getDirections:Bool
    @State var isLocalPlacesSearch:Bool = false
    @Binding var mapSelectionPlace:MKMapItem?
    var map = MapView()
    
    @EnvironmentObject var favoritesVm:FavoritesViewModel
    @EnvironmentObject var languageManager:LanguageManager
    
    
    //MARK: - BODY
    var body: some View {
        
        ZStack {
            // Background Color
            Color("DarkBg2").ignoresSafeArea()
            
            VStack {
                // MARK: - SEARCH BAR
                FavoritesSearchRowView(searchResultsFav: $searchResultsFav, getDirections: $getDirections)
                
                
                Divider()
                
                // MARK: - MAIN CONTENT
                if !searchViewModel.searchText.isEmpty {
                    /// Seach yapıp drop down açılan  adress listeleri
                    SearchResultsView
                } else {
                    if let selectedLocation = searchViewModel.selectedLocationFav {
                        /// Adress listesinden seçilen yer.
                        SelectedPlaceView(selectedLocation: selectedLocation)
                    } else {
                        
                        /// Text içine hiçbir şey yazılmadıysa kullanıcıya preview göster.
                        FavoritesPreviewView()
                    }
                }
                
                Spacer()
            }
            .padding()
            
            ///SearchResultsFavdan döneni  local searchReuslstFav'a yolluyoruz
            .onChange(of: searchViewModel.searchResultsFav, { _, newValue in
                searchResultsFav = newValue
            })
        }
        .overlay(alignment: .top, content: {
            if searchViewModel.isFavLocationSelected {
                ToastView(message: "Added to Favorites")
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut, value: searchViewModel.isFavLocationSelected)
            }
        })
        
        
    }
    
    
    
}
//MARK: - PREVIEW
#Preview {
    FavoritesView(searchResultsFav:.constant(.init()), showDetails: .constant(false), getDirections: .constant(false), mapSelectionPlace: .constant(.init()))
        .environmentObject(RouteViewModel( locationManager: LocationManagerDummy()))
        .environmentObject(SearchViewModel())
        .environmentObject(MapViewModel(locationManager: LocationManagerDummy()))
        .environmentObject(LocationManagerDummy())
        .environmentObject(SideMenuViewModel())
        .environmentObject(UIStateViewModel())
        .environmentObject(LanguageManager())
}


//MARK: - EXTENSION
extension FavoritesView{
    
    
    
    //MARK: - SELECTED FAV PLACE
    private func SelectedPlaceView(selectedLocation: SearchResultModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Selected Location")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(selectedLocation.mapItem.name ?? "Unknown Name")
                    .font(.title3)
                    .fontWeight(.bold)
                Text(selectedLocation.mapItem.placemark.title ?? "Unknown Address")
                    .font(.body)
                    .foregroundColor(.gray)
            }
            
            Divider()
            
            Button(action: {
                // Add functionality to handle favorite location
//                searchViewModel.isFavLocationSelected = true
//                map.saveToFavoritesPlace(from: searchViewModel.selectedLocationFav, context: context)
                showToastMessage()
                
                favoritesVm.saveFavoritePlaceToUser(from: searchViewModel.selectedLocationFav)
                favoritesVm.fetchUserFavorites()
            }) {
                Text("Add to Favorites")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.hex("0C7B93"))
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
    
    
    //MARK: - TOAST MESSAGE
    func showToastMessage() {
        print("Toast shoving")
        withAnimation {
            searchViewModel.isFavLocationSelected = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                searchViewModel.isFavLocationSelected = false
                print("Toast closed")
            }
        }
    }
    
    //MARK: - SEARCH RESULT VIEW
    private var SearchResultsView: some View{
        List {
            ForEach(searchViewModel.locationService.completions) { completion in
                Button(action: {
                    
                    /// farklı didTap kullanıldı
                    searchViewModel.didTapOnSearchCompletionFavorites(completion)
                    
                    ///Text tekarar kullanılabilir hale gelsin
                    searchViewModel.searchText = ""
                    
                    
                    
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing:8){
                            Circle()
                                .frame(width: 8,height:8)
                                .foregroundStyle(Color("TextColor").opacity(0.6))
                            
                            VStack(alignment: .leading, spacing: 4){
                                Text(completion.title)
                                    .font(.system(size: 17, weight: .medium))
                                Text(completion.subTitle)
                                    .foregroundStyle(Color("TextColor").opacity(0.6))
                                
                                if let url = completion.url {
                                    Link(url.absoluteString, destination: url)
                                        .lineLimit(1)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "map.circle")
                                .resizable()
                                .fontWeight(.light)
                                .scaledToFit()
                                .frame(width: 30,height: 30)
                                .foregroundStyle(Color("TextColor").opacity(0.6))
                            
                            
                        }
                        
                    }
                    
                    
                    
                }
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollDismissesKeyboard(.immediately)
        .scrollIndicators(.hidden)
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - SELECTED PLACE VIEW
//    private var SelectedPlaceView:some View{
//        
//        VStack(alignment: .leading){
//            if mapSelectionPlace != nil/*, selectedPlace.name != "Unknown Location"*/{
//                VStack(alignment:.leading){ // Seçilen yer VStack
//                    Text("Selected Location".addLocalizableString(str: languageManager.language))
//                        .font(.system(size: 13))
//                        .foregroundStyle(Color("TextColor").opacity(0.5))
//                        .padding(.horizontal)
//                    
//                    HStack{
//                        VStack(alignment:.leading){
//                            Text(searchViewModel.selectedLocationFav?.mapItem.placemark.name ?? "Address None")
//                                .fontWeight(.medium)
//                            Text(searchViewModel.selectedLocationFav?.mapItem.placemark.title ?? "Address None")
//                                .font(.caption2)
//                            
//                            
//                            
//                        }
//                        
//                        
//                        
//                        
//                        Spacer()
//                        
//                        Image(systemName: "trash")
//                            .foregroundStyle(.red)
//                    }
//                    
//                    .padding(.top,5)
//                    
//                    .background(Color(.systemGray6))
//                    
//                    .padding(.horizontal)
//                }
//                
//            }
//        }
//        
//        
//    } //:VStack
    
    //MARK: - SELECTED PLACE LOCATION VIEW
//    private var SelectedPlaceLocationView:some View{
//        
//        VStack{
//            if let selectedPlace = mapSelectionPlace/*, selectedPlace.name != "Unknown Location"*/{
//                VStack(alignment:.leading){ /// Lokasyon VStack
//                    Text("Location".addLocalizableString(str: languageManager.language))
//                        .font(.system(size: 13))
//                        .foregroundStyle(Color("TextColor").opacity(0.5))
//                        .padding(.horizontal)
//                    
//                    HStack{
//                        Text("\(selectedPlace.placemark.coordinate.latitude)  \(selectedPlace.placemark.coordinate.longitude)")
//                        
//                        Spacer()
//                        
//                        Image(systemName: "trash")
//                            .foregroundStyle(.red)
//                    }
//                    .padding()
//                    
//                    .background(Color(.systemGray6))
//                    .cornerRadius(14)
//                    .padding(.horizontal)
//                    
//                }
//            }
//        }
//        
//    }
    
}



//ZStack {
//
//    Color("DarkBg2")
//        .ignoresSafeArea(.all)
//    VStack(alignment:.leading){
//
//        //MARK: - SEARCH BAR
//        FavoritesSearchRowView(searchResultsFav: $searchResultsFav, getDirections: $getDirections)
//            .ignoresSafeArea(.keyboard)
//            .ignoresSafeArea()
//
//        Divider()
//        /// Eğer search text boş değilse arama sonuçları gelsin
//        if !searchViewModel.searchText.isEmpty {
//
//            //MARK: - SEARCH RESULTS
//            SearchResultsView
//        }
//
//
//
//        if searchViewModel.searchText.isEmpty{
//
//            if searchViewModel.selectedLocationFav != nil{
//                VStack{
//                    //MARK: - FRONT SIDE
//                    if !isFlipped{
//                        ScrollView{
//                            VStack(alignment:.leading){
//                                //MARK: - SEÇİLEN YER
//                                SelectedPlaceView//:VStack
//
//                                Divider()
//
//                                Button(action: {
//                                    withAnimation {
//                                        searchViewModel.isFavLocationSelected.toggle()
//                                    }
//
//                                }) {
//                                    HStack {
//
//                                        Text("Add Selected Place")
//                                            .font(.headline)
//                                            .foregroundColor(.white)
//                                            .padding()
//                                            .background(Color.blue)
//                                            .cornerRadius(10)
//
//                                    }
//                                }
//                                .padding(.vertical)
//
//                            }
//
//                        }
//
//                    }else{
//
//                    }
//                }
//                .frame(maxHeight:  180)
//                .padding(.top,12)
//                .background(Color(.systemGray6))
//                .cornerRadius(20)
//                .padding()
//                .padding(.bottom)
//                .shadow(radius: 5)
//                .rotation3DEffect(
//                    .degrees(degrees),
//                    axis: (x: 0.0, y: -1.0, z: 0.0)
//                )
//
//            }else{
//                FavoritesPreviewView()
//
//            }
//            Spacer()
//
//        }
//
//
//
//    }//:VStack
//
//
//    ///SearchResultsFavdan döneni  local searchReuslstFav'a yolluyoruz
//    .onChange(of: searchViewModel.searchResultsFav, { _, newValue in
//        searchResultsFav = newValue
//    })
//
//}
//.ignoresSafeArea(.keyboard)
//.ignoresSafeArea()
