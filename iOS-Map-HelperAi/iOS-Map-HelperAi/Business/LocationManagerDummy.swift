import MapKit
import CoreLocation
import SwiftUI

// LocationManagerDummy sınıfı, cihazın konumunu takip etmek için kullanılan bir observable object'tir.
// CLLocationManager ile entegre olarak cihazın anlık konumunu alır ve SwiftUI arayüzünü günceller.
final class LocationManagerDummy: NSObject, ObservableObject {
    
    // Closure ile güncellemeleri dışarıya iletir
        var onLocationUpdate: ((CLLocationCoordinate2D?) -> Void)?
    
    // Cihazın konumunu almak için kullanılan CLLocationManager örneği.
    private let locationManager = CLLocationManager()
    
    // Uygulama başladığında varsayılan olarak Apple'ın merkezi olan Cupertino'yu merkez alacak bir harita bölgesi.
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.334_900, longitude: -122.009_020),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    
    // Uygulama yüklenirken konumun yüklendiğini izlemek için kullanılır.
    @Published var isLoading = true // Yüklenme durumu
    
    // Konum doğruluğunu artırmak için güncelleme yapılıp yapılmadığını takip eder.
    private var isRefiningAccuracy = false // Doğruluk artırılıyor mu takip durumu
    
    // Cihazın şu anki konumunu saklar.
    @Published var currentLocation: CLLocationCoordinate2D? // Geçerli konum
    
    private var timer: Timer? /// OK: Belirli aralıklarla konum güncellemeleri için Timer eklendi.
    
    // Lokasyon başlatılırken ilk ayarlamalar yapılır.
    override init() {
        super.init()
        self.locationManager.delegate = self
        // Konum doğruluğu başlangıçta düşük olarak ayarlanır. (Kilometre düzeyinde doğruluk)
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Uygulama ilk başlatıldığında konum izni isteği yapılır.
        self.setup()
        
        /// Burayı Ekledim ********
        self.getUserLocation()
    }
    
    // Kullanıcıdan konum izni istemek ve mevcut izni kontrol etmek için kullanılan fonksiyon.
    private func setup() {
       // Konum izni durumuna göre yapılacak işlemleri belirler.
        switch locationManager.authorizationStatus {
          
        case .authorizedWhenInUse:
            // Eğer konum izni verilmişse, hemen konum isteği başlatılır.
            locationManager.requestLocation()
            // Sürekli konum güncellemelerini başlatır.
            startTimedLocationUpdates() /// OK: Sürekli güncelleme yerine Timer'ı başlatan yeni fonksiyon çağrıldı.
            
        case .notDetermined:
           // Eğer konum izni henüz sorulmamışsa, izin istemek için kullanıcıya bir istek gönderilir.
            locationManager.requestWhenInUseAuthorization()
            
        default:
            break
        }
    }
    
    func getUserLocation(){
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    // Konum doğruluğunu artırmak için kullanılan fonksiyon.
    // İlk düşük doğrulukta konum alındıktan sonra, daha yüksek doğrulukla konum alımı için güncelleme başlatılır.
    private func refineAccuracy() {
        isRefiningAccuracy = true
        // Doğruluğu artırmak için daha yüksek doğruluk ayarlanır.
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // Tekrar konum isteği gönderilir.
        locationManager.requestLocation()
    }
    
    // Cihazda en son bilinen bir konum varsa, bu konumu hemen gösterir ve region değerini günceller.
    func showLastKnownLocation() {
        if let lastLocation = locationManager.location {
            // Haritanın merkezi en son bilinen konum olacak şekilde ayarlanır.
            region = MKCoordinateRegion(
                center: lastLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            // Geçerli konum kaydedilir.
            currentLocation = lastLocation.coordinate
        }
    }
    
    // Belirli aralıklarla konum güncellemesini başlatmak için kullanılan fonksiyon. /// OK: Yeni fonksiyon eklendi.
    func startTimedLocationUpdates() {
        timer?.invalidate() // Önceki timer'ı durdur
        timer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { [weak self] _ in
            self?.locationManager.requestLocation() // Konumu iste
        }
        timer?.fire() // Timer başlatıldığında hemen çalıştır
    }

    // Sürekli güncellemeleri durdurmak için kullanılan fonksiyon. /// OK: Timer'ı durdurma fonksiyonu eklendi.
    func stopTimedLocationUpdates() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        stopTimedLocationUpdates() // Sınıf silinirken Timer'ı durdur
    }
}

