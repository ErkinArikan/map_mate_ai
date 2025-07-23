//
//  MapView.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 20.09.2024.
//

import SwiftUI
import MapKit
import SwiftData


    


/// YAPARKEN DİKKAT ETTİĞİM & ÖĞRENDİĞİM ŞEYLER

/// Bu sayfaya preview eklersen açılırken yavaşlıyor. Unutma açılırken yavaşlamasını engellemek için maxHeight kullanman lazım.
//MARK: - MAP VIEW

struct MapView: View {
    //MARK: - VARIABLES
    @EnvironmentObject var locationManager: LocationManagerDummy
    @EnvironmentObject var vm: MapViewModel
    @EnvironmentObject var searchViewModel: SearchViewModel
    @EnvironmentObject var routeVm: RouteViewModel
    @EnvironmentObject var uiStateVm:UIStateViewModel
    @State private var isPolylineShow: Bool = false
    @Namespace private var favoritesMap
    @Environment(\.modelContext) var context
    @State private var selection: SearchResultModel?

    
    
    //MARK: - BODY
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            //MARK: - MAPDISPLAY VIEW
            MapDisplayView(isPolylineShow: $isPolylineShow, selection: $selection, shouldCenterMapOnUser: $uiStateVm.shouldCenterMapOnUser)
                .environmentObject(vm)
                .environmentObject(searchViewModel)
                .environmentObject(routeVm)
                .environmentObject(uiStateVm)
            

        }
        

        .mapScope(favoritesMap)
        .onAppear {
            routeVm.cameraPosition = MapCameraPosition.region(vm.cameraRegion.region)
        }

        
        ///Selected Location değiştiğinde bunu kaydet.
        .onChange(of: routeVm.selectedLocation, { oldValue, newValue in
            // Eğer newValue nil ise kaydetme işlemi yapılmasın
            guard let newValue = newValue else {
                print("selectedLocation nil, recent search kaydedilmedi.")
                return
            }

            uiStateVm.isSheetPresented = false
            routeVm.updateLocationDetails(newValue)
            saveToRecentSearches(from: newValue)
        })

        .onChange(of: uiStateVm.getDirections, { oldValue, newValue in
            isPolylineShow = newValue
            if newValue {
          
                routeVm.fetchCarRoute()
                routeVm.fetchPedestrianRoute()
                

            }
        })
//        onChange(of: routeVm.cameraPosition, { old, new in
//            print("new camera :\(new))
//            print("\(old)")
//        })
        
        /// Search  modeldeki search result'ı route vm.dekine eşitlemişiz bunu değiştiricez anlamsız. 
//        .onChange(of: searchViewModel.searchResults, { oldValue, newValue in
//            routeVm.searchResults = newValue
//        })
        
        
        .onChange(of: routeVm.selectedLocation, { oldValue, newValue in
            print("selected location : \(String(describing: newValue?.mapItem.placemark.name))")
        })
        .onChange(of: searchViewModel.searchResults, { oldValue, newValue in
            
            /// Burada search Resultslar içinde sadece bir tane ise her zaman 1 tane oluyor seçilen bunu selected Location'a eşitliyoruz
            ///  Search Results İçindeki sonuçlardan ilkini first Reuslt'a eşitliyoruz.
            if let firstResult = searchViewModel.searchResults.first, searchViewModel.searchResults.count == 1 {
                routeVm.selectedLocation = firstResult
            }
        })
        ///favorilerdeki selected location elimizde şimdi
        ///Search Results Favoriler listesi değişirse onun birinci indexindekini selected LocationFav ' a ekle.
        .onChange(of: searchViewModel.searchResultsFav) { oldValue, newValue in
            if let firstResult = searchViewModel.searchResultsFav.first, searchViewModel.searchResultsFav.count == 1 {
                searchViewModel.selectedLocationFav = firstResult
                print("Favorite location selected : \(firstResult)")
            }
        }
        ///Selected Location değiştiğinde bunu kaydet.
        .onChange(of: searchViewModel.selectedLocationFav, { oldValue, newValue in
            uiStateVm.isSheetPresented = searchViewModel.selectedLocationFav == nil
            routeVm.updateLocationDetails(newValue)
            
            /// Save to Fav DB olucak burası
            #warning("Burası save to Fav DB olucak.")
            
//            saveToFavoritesPlace(from: newValue)
            
        })

    } //:BODY
    
    //MARK: - SAVE TO RECENT DB
    func saveToRecentSearches(from result: SearchResultModel?) {
        let recentSearchItem = LastSearchedPlaces(
            poiadi: result?.mapItem.name ?? "poiadi yok",
            lat: result?.mapItem.placemark.coordinate.latitude ?? 0.0,
            lon: result?.mapItem.placemark.coordinate.longitude ?? 0.0,
            ilce: result?.mapItem.placemark.locality ?? "locality yok",
            il: result?.mapItem.placemark.subtitle ?? "subtitle yok",
            timestamp: Date() // Zamanı ekliyoruz
        )

        do {
            // 1. Yeni aramayı veritabanına ekleyin
            try context.insert(recentSearchItem)
            print("Son arama kaydedildi: \(recentSearchItem.poiadi)")

            // 2. Şu anda veritabanındaki tüm aramaları çekin ve zamana göre sıraya dizin
            let fetchRequest = FetchDescriptor<LastSearchedPlaces>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
            let allSearches = try context.fetch(fetchRequest)

            // 3. Eğer kayıt sayısı 8'den fazla ise, en eski olanları silin
            if allSearches.count > 8 {
                let extraItems = allSearches.suffix(from: 8) // İlk 8 kaydı koru, geri kalanını al
                for item in extraItems {
                    context.delete(item)
                    print("Silinen eski arama: \(item.poiadi)")
                }
            }

        } catch {
            print("Son aramayı kaydederken hata: \(error.localizedDescription)")
        }
    } //:Func

    
    func saveToStarredPlace(from result: SearchResultModel?, context: ModelContext) {
        guard let result = result else {
            print("Error: No search result provided.")
            return
        }

        let starredLocation = StarredPlacesDB(
            poiadi: result.mapItem.name ?? "poiadi yok",
            lat: result.mapItem.placemark.coordinate.latitude,
            lon: result.mapItem.placemark.coordinate.longitude,
            ilce: result.mapItem.placemark.locality ?? "locality yok",
            il: result.mapItem.placemark.subtitle ?? "subtitle yok",
            timestamp: Date()
        )

        do {
            // Insert the new favorite location into the database
            try context.insert(starredLocation)
            print("Favorite place saved: \(starredLocation.poiadi)")
            print("Saved Favori place lat:\(starredLocation.lat)  lon:\(starredLocation.lon)")

            // Fetch all saved favorite places sorted by timestamp in descending order
            let fetchRequest = FetchDescriptor<StarredPlacesDB>(
                sortBy: [SortDescriptor(\StarredPlacesDB.timestamp, order: .reverse)]
            )

            let allStarred = try context.fetch(fetchRequest)
            print("Total saved favorites: \(allStarred.count)")

        } catch {
            print("Error saving favorite place: \(error.localizedDescription)")
        }
    }


}






//MARK: - Preview
#Preview {
    MapView()
        .environmentObject(LocationManagerDummy())
        .environmentObject(MapViewModel(locationManager: LocationManagerDummy()))
        .environmentObject(RouteViewModel( locationManager: LocationManagerDummy()))
        .environmentObject(SearchViewModel())
//        .environmentObject(MapStyleConfig())
}



//MARK: - EXTENSION


 
struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(Color.green)
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding(.bottom, 20)
    }
}
