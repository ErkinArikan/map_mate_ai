import Foundation
import SwiftData

@Model
class LastSearchedPlaces {
    
    @Attribute(.unique) var id: UUID
    @Attribute var poiadi: String
    @Attribute var lat: Double
    @Attribute var lon: Double
    @Attribute var ilce: String
    @Attribute var il: String
    @Attribute var timestamp: Date  // Zaman bilgisi için yeni bir alan
    
    init(poiadi: String = "", lat: Double = 0.0, lon: Double = 0.0, ilce: String = "", il: String = "", timestamp: Date = Date()) {
        self.id = UUID()
        self.poiadi = poiadi
        self.lat = lat
        self.lon = lon
        self.ilce = ilce
        self.il = il
        self.timestamp = timestamp  // Aramanın yapıldığı zamanı kaydediyoruz
    }
}