// CLLocationManagerDelegate protokolünü implement eden uzantı (extension).
// Bu sayede konum güncellemeleri ve izin değişikliklerine yanıt verebiliriz.
extension LocationManagerDummy: CLLocationManagerDelegate {
    
    // Kullanıcı konum izni durumunu değiştirdiğinde çağrılan fonksiyon.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Eğer konum izni verilmişse
        guard manager.authorizationStatus == .authorizedWhenInUse else { return }
        // En son bilinen konumu hemen gösterir.
        showLastKnownLocation()
        // Belirli aralıklarla güncellemeleri başlatır. /// OK: Sürekli güncellemeler yerine belirli aralıklarla konum alınması eklendi.
        startTimedLocationUpdates()
    }
    
    // Konum güncellemesi başarısız olduğunda çağrılan fonksiyon.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Hata mesajı yazdırılır ve yüklenme durumu false yapılır.
        print("Bir hata oluştu: \(error)")
        isLoading = false
    }
    
    // Konum başarıyla güncellendiğinde çağrılan fonksiyon.
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.last {
//            // Konum güncellendikçe harita merkezi yeni konuma göre ayarlanır.
//            region = MKCoordinateRegion(
//                center: location.coordinate,
//                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//            )
//            // Geçerli konum kaydedilir.
//            currentLocation = location.coordinate
//            onLocationUpdate?(location.coordinate) // Closure ile yeni konumu ilet
//            
//            ///Burayı ekledimmm *******
////            print("Lat: \(location.coordinate.latitude) \nLong : \(location.coordinate.longitude)")
//            
//            // Eğer doğruluk artırılıyorsa
//            if isRefiningAccuracy {
//                isLoading = false
//            } else {
//                // İlk güncellemeden sonra doğruluğu artırmak için refineAccuracy fonksiyonu çağrılır.
//                refineAccuracy()
//            }
//        }
//    }
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//        if let lastLocation = currentLocation {
//            let distanceMoved = location.distance(from: CLLocation(latitude: lastLocation.latitude, longitude: lastLocation.longitude))
//            if distanceMoved < 10 { // Eğer hareket 10 metreden azsa güncellemeyi atla
//                return
//            }
//        }
//        currentLocation = location.coordinate
//        onLocationUpdate?(location.coordinate)
//    }
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//
//        // Kullanıcının hareket ettiği mesafeyi kontrol edin
//        if let lastLocation = currentLocation {
//            let distanceMoved = location.distance(from: CLLocation(latitude: lastLocation.latitude, longitude: lastLocation.longitude))
//            if distanceMoved < 10 { // Eğer hareket 10 metreden azsa güncellemeyi atla
//                return
//            }
//        }
//
//        // Geçerli konumu güncelle ve closure'ı çağır
//        currentLocation = location.coordinate
//        onLocationUpdate?(location.coordinate)
//
//        // Harita bölgesini güncelle
//        region = MKCoordinateRegion(
//            center: location.coordinate,
//            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//        )
//    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        // Hareket edilen mesafeyi kontrol et
        if let lastLocation = currentLocation {
            let distanceMoved = location.distance(from: CLLocation(latitude: lastLocation.latitude, longitude: lastLocation.longitude))
            if distanceMoved < 10 { return }
        }

        // Konum güncellemesi
        currentLocation = location.coordinate
        onLocationUpdate?(location.coordinate)

        // Harita bölgesini animasyonlu şekilde güncelle
        DispatchQueue.main.async {
            withAnimation {
                self.region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            }
        }
    }
}
