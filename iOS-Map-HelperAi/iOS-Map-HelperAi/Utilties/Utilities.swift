//
//  Utilities.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 20.09.2024.
//

import Foundation

//
//  Extensions.swift
//  IOS-Map-Basarsoft
//
//  Created by Erkin Arikan on 18.07.2024.
//

import Foundation
import MapKit
import SwiftUI


let nearbyPlaces = [
    NearbyPlace(name: "Hospital", searchFor: "Hastane", iconName: "cross.fill", iconColor: .red),
    NearbyPlace(name: "Cafe", searchFor: "Kafe", iconName: "cup.and.saucer.fill", iconColor: .brown),
    NearbyPlace(name: "Gas Station", searchFor: "Benzinlik", iconName: "fuelpump.fill", iconColor: .blue),
    NearbyPlace(name: "Hotel", searchFor: "Otel", iconName: "bed.double.fill", iconColor: .purple),
    NearbyPlace(name: "Pharmacy", searchFor: "Eczane", iconName: "pill.fill", iconColor: .pink),
    NearbyPlace(name: "Metro", searchFor: "Metro İstasyonu", iconName: "tram.fill", iconColor: .blue),
    NearbyPlace(name: "Mall", searchFor: "Alışveriş Merkezi", iconName: "tag.fill", iconColor: .pink),
    NearbyPlace(name: "Market", searchFor: "Market", iconName: "cart.fill", iconColor: .orange),
    NearbyPlace(name: "Charge", searchFor: "Şarj İstasyonu", iconName: "bolt.fill", iconColor: .green),
    NearbyPlace(name: "ATM", searchFor: "ATM", iconName: "creditcard.fill", iconColor: .gray)
    ]



/// Login ve register sayfalarında kullanıldı
struct CustomShape: Shape {
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft,.topRight], cornerRadii: CGSize(width: 35, height: 35))
        return Path(path.cgPath)
    }
}
/// Login ve register sayfalarında kullanıldı geriye giderken lazım
struct BackSwipeEnabler: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        
        // Kullanıcı etkileşimleri aktif
        controller.view.isUserInteractionEnabled = true
        
        // navigationController'a erişim
        DispatchQueue.main.async {
            if let navigationController = controller.navigationController {
                navigationController.interactivePopGestureRecognizer?.delegate = context.coordinator
            }
        }
        
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
    }
}





extension Encodable {
    func asDictionary() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self) else {
            return [:]
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            return json ?? [:]
        } catch {
            return [:]
        }
    }
}

extension Color {
    static let lightShadow = Color(red: 255 / 255, green: 255 / 255, blue: 255 / 255)
    static let darkShadow = Color(red: 163 / 255, green: 177 / 255, blue: 198 / 255)
    static let background = Color(red: 224 / 255, green: 229 / 255, blue: 236 / 255)
    static let neumorphictextColor = Color(red: 132 / 255, green: 132 / 255, blue: 132 / 255)
}


//MARK: - POLY LINE STROKE STYLE
let strokeStyle = StrokeStyle(
    lineWidth: 2,
    lineCap: .round,
    lineJoin: .round,
    dash: [5,5]
)

//MARK: - ACTIVE SHEET ENUM
enum ActiveSheet: Identifiable {
    case search, details,direction,favorites,mapStyle,chat,startedNavigation,pharmacyView,empty
    
    var id: Int {
        hashValue
    }
}

//MARK: - VIBRATION
let hapticImpact = UIImpactFeedbackGenerator(style: .medium)


//MARK: - HIDE KEYBOARD
func hideKeyboard() {
     // Klavyeyi kapatmak için
     UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
 }


extension String{
    func addLocalizableString(str:String) -> String{
        let path = Bundle.main.path(forResource: str, ofType: "lproj")
        let bundle = Bundle(path: path!)
      return  NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
}


   



//MARK: - HEX COLOR
extension Color {
    static func hex(_ hex: String) -> Color {
        var cleanedHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        if cleanedHex.hasPrefix("#") {
            cleanedHex.remove(at: cleanedHex.startIndex)
        }
        var rgb: UInt64 = 0
        Scanner(string: cleanedHex).scanHexInt64(&rgb)
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        return Color(red: red, green: green, blue: blue)
    }
}

//MARK: - COORDINATE
extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}




//MARK: - NEARBY SEARCH ITEMS
//MARK: - NEARBY SEARCH ITEMS
enum PlaceType: String {
    case hospital = "Hastane"
    case shoppingMall = "Alışveriş Merkezi"
    case market = "Market"
    case metroStation = "Metro İstasyonu"
    case chargingStation = "Şarj İstasyonu"
    case pharmacy = "Eczane"
    case atm = "ATM"
    case hotel = "Otel"
    case gasStation = "Benzinlik"
    case coffee = "Kafe"
    
    var icon: String {
        switch self {
        case .hospital:
            return "cross.circle.fill"
        case .shoppingMall:
            return "tag.fill"
        case .market:
            return "cart.fill"
        case .metroStation:
            return "tram.fill"
        case .chargingStation:
            return "bolt.fill"
        case .pharmacy:
            return "pill.circle.fill"
        case .atm:
            return "creditcard.circle.fill"
        case .hotel:
            return "bed.double.circle.fill"
        case .gasStation:
            return "fuelpump.circle"
        case .coffee:
            return "cup.and.saucer.fill"
        }
    
    }
    
    var color: Color {
        switch self {
        case .hospital:
            return .red
        case .shoppingMall:
            return .pink
        case .market:
            return .orange
        case .metroStation:
            return .blue
        case .chargingStation:
            return .green
        case .pharmacy:
            return .pink
        case .atm:
            return .gray
        case .hotel:
            return .purple
        case .gasStation:
            return .blue
        case .coffee:
            return .brown
        }
    
    }
}



//MARK: - TAB
enum Tab: Int, Identifiable, CaseIterable, Comparable {
    static func < (lhs: Tab, rhs: Tab) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    case  chat,search,pharmacy,settings
    
    internal var id: Int { rawValue }
    
    var icon: String {
        switch self {
       
        case .chat:
            return "lasso.badge.sparkles"
        case .search:
            return "magnifyingglass"
        
        case .settings:
            return "gear"
        
        case .pharmacy:
            return "pill.fill"
        }
       

        
    }
    
   
    
    var color: Color {
        switch self {
        case .search:
            return .indigo
        case .settings:
            return .orange
        case .chat:
            return .teal
        case .pharmacy:
            return .teal
        }
    }
}

let backgroundColor = Color.init(white: 0.92)





//MARK: - DENEME UTILITIES

struct TextFieldGrayBackgroundColor: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(.gray.opacity(0.1))
            .cornerRadius(8)
            .foregroundColor(.primary)
    }
}







///ÖNEMLİ VİEW BİLGİSİ İÇERİRİ
///
///
///
//if searchViewModel.searchText.isEmpty {
////                    Form {
////                        Section {
////                            HStack{
////                                Text(mapSelectionPlace?.name ?? "Address yok")
////                                Spacer()
////
////                                if mapSelectionPlace?.name != "Unknown Location" {
////                                    Image(systemName: "trash")
////                                        .foregroundStyle(.red)
////                                }
////
////                            }
////
////                        } header: {
////                            Text("Seçieln Yer")
////                        }
////
////                    }
//////                    .scrollContentBackground(.hidden)// Bunun sayesinde form bg gidiyor
////                    .tint(.pink)
////                    .background(Color.clear)
////                    .frame(maxHeight: 300)
////                    .cornerRadius(20)
////                }
////
