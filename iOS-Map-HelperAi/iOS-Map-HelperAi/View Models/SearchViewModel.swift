import Foundation
import MapKit
import SwiftUI
import SwiftData

@MainActor
class SearchViewModel: ObservableObject {
    @Published var isFavLocationSelected:Bool = false
    @Published var nearBySearchName: String = ""
    
    // MARK: - Search Text and Results
    @Published var searchText: String = ""
    @Published var searchResults: [SearchResultModel] = [] // Defaul arama sonuçları listesi
    
    @Published var searchResultsFav: [SearchResultModel] = []  // Favoriler için arama sonuçları bunun sonuç listesi ve tek seçilmesini istediğimizi onChange ile MainMapte birleştiriyoruz. Listenin birinci sırasına geleni selectedLocationFav ' a atıyoruz.
    
    @Published var selectedLocationFav: SearchResultModel?
    
    @Published var exSearchResul: [SearchResultModel] = []

    // MARK: - Camera Position
    @Published var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion())

    // MARK: - Location and Services
    var locationManager = LocationManagerDummy()
    
    var locationService = SearchManager(completer: .init())
    
   
    
    
    // MARK: - Search Completion Functions
    /// Completion'dan gelen değeri gerçek arama içine yerleştiren fonksiyon
    func didTapOnSearchCompletion(_ completion: SearchCompletionsModel) {
        print("Debug: didTapOnSearchCompletion çağrıldı. Title: \(completion.title), SubTitle: \(completion.subTitle)")

        Task {
            // Ağ çağrısını arka planda çalıştırın
            if let singleLocation = try? await locationService.search(with: "\(completion.title)").first {
                // UI güncellemelerini ana iş parçacığında yapın (zaten @MainActor ile korunuyor)
                self.searchResults = [singleLocation]
                print("Debug: searchResults güncellendi. Yeni sonuç: \(self.searchResults.count) adet.")
                
                // Kamera pozisyonunu güncelle
                if let lat = self.searchResults.first?.mapItem.placemark.coordinate.latitude,
                   let lon = self.searchResults.first?.mapItem.placemark.coordinate.longitude {
                    let newRegion = MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                    print("Debug: Kamera pozisyonu güncelleniyor. Latitude: \(lat), Longitude: \(lon)")
                    withAnimation(.spring()) {
                        self.cameraPosition = .region(newRegion)
                    }
                }
            } else {
                print("Debug: Arama başarısız. Sonuç bulunamadı.")
            }
        }
    }
    
    
    func didTapOnSearchCompletionWithDistrict(_ completion: SearchCompletionsModel) {
        print("Debug: didTapOnSearchCompletion çağrıldı. Title: \(completion.title), SubTitle: \(completion.subTitle)")

        Task {
            // İlçe bilgisini al
            let district = completion.subTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // İlçe bilgisini içeren sorgu oluştur
            let query = "\(completion.title), \(district)"
            
            print("Debug: Arama yapılacak sorgu: \(query)")
            
            if let singleLocation = try? await locationService.search(with: query).first {
                self.searchResults = [singleLocation]
                print("Debug: searchResults güncellendi. Yeni sonuç: \(self.searchResults.count) adet.")
                
                // Kamera pozisyonunu güncelle
                if let lat = self.searchResults.first?.mapItem.placemark.coordinate.latitude,
                   let lon = self.searchResults.first?.mapItem.placemark.coordinate.longitude {
                    let newRegion = MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                    print("Debug: Kamera pozisyonu güncelleniyor. Latitude: \(lat), Longitude: \(lon)")
                    withAnimation(.spring()) {
                        self.cameraPosition = .region(newRegion)
                    }
                }
            } else {
                print("Debug: Arama başarısız. Sonuç bulunamadı.")
            }
        }
    }

    // MARK: - Search Places With Location
    @MainActor
    func searchPlacesWithLoc(query: String, coordinate: CLLocationCoordinate2D? = nil) {
        Task {
            do {
                print("Debug: searchPlaces çağrıldı. Query: \(query), Coordinate: \(String(describing: coordinate))")
                let results = try await locationService.search(with: query, coordinate: coordinate)
                
                DispatchQueue.main.async {
                    self.searchResults = results
                    print("Debug: Arama sonuçları güncellendi. \(self.searchResults.count) sonuç bulundu.")
                    
                    // İlk sonuçtan kamera pozisyonunu güncelle
                  
                    if let lat = self.searchResults.first?.mapItem.placemark.coordinate.latitude,
                       let lon = self.searchResults.first?.mapItem.placemark.coordinate.longitude {
                        let newRegion = MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                        print("Debug: Kamera pozisyonu güncelleniyor. Latitude: \(lat), Longitude: \(lon)")
                        withAnimation(.spring()) {
                            self.cameraPosition = .region(newRegion)
                        }
                    }
                }
            } catch {
                print("Debug: Arama başarısız. Hata: \(error.localizedDescription)")
            }
        }
    }
    
    

    @MainActor
     func searchAddress(for coordinate: CLLocationCoordinate2D) {
         Task {
             do {
                 print("Debug: searchAddress çağrıldı. Coordinate: \(coordinate)")
                 let results = try await locationService.searchAddress(for: coordinate)
                 
                 DispatchQueue.main.async {
                     self.searchResults = results
                     print("Debug: Ters geocoding sonuçları güncellendi. \(self.searchResults.count) sonuç bulundu.")
                     
                     // İlk sonuçtan kamera pozisyonunu güncelle
                     let lat = coordinate.latitude
                     let lon = coordinate.longitude
                     let newRegion = MKCoordinateRegion(
                         center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                         span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                     )
                     print("Debug: Kamera pozisyonu güncelleniyor. Latitude: \(lat), Longitude: \(lon)")
                     withAnimation(.spring()) {
                         self.cameraPosition = .region(newRegion)
                     }
                 }
             } catch {
                 print("Debug: Ters geocoding başarısız. Hata: \(error.localizedDescription)")
             }
         }
     }
    
    

    
    /// Kamera pozisyonuna ihtiyaç duymayan favori arama tamamlama işlevi
    func didTapOnSearchCompletionFavorites(_ completion: SearchCompletionsModel) {
        Task {
            if let singleLocation = try? await locationService.search(with: "\(completion.title)").first {
                DispatchQueue.main.async {
                    self.searchResultsFav = [singleLocation]
                }
            }
        }
    }
    
    // MARK: - Local Search
    /// Belirli bir sorgu için yerel yerleri arar
    func searchForLocalPlaces(for query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        request.region = locationManager.region

        Task {
            let search = MKLocalSearch(request: request)
            let response = try? await search.start()
            
            // Response mapItems'ı SearchResultModel nesnelerine dönüştür
            if let mapItems = response?.mapItems {
                self.exSearchResul = mapItems.map { SearchResultModel(mapItem: $0) }
            } else {
                self.exSearchResul = []
            }
        }
    }
}


