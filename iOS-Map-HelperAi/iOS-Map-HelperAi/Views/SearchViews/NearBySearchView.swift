//
//  NearbySearchView.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 23.09.2024.
//

import SwiftUI
import MapKit



enum NearByPlaces: String {
    case hospital
    case hotel 
    case gasstation
    case otel
    case pharmacy
 
}


struct NearBySearchView: View {
    @EnvironmentObject var languageManager:LanguageManager
    @EnvironmentObject var routeVm:RouteViewModel
    @EnvironmentObject var vm:MapViewModel
    @EnvironmentObject var searchViewModel:SearchViewModel
    @EnvironmentObject var locationManager:LocationManagerDummy
    @EnvironmentObject var uiStateVm:UIStateViewModel
    

    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        VStack(alignment:.leading){
            Text("Nearby places".addLocalizableString(str: languageManager.language))
                .font(.system(size: 13))
                .foregroundStyle(colorScheme == .light ? Color.hex("0C7B93"): Color.hex("F2F2F7"))
                .padding(.horizontal,20)
            Divider()
                .overlay(content: {
                    Color.hex("0C7B93")
                })
            List{
                ForEach(nearbyPlaces) { place in
                    Button {
                        withAnimation {
                            
                            updateCameraAndSearch(for: place.searchFor)
                            hapticImpact.impactOccurred()
                            uiStateVm.showDestinationDetailsView = true
                            
                        }
                   
                    } label: {
                        HStack {
                            NearByRowIconRowView(iconName: place.iconName, iconColor: place.iconColor)
                            Text(place.name.addLocalizableString(str: languageManager.language))
                                .font(.system(size: 18))
                                .fontWeight(.medium)
                                .foregroundStyle(colorScheme == .light ? Color.hex("0C7B93"): Color("TextColor"))
                        }
                    }
              
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .scrollIndicators(.hidden)
            .listStyle(.plain)
            .scrollDismissesKeyboard(.immediately)
        }
        .frame(maxHeight: 450)
        .padding(.top,10)
    }
    func extractAddressesAndPlaceNames(from text: String?) -> [(placeName: String, address: String)] {
        guard let text = text else { return [] }
        
        // Düzenli ifade: **[Place Name](address:Address)**
        let pattern = #"(?<=\*\*\[)(.*?)(?=\]\(address:)(.*?)(?=\))"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        
        let matches = regex.matches(in: text, range: NSRange(location: 0, length: text.utf16.count))
        
        // Eşleşmeleri ayıklayıp place name ve adresleri döndür
        return matches.compactMap { match in
            guard let placeNameRange = Range(match.range(at: 1), in: text),
                  let addressRange = Range(match.range(at: 2), in: text) else { return nil }
            
            let placeName = String(text[placeNameRange])
            let address = String(text[addressRange])
            
            return (placeName: placeName, address: address)
        }
    }
    
    
    func updateCameraAndSearch(for place: String) {
            DispatchQueue.main.async {
                let currentRegion = locationManager.region
                let zoomedOutRegion = MKCoordinateRegion(center: currentRegion.center,
                                                         span: MKCoordinateSpan(latitudeDelta: currentRegion.span.latitudeDelta * 8,
                                                                                longitudeDelta: currentRegion.span.longitudeDelta * 8))
                
                routeVm.cameraPosition = MapCameraPosition.region(zoomedOutRegion)
                searchViewModel.searchForLocalPlaces(for: place)
                uiStateVm.isShowNearByPlaces = true
                searchViewModel.nearBySearchName = place
                withAnimation(.easeInOut(duration: 0.01)) {
                    uiStateVm.selectedDetent = .height(310)
                    hideKeyboard()
                }
            }
        }
    
}


#Preview {
    NearBySearchView()
        .environmentObject(RouteViewModel( locationManager: LocationManagerDummy()))
        .environmentObject(MapViewModel(locationManager: LocationManagerDummy()))
        .environmentObject(SearchViewModel())
        .environmentObject(LocationManagerDummy())
    
    
    
}

struct NearByRowIconRowView: View {
    @State var iconName:String = ""
    @State var iconColor:Color = .white
    
    var body: some View {
        ZStack {
            Circle()
                .frame(width: 30, height: 30)
                .foregroundStyle(iconColor.opacity(0.25))
            
            Circle()
                .frame(width: 20, height: 20)
                .foregroundStyle(.white)
            
            Image(systemName: iconName)
                .resizable()
                .frame(width: 12, height: 12)
                .foregroundStyle(iconColor)
        }
    }
}

struct NearByRowIconRowViewSideMenu: View {
    @State var iconName:String = ""
    @State var iconColor:Color = .white
    
    var body: some View {
        ZStack {
            Circle()
                .frame(width: 20, height: 10)
                .foregroundStyle(iconColor.opacity(0.25))
            
            Circle()
                .frame(width: 10, height: 10)
                .foregroundStyle(.white)
            
            Image(systemName: iconName)
                .resizable()
                .frame(width: 8, height: 8)
                .foregroundStyle(iconColor)
        }
    }
}
