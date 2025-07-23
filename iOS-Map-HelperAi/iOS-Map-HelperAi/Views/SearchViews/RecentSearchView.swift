//
//  RecentSearchView.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 23.09.2024.
//

import SwiftUI
import SwiftData
import MapKit

struct RecentSearhView: View {
    @EnvironmentObject var vm: MapViewModel
    @Environment(\.modelContext) var context
    @EnvironmentObject var searchVm:SearchViewModel
    @EnvironmentObject var uiStateVm:UIStateViewModel
    // DB'yi kullanabilmek için gerekli
    @Query(sort: \LastSearchedPlaces.timestamp) private var items: [LastSearchedPlaces]
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var searchViewModel:SearchViewModel
    @EnvironmentObject var routeVm:RouteViewModel
    @EnvironmentObject var languageManager:LanguageManager
    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                Text("Last Searched Places".addLocalizableString(str: languageManager.language))
                    .font(.system(size: 13))
                    .foregroundStyle(colorScheme == .light ? Color.hex("0C7B93"): Color.hex("F2F2F7"))
                    .padding(.horizontal, 20)
//                Color.hex("0C7B93")
                Spacer()
                    
                
                if !uiStateVm.isSecondViewSearchView {
                    Button {
                        withAnimation(.easeInOut){
                            uiStateVm.isGridActive.toggle()
                            uiStateVm.isSecondViewSearchView = true
                        }
                        
                        
                    } label: {
                        ZStack {
                            Circle()
                                .fill(colorScheme == .light ? Color.hex("0C7B93"): Color(UIColor.systemGray6))
                                .frame(width: 35, height: 35)
                                .padding(.leading)
                                .shadow(color: .gray.opacity(0.9), radius: 1, x: 0, y: 1)
                            
                            
                            Image(systemName: "square.grid.2x2")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 17, height: 17)
                                .background(colorScheme == .light ? Color.hex("0C7B93"): Color(UIColor.systemGray6))
                                .padding(.leading)
                                .foregroundStyle(uiStateVm.isGridActive ? .blue :  Color.hex("F2F2F7"))
                                .fontWeight(.medium)
                        }
                        //                                .clipShape(Capsule(style: .continuous))
//                        Color.hex("0C7B93") : colorScheme == .light ?  Color.hex("0C7B93"): Color.hex("F2F2F7")
                    }
                    .padding(.trailing)
                } else {
                    /*@START_MENU_TOKEN@*/EmptyView()/*@END_MENU_TOKEN@*/
                }
            }
            
            Divider()
                .overlay(content: {
                    Color.hex("0C7B93")
                })
                
//                .foregroundStyle(Color.hex("0C7B93"))
            
            List {
                ForEach(items.reversed()) { item in
                    VStack(alignment: .leading) {
                        Button(action: {
                            withAnimation {
                                searchVm.exSearchResul.removeAll(keepingCapacity: false)
                                handleItemSelection(item: item)
                                hapticImpact.impactOccurred()
                            }
                           
                        }, label: {
                            HStack {
                                NearByRowIconRowView(iconName: "magnifyingglass", iconColor:Color("myDark"))
                               
                                Text(item.poiadi)
                                    .font(.system(size: 18,weight: .medium))
                                    .lineLimit(1) // Metni tek satırda sınırla
                                    .truncationMode(.tail) // Metni sağdan kes ve '...' ekle
                                    .foregroundStyle(colorScheme == .light ? Color.hex("0C7B93"): Color("TextColor"))
                                Spacer()
                                Spacer()
                                Button {
                                    withAnimation {
                                        context.delete(item)
                                    }
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundStyle(.red)
                                } //:Button
                            }
                        })
                        .foregroundStyle(.black)
                        
                       
                    } //:VStack
                    .frame(maxWidth: .infinity, alignment: .leading)
                } //:Foreach
                .listRowBackground(Color.clear)
            } //:List
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.immediately)
            .listStyle(.plain)
        } //: VStack
        .padding(.top, uiStateVm.isSecondViewSearchView ? 20 : 10)
        .ignoresSafeArea(.keyboard)
        
        
        
    }
    // Fonksiyon: Seçilen öğe ile yapılan işlemleri yönetir
        func handleItemSelection(item: LastSearchedPlaces) {
            // Son arananlarda seçili yerin lat ve lon bilgileri
            let recentSearchCompletion = SearchCompletionsModel(title: item.poiadi, subTitle: item.il, location: "")
            print("item il:\(item.poiadi)")
            print("item ilçe: \(item.ilce)")
            
            ///Deneme
            uiStateVm.activeSheet = .details
            uiStateVm.selectedDetent = .height(300)
            searchViewModel.searchText = ""
            searchViewModel.didTapOnSearchCompletion(recentSearchCompletion)
//            iosVm.shouldCenterMapOnUser = false

            // Kamerayı seçili lokasyona odaklama
            let newRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: item.lat, longitude: item.lon),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            
            withAnimation(.spring(duration: 0.3)) {
                // Search view kapansın
                uiStateVm.isSearchViewShow = false
                // Route view açılsın
                uiStateVm.showDestinationDetailsView = true
                
                uiStateVm.showAnnotation = true
                // Kamera animasyonlu gelsin
//                vm.cameraRegion = EquatableCoordinateRegion(region: newRegion)
                routeVm.cameraPosition = MapCameraPosition.region(newRegion)
            }
        }
    
    
}

#Preview {
    RecentSearhView()
        .environmentObject(MapViewModel(locationManager: LocationManagerDummy()))
        .environmentObject(SearchViewModel())
        .environmentObject(RouteViewModel( locationManager: LocationManagerDummy()))
        .environmentObject(UIStateViewModel())
        .environmentObject(UIStateViewModel())
}
