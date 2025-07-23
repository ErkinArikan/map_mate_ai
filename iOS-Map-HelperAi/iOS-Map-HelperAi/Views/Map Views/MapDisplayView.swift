//
//  MapDisplayView.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 11.11.2024.
//

import SwiftUI
import MapKit

struct MapDisplayView: View {
    //MARK: - VARIABLES
    @Binding var isPolylineShow: Bool
    @Binding var selection: SearchResultModel?
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    @EnvironmentObject var vm: MapViewModel
    @EnvironmentObject var searchViewModel: SearchViewModel
    @EnvironmentObject var routeVm: RouteViewModel
    @Namespace private var favoritesMap
    @EnvironmentObject var locationManager:LocationManagerDummy
    @EnvironmentObject var uiStateVm:UIStateViewModel
    @Environment(\.colorScheme) private var colorScheme
    ///Burayı ekledim 6 ekim
    @Binding var shouldCenterMapOnUser: Bool // Bu değişkeni burada tanımlıyoruz

    
    
    //MARK: - BODY
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(position: $routeVm.cameraPosition, selection: $selection, scope: favoritesMap) {
                
                /// User location
                UserAnnotation()
                // MARK: - POLYLINE
                if isPolylineShow {
                    let routes = uiStateVm.isWalkRouteShowing ? routeVm.walkRoutes : routeVm.routes
                    let primaryColor = uiStateVm.isWalkRouteShowing ? Color.blue : Color.blue
                    let secondaryColor = uiStateVm.isWalkRouteShowing ? Color(.systemTeal) : Color.blue.opacity(0.5)

                    ForEach(routes, id: \.self) { route in
                           if uiStateVm.isWalkRouteShowing {
                               // Kesikli yol için
                               MapPolyline(route.polyline)
                                   .stroke(primaryColor, style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [10, 5])) // Dash ayarı
                           } else {
                               // Normal yol için
                               MapPolyline(route.polyline)
                                   .stroke(route == routes.first ? primaryColor : secondaryColor, lineWidth: route == routes.first ? 9 : 7)
                           }
                       }
                }

                //MARK: - NEAR BY ANNOTATIONS
                if uiStateVm.isShowNearByPlaces {
                    ForEach(searchViewModel.exSearchResul, id: \.self) { result in
                        let item = result.mapItem
                        let placeType = vm.getPlaceType(for: searchViewModel.nearBySearchName)
                        
                        Annotation(item.placemark.name ?? "", coordinate: item.placemark.coordinate) {
                            ZStack {
                                Circle()
                                    .frame(width: 40, height: 40)
                                    .foregroundStyle(placeType.color.opacity(0.25))
                                
                                Circle()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(.white)
                                
                                Image(systemName: placeType.icon)
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(placeType.color)
                            } //: ZStack
                        } //: Annotation
                    } //:For
                } //: if
                
                //MARK: - DEFAULT MARKER
                if /*uiStateVm.showDestinationDetailsView && !uiStateVm.isShowNearByPlaces*/    uiStateVm.showAnnotation == true{
                    ForEach(searchViewModel.searchResults, id: \.self) { item in
                        
//                        Marker(placemark.name ?? "", coordinate: placemark.coordinate)
                        Annotation(item.mapItem.placemark.name ?? "", coordinate: item.mapItem.placemark.coordinate){
                            ZStack {
                                Circle()
                                    .fill(Color.hex("0C7B93").opacity(0.8))  // Daha dikkat çekici bir kırmızı renk
                                    .frame(width: 40, height: 40) // Çerçeve genişletildi
                                    .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 5) // Daha belirgin bir gölge
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 3) // Beyaz dış çerçeve
                                    )
                                
                                Image(systemName: "mappin.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 28, height: 28)
                                    .foregroundColor(.white)
                            }
                            .shadow(radius: 5)
                            .transition(.scale) // Görünüş animasyonu
                            .animation(.spring(), value: searchViewModel.searchResults) // Animasyon eklenmiş
                            
                        }
                    } //:For
                }//:if
                
                
                //MARK: - POLYLINE
             
                
            } //: MAP
            .mapControlVisibility(.hidden)
            .mapStyle(vm.mapStyleConfig.mapStyle)
            
            mapUserLocationButton
        
            
            
        } //:ZStack

        .onChange(of: selection, { oldValue, newValue in
            guard let selectedLocation = newValue else {
                print("Yeni bir konum seçilmedi")
                return
            }
            
            print("Yeni seçim yapıldı: \(selectedLocation.mapItem.name ?? "İsimsiz Konum")")

            withAnimation(.spring) {
                uiStateVm.isSearchViewShow = false
                uiStateVm.showDestinationDetailsView = true
            
                uiStateVm.selectedDetent = .height(300)
                uiStateVm.activeSheet = .details
                
                // Detayları güncelle
                let recentSearchCompletion = SearchCompletionsModel(title: selectedLocation.mapItem.name ?? "No name", subTitle: selectedLocation.mapItem.placemark.subtitle ?? "No subtitle", location: "")
                searchViewModel.didTapOnSearchCompletion(recentSearchCompletion)

                // Haritayı yeni seçilen konuma odaklayın
                let newRegion = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: selectedLocation.mapItem.placemark.coordinate.latitude,
                                                   longitude: selectedLocation.mapItem.placemark.coordinate.longitude),
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
                routeVm.cameraPosition = MapCameraPosition.region(newRegion)
            }
        })
        .mapScope(favoritesMap)
        
      
    }

    
}



extension MapDisplayView{
    
    private var mapUserLocationButton: some View{
       
        VStack{
            
            MapCompass(scope: favoritesMap)
                .mapControlVisibility(.visible)
                .tint(Color("TextColor"))
                .shadow(color: .gray.opacity(0.4), radius: 20, x: 0, y: 20)
                
            
            MapPitchToggle(scope: favoritesMap)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(colorScheme == .light ? Color.hex("0C7B93").opacity(0.8) : Color("NewBlack1"))
                )
                .mapControlVisibility(.visible)
            
                .tint(colorScheme == .light ? Color.hex("#F2F2F7"):Color.hex("#F2F2F7"))
              
                .shadow(color: .gray.opacity(0.4), radius: 20, x: 0, y: 20)
                
                
            ZStack{
                //User location button özelleştirilmiş hali
                //MARK: - MAPUSER LOCATION BUTTON
                MapUserLocationButton(scope: favoritesMap)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(colorScheme == .light ? Color.hex("0C7B93").opacity(0.8) : Color("NewBlack1"))
                    )
                    .mapControlVisibility(.visible)
                
                    .tint(colorScheme == .light ? Color.hex("#F2F2F7"):Color.hex("#F2F2F7"))
                  
                    .shadow(color: .gray.opacity(0.4), radius: 20, x: 0, y: 20)
                    
               
                    
            } //:ZStack
        } //:VStacka
        .padding()
//        .buttonBorderShape(.circle)
        .offset(y: calculateOffset())
        .mapScope(favoritesMap)
        
        
    }
    
    private func calculateOffset() -> CGFloat {
        // Durumlara göre y ofsetini hesaplayarak sadece bir offset uyguluyoruz
        if uiStateVm.isSearchViewShow  {
            return -270
        }
        else if uiStateVm.showDestinationDetailsView {
            return -320
        }else if  uiStateVm.isDirectionsShow{
            return -350
        }else {
            return -130
        }
        
    }
}



