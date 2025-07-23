//
//  NearBySearchView2.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 18.10.2024.
//

import SwiftUI
import MapKit

struct NearbyPlace: Identifiable {
    let id = UUID()
    let name: String
    let searchFor: String
    let iconName: String
    let iconColor: Color
}


struct NearBySearchViewHorizontal: View {
    @EnvironmentObject var routeVm:RouteViewModel
    @EnvironmentObject var vm:MapViewModel
    @EnvironmentObject var searchViewModel:SearchViewModel
    @EnvironmentObject var locationManager:LocationManagerDummy
    @EnvironmentObject var uiStateVm:UIStateViewModel
    @EnvironmentObject var languageManager:LanguageManager
    
    let nearbyPlaces = [
        NearbyPlace(name: "Hospital", searchFor: "Hastane", iconName: "cross.fill", iconColor: .red),
        NearbyPlace(name: "Kafe", searchFor: "Kafe", iconName: "cup.and.saucer.fill", iconColor: .brown),
        NearbyPlace(name: "Benzinlik", searchFor: "Benzinlik", iconName: "fuelpump.fill", iconColor: .blue),
        NearbyPlace(name: "Otel", searchFor: "Otel", iconName: "bed.double.fill", iconColor: .purple),
        NearbyPlace(name: "Eczane", searchFor: "Eczane", iconName: "pill.fill", iconColor: .pink),
        NearbyPlace(name: "Metro", searchFor: "Metro İstasyonu", iconName: "tram.fill", iconColor: .blue),
        NearbyPlace(name: "AVM", searchFor: "Alışveriş Merkezi", iconName: "tag.fill", iconColor: .pink),
        NearbyPlace(name: "Market", searchFor: "Market", iconName: "cart.fill", iconColor: .orange),
        NearbyPlace(name: "Şarj", searchFor: "Şarj İstasyonu", iconName: "bolt.fill", iconColor: .green),
        NearbyPlace(name: "ATM", searchFor: "ATM", iconName: "creditcard.fill", iconColor: .gray)
        ]
    @Environment(\.colorScheme) private var colorScheme
  
    
    //MARK: - BODY
    var body: some View {
        VStack(alignment:.leading){
            HStack{
                
                Text("Nearby places".addLocalizableString(str: languageManager.language))
                    .font(.system(size: 13))
                    .foregroundStyle(colorScheme == .light ? Color.hex("0C7B93"): Color.hex("F2F2F7"))
                    .padding(.horizontal,20)
                
                Spacer()
                
                Button {
                    withAnimation(.easeInOut){
                        uiStateVm.isGridActive.toggle()
                        uiStateVm.isSecondViewSearchView = false
                        hapticImpact.impactOccurred()
                    }
                 
                
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(.systemGray6))
                            .frame(width: 35, height: 35)
                            .padding(.leading)
                            .shadow(color: .gray.opacity(0.9), radius: 1, x: 0, y: 1)
                        
                        
                        Image(systemName: "square.grid.2x2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 17, height: 17)
                            .background(Color(UIColor.systemGray6))
                            .padding(.leading)
                            .foregroundStyle(uiStateVm.isGridActive ? .blue : Color("TextColor"))
                            .fontWeight(.medium)
                    }
//                                .clipShape(Capsule(style: .continuous))

                }
                .padding(.trailing)
            }
            Divider()
                .overlay(content: {
                    Color.hex("0C7B93")
                })
            
            ScrollView(.horizontal) {
                
                LazyHStack {
                    ForEach(nearbyPlaces) { place in
                        Button {
                            withAnimation {
                                uiStateVm.showDestinationDetailsView = true
                                updateCameraAndSearch(for: place.searchFor)
                            }
                           
                        } label: {
                            VStack {
                                NearByRowIconRowView2(iconName: place.iconName, iconColor: place.iconColor)
                                Text(place.name.addLocalizableString(str: languageManager.language))
                                    .font(.system(size: 15))
                                    .foregroundStyle(colorScheme == .light ? Color.hex("0C7B93"): Color("TextColor"))
                                    .fontWeight(.medium)
                            }
                        }
                        .padding(.leading)
                    }
                } //: LazyHStack
                .scrollIndicators(.hidden)
                .listStyle(.plain)
          
                
            } //:ScrollView
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.immediately)
            .frame(maxHeight: 100)
            
        }//:VStack
    }
    
    
    //MARK: - UPDATE CAMERA FUNCTION
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
    NearBySearchViewHorizontal()
        .environmentObject(RouteViewModel( locationManager: LocationManagerDummy()))
        .environmentObject(MapViewModel(locationManager: LocationManagerDummy()))
        .environmentObject(SearchViewModel())
        .environmentObject(LocationManagerDummy())
}


//MARK: - ROW ICON
struct NearByRowIconRowView2: View {
    @State var iconName:String = ""
    @State var iconColor:Color = .white
    
    var body: some View {
        ZStack {
            Circle()
                .frame(width: 60, height: 60)
                .foregroundStyle(iconColor.opacity(0.25))
            
            Circle()
                .frame(width: 45, height: 45)
                .foregroundStyle(.white)
            
            Image(systemName: iconName)
                .resizable()
                .frame(width: 25, height:25)
                .foregroundStyle(iconColor)
        }
    }
}
