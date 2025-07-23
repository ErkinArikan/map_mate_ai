//
//  DestinationDetailsButtonsViewPractice.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 23.09.2024.
//

import SwiftUI
import MapKit

struct DestinationDetailsButtonsViewPractice: View {
    @EnvironmentObject var locationManager:LocationManagerDummy
    @EnvironmentObject var vm:MapViewModel
    @EnvironmentObject var routeVm:RouteViewModel
    @EnvironmentObject var searchVm:SearchViewModel
    @EnvironmentObject var uiStateVm:UIStateViewModel
//    @StateObject var rotaManager = RotaManager.shared
    @Binding var getDirections:Bool
    @Binding var show:Bool
    @Environment(\.colorScheme) private var colorScheme
//    @Binding var showToast:Bool
//    @Binding var toast: Toast?
    @EnvironmentObject var languageManager:LanguageManager
    @Environment(\.modelContext) var context
    @EnvironmentObject var favoritesVm:FavoritesViewModel
    var map = MapView()
    
    var body: some View {
        HStack(spacing:15){
            
        //MARK: - DIRECTIONS BUTTON
            Button(action: {
                //buraya bastığımızda Directions sayfası aktif olmalı.
                withAnimation(.spring(duration: 0.3)){
                    uiStateVm.isDirectionsShow = true
                    
//                    vm.showDestinationDetailsView = false
                    uiStateVm.isSearchViewShow = false
                    getDirections = true
                    show = false
                    uiStateVm.activeSheet = .direction
                    uiStateVm.selectedDetent = .height(400)
//                    searchVm.exSearchResul.removeAll(keepingCapacity: false)
                    
                }
             
                
            }, label: {
                Group{
                   
                
                        Text("Directions".addLocalizableString(str: languageManager.language))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(colorScheme == .light ?  Color.hex("F2F2F7"):  Color.hex("F2F2F7"))
                    
                    
                }.frame(width:110,height: 30)
                    .padding()
                    .padding(.horizontal,30)
                    .background(colorScheme == .light ? Color.hex("0C7B93").opacity(0.7):(Color(.systemGray6)))
                    .cornerRadius(20)
//                    .shadow(color: .gray.opacity(0.4), radius: 20, x: 0, y: 20)
                   
            })
            
            
            
            //MARK: - SHARE BUTTON
            ZStack{
                Circle()
                    .fill(colorScheme == .light ? Color.hex("0C7B93").opacity(0.7):(Color(.systemGray6)))
                    .frame(width: 60, height: 60)
                   
                
                
                ShareLink("",item: URL(string: "https://maps.apple.com/?ll=\(routeVm.selectedLocation?.mapItem.placemark.coordinate.latitude ?? 0.0),\(routeVm.selectedLocation?.mapItem.placemark.coordinate.longitude ?? 0.0)")!)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(colorScheme == .light ?  Color.hex("F2F2F7"):  Color.hex("F2F2F7"))
                    .padding(.leading,7)
                
                
            }
            
            //MARK: - STAR BUTTON
            ZStack {
                Circle()
                    .fill(colorScheme == .light ? Color.hex("0C7B93") : Color(.systemGray6))
                    .frame(width: 60, height: 60)
                    .shadow(radius: 2)
                
                Button(action: {
                    withAnimation {
                        if favoritesVm.isFavorite(place: routeVm.selectedLocation) {
                            favoritesVm.deleteFavorite(place: [
                                "lat": routeVm.selectedLocation?.mapItem.placemark.coordinate.latitude ?? 0.0,
                                "lon": routeVm.selectedLocation?.mapItem.placemark.coordinate.longitude ?? 0.0
                            ])
                        } else {
                            favoritesVm.saveFavoritePlaceToUser(from: routeVm.selectedLocation)
                        }
                    }
                }, label: {
                    Image(systemName: favoritesVm.isFavorite(place: routeVm.selectedLocation) ? "star.fill" : "star")
                        .font(.title2)
                        .foregroundStyle(Color.hex("F2F2F7"))
                })
            }
            
            
        }
       
        .padding(.horizontal)
        .padding(.top,25)
    }
}


//#Preview {
//    DestinationDetailsButtonsViewPractice()
//}
