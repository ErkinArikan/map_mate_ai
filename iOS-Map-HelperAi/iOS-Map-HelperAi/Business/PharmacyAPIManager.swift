import Foundation
import Firebase

class PharmacyApiManager {
    // API çağrısını gerçekleştiren metod
//    func fetchDutyPharmacies(il: String, ilce: String, completion: @escaping (Result<[Pharmacy], Error>) -> Void) {
//        // API URL'si
//        guard let url = URL(string: "https://api.collectapi.com/health/dutyPharmacy?il=\(il)&ilce=\(ilce)") else {
//            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
//            return
//        }
//        
//        // HTTP Başlıkları
//        let headers = [
//            "content-type": "application/json",
//            "authorization": "apikey 0Ijjnh8wN9wtbXEO3lItC3:02jUJcYg18Do8WDl3GSdxc" // API anahtarınızı ekleyin
//        ]
//        
//        // Request oluşturma
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.allHTTPHeaderFields = headers
//        
//        // URLSession ile isteği gönder
//        let session = URLSession.shared
//        let task = session.dataTask(with: request) { data, response, error in
//            if let error = error {
//                completion(.failure(error))
//            } else if let data = data {
//                do {
//                    // JSON verisini modele dönüştür
//                    let decodedResponse = try JSONDecoder().decode(PharmacyResponse.self, from: data)
//                    
//                    // Başarı durumuna göre tamamlayıcıyı çağır
//                    if decodedResponse.success {
//                        completion(.success(decodedResponse.result))
//                    } else {
//                        completion(.failure(NSError(domain: "API Error", code: 500, userInfo: nil)))
//                    }
//                } catch {
//                    completion(.failure(error))
//                }
//            }
//            print(String(data: data ?? Data() , encoding: .utf8) ?? "No Data")
//        }
//        
//        
//        task.resume()
//    }
    
  
    
    func fetchDutyPharmacies(il: String, ilce: String, completion: @escaping (Result<[Pharmacy], Error>) -> Void) {
        // API URL'si
        guard let url = URL(string: "https://api.collectapi.com/health/dutyPharmacy?il=\(il)&ilce=\(ilce)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        
        // HTTP Başlıkları
        let headers = [
            "content-type": "application/json",
            "authorization": "apikey 0Ijjnh8wN9wtbXEO3lItC3:02jUJcYg18Do8WDl3GSdxc" // API anahtarınızı ekleyin
        ]
        
        // Request oluşturma
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        // URLSession ile isteği gönder
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                // Ham yanıtı bastır
                print("Ham Yanıt:")
                print(String(data: data, encoding: .utf8) ?? "No Data")
                
                do {
                    // JSON verisini modele dönüştür
                    let decodedResponse = try JSONDecoder().decode(PharmacyResponse.self, from: data)
                    
                    // Başarı durumuna göre tamamlayıcıyı çağır
                    if decodedResponse.success {
                        completion(.success(decodedResponse.result))
                    } else {
                        completion(.failure(NSError(domain: "API Error", code: 500, userInfo: nil)))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }
        
        
        
        task.resume()
    }
    
    private let firestore = Firestore.firestore()

    func insertPharmaciesRecord(il: String, ilce: String, completion: @escaping (Result<[Pharmacy], Error>) -> Void) {
        let collectionRef = firestore.collection("pharmacies")
        
        // Firestore'dan mevcut verileri kontrol et
        collectionRef
            .whereField("city", isEqualTo: il)
           /* .whereField("dist", isEqualTo: ilce)*/ // İlçeye göre sorgulama
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Firestore'dan veri alınırken hata oluştu: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                if let documents = snapshot?.documents, !documents.isEmpty {
                    // Firestore'dan mevcut veriler alınır
                    let pharmacies: [Pharmacy] = documents.compactMap { document in
                        try? document.data(as: Pharmacy.self)
                    }
                    print("Firestore'dan \(pharmacies.count) adet eczane yüklendi.")
                    completion(.success(pharmacies))
                } else {
//                     Firestore'da veri yoksa API çağrısı yapılır
                    self.fetchDutyPharmacies(il: il, ilce: ilce) { result in
                        switch result {
                        case .success(let pharmacies):
                            // API'den alınan verileri Firestore'a kaydet
                            for pharmacy in pharmacies {
                                do {
                                    // Veriye `city` alanını ekliyoruz
                                    var pharmacyData = try Firestore.Encoder().encode(pharmacy)
                                    pharmacyData["city"] = il // `city` alanını ekle

                                    try collectionRef.document(pharmacy.name).setData(pharmacyData) // Firestore'a kaydet
                                } catch {
                                    print("Firestore'a veri yazılırken hata oluştu: \(error.localizedDescription)")
                                }
                            }
                            print("API'den alınan eczaneler Firestore'a kaydedildi.")
                            completion(.success(pharmacies))
                        case .failure(let error):
                            print("API'den veri alınırken hata oluştu: \(error.localizedDescription)")
                            completion(.failure(error))
                        }
                    }
                }
            }
    }


        // Dummy API çağrısı
        private func fetchDutyPharmaciesDummy(il: String, ilce: String, completion: @escaping (Result<[Pharmacy], Error>) -> Void) {
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                let samplePharmacies = [
                    Pharmacy(name: "Eczane 1", dist: ilce, address: "Adres 1", phone: "123456789", loc: "40.1234,29.1234"),
                    Pharmacy(name: "Eczane 2", dist: ilce, address: "Adres 2", phone: "987654321", loc: "40.5678,29.5678")
                ]
                completion(.success(samplePharmacies))
            }
        }
    
    
    
//    func fetchAndStorePharmacies(il: String, ilce: String, completion: @escaping (Result<[Pharmacy], Error>) -> Void) {
//        let firestore = Firestore.firestore()
//        let collectionRef = firestore.collection("pharmacies")
//        
//        // İlk olarak Firestore'dan verileri kontrol et
//        collectionRef.whereField("city", isEqualTo: il).whereField("district", isEqualTo: ilce).getDocuments { snapshot, error in
//            if let error = error {
//                print("Firestore'dan veri alınırken hata oluştu: \(error)")
//                completion(.failure(error))
//                return
//            }
//            
//            if let documents = snapshot?.documents, !documents.isEmpty {
//                // Firestore'da veri mevcut, sonuçları döndür
//                let pharmacies: [Pharmacy] = documents.compactMap { document in
//                    try? document.data(as: Pharmacy.self) // Codable kullanarak deserialize
//                }
//                completion(.success(pharmacies))
//            } else {
//                // Firestore'da veri yok, API çağrısı yap
//                self.fetchDutyPharmacies(il: il, ilce: ilce) { result in
//                    switch result {
//                    case .success(let pharmacies):
//                        // Firestore'a yaz
//                        for pharmacy in pharmacies {
//                            do {
//                                try collectionRef.document(pharmacy.name).setData(from: pharmacy)
//                            } catch {
//                                print("Firestore'a veri yazılırken hata oluştu: \(error)")
//                            }
//                        }
//                        completion(.success(pharmacies))
//                    case .failure(let error):
//                        completion(.failure(error))
//                    }
//                }
//            }
//        }
//    }
//
//    
//    

}