//    func didTapOnSearchCompletion(_ completion: SearchCompletionsModel) {
//        print("Debug: didTapOnSearchCompletion çağrıldı. Title: \(completion.title), SubTitle: \(completion.subTitle)")
//
//        Task {
//            if let singleLocation = try? await locationService.search(with: "\(completion.title)").first {
//                print("Debug: Arama başarılı. Bulunan ilk yer: \(singleLocation.mapItem.name ?? "Bilinmiyor")")
//                DispatchQueue.main.async {
//
//                    self.searchResults = [singleLocation]
//                    print("Debug: searchResults güncellendi. Yeni sonuç: \(self.searchResults.count) adet.")
//
//                    // Kamera pozisyonunu güncelle
//                    if let lat = self.searchResults.first?.mapItem.placemark.coordinate.latitude,
//                       let lon = self.searchResults.first?.mapItem.placemark.coordinate.longitude {
//                        let newRegion = MKCoordinateRegion(
//                            center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
//                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//                        )
//                        print("Debug: Kamera pozisyonu güncelleniyor. Latitude: \(lat), Longitude: \(lon)")
//                        withAnimation(.spring()) {
//                            self.cameraPosition = .region(newRegion)
//                        }
//                    }
//                }
//            } else {
//                print("Debug: Arama başarısız. Sonuç bulunamadı.")
//            }
//        }
//    }
//
    
//    func didTapOnSearchCompletion(_ completion: SearchCompletionsModel) {
//        print("Debug: didTapOnSearchCompletion çağrıldı. Title: \(completion.title), SubTitle: \(completion.subTitle)")
//
//        Task { [weak self] in
//            guard let self = self else { return }
//            if let singleLocation = try? await self.locationService.search(with: "\(completion.title)").first {
//                print("Debug: Arama başarılı. Bulunan ilk yer: \(singleLocation.mapItem.name ?? "Bilinmiyor")")
//                DispatchQueue.main.async { [weak self] in
//                    guard let self = self else { return }
//                    self.searchResults = [singleLocation]
//                    print("Debug: searchResults güncellendi. Yeni sonuç: \(self.searchResults.count) adet.")
//
//                    // Kamera pozisyonunu güncelle
//                    if let lat = self.searchResults.first?.mapItem.placemark.coordinate.latitude,
//                       let lon = self.searchResults.first?.mapItem.placemark.coordinate.longitude {
//                        let newRegion = MKCoordinateRegion(
//                            center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
//                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//                        )
//                        print("Debug: Kamera pozisyonu güncelleniyor. Latitude: \(lat), Longitude: \(lon)")
//                        withAnimation(.spring()) {
//                            self.cameraPosition = .region(newRegion)
//                        }
//                    }
//                }
//            } else {
//                print("Debug: Arama başarısız. Sonuç bulunamadı.")
//            }
//        }
//    }
