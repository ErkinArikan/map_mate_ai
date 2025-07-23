//
//  PharmacyRow2.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 11.01.2025.
//

import SwiftUI
import MapKit


struct PharmacyRow2: View {
    let pharmacy: Pharmacy
    @EnvironmentObject var searchViewModel: SearchViewModel
    @EnvironmentObject var uiStateVm: UIStateViewModel
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        Button {
//                        if let coordinate = pharmacy.coordinate {
//                            tapAddress(placeName: pharmacy.name, coordinate: coordinate)
//                        } else {
//                            print("Hata: Geçersiz koordinat")
//                        }
                            
            tapAddress(placeName: pharmacy.name, placeSubTitle: pharmacy.dist)
            
            hapticImpact.impactOccurred()
            uiStateVm.showDestinationDetailsView = true
            uiStateVm.showAnnotation = true
            //                                                    searchViewModel.searchForLocalPlaces(for: place.placeName)
            
            
            uiStateVm.activeSheet = .details
            
            uiStateVm.showDestinationDetailsView = true
            
            
            uiStateVm.selectedDetent = .height(300)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                
                
                Text(pharmacy.name)
                    .font(.headline)
                    .foregroundStyle(colorScheme == .light ? Color.hex("0C7B93"):Color.hex("F2F2F7"))
                
                Text("\(pharmacy.address)\n\(pharmacy.dist)")
                    .font(.system(size: 13))
                    .foregroundStyle(colorScheme == .light ? Color.hex("0C7B93").opacity(0.6):Color.hex("F2F2F7").opacity(0.6))
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Spacer()
                    Button(action: {
                        UIPasteboard.general.string = pharmacy.name
                        hapticImpact.impactOccurred()
                    }) {
                        Image(systemName: "doc.on.doc")
                            .foregroundStyle(colorScheme == .light ? Color.hex("0C7B93"):Color.hex("F2F2F7"))
                        
                    }
                    
                    
                    
                    //                Link("Adres Detayları", destination: URL(string: "https://www.google.com/maps?q=\(pharmacy.loc)")!)
                    //                    Button(action: {
                    //
                    //
                    //                    }) {
                    //                        HStack{
                    //                            Text("Haritada Göster")
                    //
                    //
                    //                            Image(systemName: "paperplane.fill")
                    //                        }
                    //                        .foregroundStyle(colorScheme == .light ? Color.hex("F2F2F7"):Color.hex("F2F2F7"))
                    //
                    //                    }
                    
                }
            }
            .overlay(alignment: .topTrailing) {
                Image(systemName: "e.square")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .foregroundStyle(.red)
            }
        }
        
        
        .padding()
        .background(colorScheme == .light ? Color(.systemGray5).opacity(0.7):(Color(.systemGray6)))
        .cornerRadius(10)
        .shadow(radius: 2)
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
//        func tapAddress(placeName: String, coordinate:CLLocationCoordinate2D){
//            searchViewModel.searchPlacesWithLoc(query: placeName, coordinate: coordinate)
//    
//    
//        }
    
    func tapAddress(placeName: String, placeSubTitle: String) {
        let cleanedPlaceName = placeName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedPlaceSubTitle = placeSubTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("Debug: tapAddress çağrıldı. Place Name: \(cleanedPlaceName), Place SubTitle: \(cleanedPlaceSubTitle)")
        
        let recentSearchCompletion = SearchCompletionsModel(title: cleanedPlaceName, subTitle: cleanedPlaceSubTitle, location: "")
//        searchViewModel.didTapOnSearchCompletion(recentSearchCompletion)
        searchViewModel.didTapOnSearchCompletionWithDistrict(recentSearchCompletion)
    }
}

#Preview {
    
    ZStack{
        PharmacyRow2(pharmacy: Pharmacy(
            name: "Eczane 1",
            dist: "Kadıköy",
            address: "Bağdat Caddesi No:123",
            phone: "02121234567",
            loc: "40.9876,29.1234"
        ))
        .environmentObject(SearchViewModel()) // SearchViewModel mock objesi
        .environmentObject(UIStateViewModel()) // UIStateViewModel mock objesi
    }
    
    
}

