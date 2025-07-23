//
//  FavoritesViewModel.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 3.02.2025.
//

import Foundation
import FirebaseAuth
import Firebase

enum FavoritesErrors{
    case success,error,empty
}

class FavoritesViewModel:ObservableObject{
    @Published  var favorites: [[String: Any]] = []
    @Published var isShowFavToast:Bool = false
    @Published var favoritesToastString:String = ""
    @Published var favEnum:FavoritesErrors = .empty

    func saveFavoritePlaceToUser(from result: SearchResultModel?) {
        guard let result = result else {
            print("Error: No search result provided.")
            return
        }

        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: Kullanıcı oturum açmamış.")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)

        // 📌 Favori adresin tüm bilgilerini bir dictionary olarak oluşturuyoruz
        let favoriteData: [String: Any] = [
            "poiadi": result.mapItem.name ?? "poiadi yok",
            "lat": result.mapItem.placemark.coordinate.latitude,
            "lon": result.mapItem.placemark.coordinate.longitude,
            "ilce": result.mapItem.placemark.locality ?? "locality yok",
            "il": result.mapItem.placemark.administrativeArea ?? "subtitle yok",
            "timestamp": Timestamp(date: Date())
        ]

        // 📌 Kullanıcının mevcut favorilerini kontrol et ve duplicate eklemeyi engelle
        userRef.getDocument { document, error in
            if let error = error {
                self.showToastMessage(type: .error, message: "Something went wrong! Please try again later.")
                print("Firestore favorileri kontrol etme hatası: \(error.localizedDescription)")
                return
            }

            var currentFavorites: [[String: Any]] = []
            if let document = document, document.exists {
                currentFavorites = document.data()?["favoritesPlaces"] as? [[String: Any]] ?? []
            }

            // 📌 Eğer favorilerde zaten aynı POI adı olan bir yer varsa ekleme
            if currentFavorites.contains(where: { $0["poiadi"] as? String == favoriteData["poiadi"] as? String }) {
                self.showToastMessage(type: .error, message: "Already added to favorites.")
                print("Bu adres zaten favorilerde kayıtlı: \(favoriteData["poiadi"]!)")
                return
            }

            // 📌 Yeni favori yerini Firestore'daki `favoritesPlaces` listesine ekle
            userRef.updateData([
                "favoritesPlaces": FieldValue.arrayUnion([favoriteData])
            ]) { error in
                if let error = error {
                    print("Firestore favori ekleme hatası: \(error.localizedDescription)")
                    self.showToastMessage(type: .error, message: "Something went wrong! Please try again later.")
                } else {
                    self.showToastMessage(type: .success, message: "Added to favorites!")
                    print("Adres favorilere başarıyla eklendi: \(favoriteData["poiadi"]!)")
                }
            }
        }
    }

    
    
    
    // 📌 **Yeni Toast Gösterme Fonksiyonu** (Gecikmeli)
    private func showToastMessage(type: FavoritesErrors, message: String) {
        DispatchQueue.main.async {
            self.isShowFavToast = false  // Önce Toast'ı kapat, ani değişim olmasın
            self.favEnum = .empty
           // 200ms bekle
                self.favEnum = type
                self.favoritesToastString = message
                self.isShowFavToast = true

                // 3 saniye sonra Toast'ı kapat
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.isShowFavToast = false
                    self.favoritesToastString = ""
                    self.favEnum = .empty
                }
            
        }
    }


    
    
    func fetchUserFavorites() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("🔥 HATA: Kullanıcı oturum açmamış.")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)

        print("📡 Firestore'dan favori verileri çekiliyor...")

        userRef.getDocument { document, error in
            if let error = error {
                print("❌ Firestore favorileri çekme hatası: \(error.localizedDescription)")
                return
            }

            if let document = document, document.exists {
                let rawData = document.data()?["favoritesPlaces"] as? [Any] ?? []
                print("🔥 Firestore'dan gelen RAW favoritesPlaces: \(rawData)")

                // 📌 Hatalı formatta olan stringleri filtrele ve yalnızca dictionary formatında olanları al
                let filteredData = rawData.compactMap { place -> [String: Any]? in
                    guard let placeDict = place as? [String: Any] else { return nil }
                    return placeDict
                }

                DispatchQueue.main.async {
                    self.favorites = filteredData
                    print("🎯 Güncellenmiş Favoriler (Filtrelenmiş): \(self.favorites)")
                }
            } else {
                print("⚠️ Firestore belgesi bulunamadı.")
            }
        }
    }

    func deleteFavorite(place: [String: Any]) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: Kullanıcı oturum açmamış.")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)

        userRef.updateData([
            "favoritesPlaces": FieldValue.arrayRemove([place])
        ]) { error in
            if let error = error {
                print("Firestore favori silme hatası: \(error.localizedDescription)")
            } else {
                print("Favori başarıyla silindi: \(place["poiadi"] ?? "Unknown")")
                self.fetchUserFavorites()
            }
        }
    }
    
    func isFavorite(place: SearchResultModel?) -> Bool {
            guard let place = place else { return false }
            return favorites.contains { fav in
                guard let favLat = fav["lat"] as? Double,
                      let favLon = fav["lon"] as? Double else { return false }
                return favLat == place.mapItem.placemark.coordinate.latitude &&
                       favLon == place.mapItem.placemark.coordinate.longitude
            }
        }
}
