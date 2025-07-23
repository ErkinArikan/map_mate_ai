//
//  DirectionsButtonsView.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 26.10.2024.
//

import SwiftUI
import _MapKit_SwiftUI

enum TransportType {
    case car
    case walk
}

struct DirectionsButtonsView: View {
    @EnvironmentObject var routeVm: RouteViewModel
    @State private var selectedTransport: TransportType = .car // Varsayılan olarak araba seçili
    @EnvironmentObject var vm:MapViewModel
    @EnvironmentObject var uiStateVm:UIStateViewModel
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var locationManager:LocationManagerDummy
    
    
    var body: some View {
        VStack(alignment:.leading) {
            

                HStack {
                    Button(action: { selectedTransport = .car }) {
                        Image(systemName: "car.fill")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(selectedTransport == .car ? colorScheme == .light ? Color.hex("0C7B93"): Color.hex("F2F2F7") : Color("BabyBlue"))
                            .padding()
                            .padding(.horizontal)
                            .cornerRadius(12)
                            .background {
                                selectedTransport == .car
                                ? (colorScheme == .light ? Color(.systemGray4) : Color(.systemGray6))
                                : (colorScheme == .light ? Color(.systemGray6):Color(.systemGray5))
                            }
                            .cornerRadius(12)
                           
                    }
                    
                    Button(action: { selectedTransport = .walk }) {
                        Image(systemName: "figure.walk")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(selectedTransport == .walk ? colorScheme == .light ? Color.hex("0C7B93"): Color.hex("F2F2F7") : Color("BabyBlue"))
                            .padding()
                            .padding(.horizontal)
                            .cornerRadius(12)
                            .background {
                                selectedTransport == .walk
                                ? (colorScheme == .light ? Color(.systemGray4) : Color(.systemGray6))
                                : (colorScheme == .light ? Color(.systemGray6):Color(.systemGray5))
                            }
                            .cornerRadius(12)
                    }
                }
                
                // Seçili olana göre rotaları listeleme
                if selectedTransport == .car {
                    
                    carRouteView

                        
                } else {
                    walkRoutesView
                }
                
            
           

        }
        .onChange(of: selectedTransport, { oldValue, newValue in
            if newValue == .car{
                withAnimation(.spring){
                    uiStateVm.isWalkRouteShowing = false
                }
                
            }else{
                withAnimation(.spring){
                    uiStateVm.isWalkRouteShowing = true
                }
            }
        })
        .padding()
        .ignoresSafeArea(.all)
       

    }


}

#Preview {
    DirectionsButtonsView()
        .environmentObject(LocationManagerDummy())
        .environmentObject(MapViewModel(locationManager: LocationManagerDummy()))
        .environmentObject(RouteViewModel( locationManager: LocationManagerDummy()))
        .environmentObject(SearchViewModel())
}










//MARK: - EXTENSION
extension DirectionsButtonsView{
    
    private var carRouteView:some View{
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(routeVm.routeModelArray) { routeInfo in
                    Button {
                        withAnimation{
                            uiStateVm.activeSheet = .startedNavigation
                            
                            let userLocation = locationManager.region.center

                            // Kamerayı 3D görünüm için ayarla
                            let targetRegion = MapCamera(
                                centerCoordinate: CLLocationCoordinate2D(latitude: userLocation.latitude, longitude: userLocation.longitude),
                                distance: 300,
                                heading: 0,
                                pitch: 30    // Kuzey yönüyle başlar (rota yönüne göre ayarlanabilir)
                            )

                            // Kamerayı animasyonlu bir şekilde uygulayın
                            withAnimation(.easeInOut(duration: 1.5)) { // Yumuşak geçiş animasyonu
                                routeVm.cameraPosition = .camera(targetRegion)
                            }
                            
                            // Seçilen rotayı güncelle
                                    if selectedTransport == .car {
                                        routeVm.selectedRoute = routeInfo
                                    } else {
                                        routeVm.selectedRoute = routeInfo
                                    }
                            
                        }
                       
                    
                    } label: {
                    HStack {
    //                    Text("\(routeInfo.readableTime)")
                        
                        VStack(alignment: .leading){
                            Text("\(routeInfo.readableTime)")
                                .fontWeight(.semibold)
                                .foregroundStyle( Color.hex("F2F2F7"))
                            
        //                    Text("\(routeInfo.distanceKm, specifier: "%.2f") km")
                            HStack{
                                Text("\(routeInfo.distanceKm, specifier: "%.2f") km")
                                    .foregroundStyle( Color.hex("F2F2F7"))
                                Image(systemName: "car.circle")
                                    .foregroundStyle( Color.hex("F2F2F7"))
                            
                            }
                            
                        }
                       
                        Spacer()
                       
                            
                            ZStack {
                                Circle()
                                    .frame(width: 35, height: 35)
                                    .foregroundStyle(.green.opacity(0.25))
                                
                                Circle()
                                    .frame(width: 25, height: 25)
                                    .foregroundStyle(.white)
                                
                                Image(systemName: "arrow.up.forward")
                                    .resizable()
                                    .frame(width: 12, height: 12)
                                    .foregroundStyle(.blue)
                            }
                           

                        }
                        
                        
                    }
                    .padding()
                    .background(colorScheme == .light ? Color.hex("0C7B93").opacity(0.7):Color.gray)
                    .cornerRadius(15)
                    .padding(.bottom, 5)
//                    .shadow(color: .gray.opacity(0.4), radius: 20, x: 0, y: 20)
                    
                   
                }
            }
        }
        .scrollIndicators(.hidden)
    }
    
    
    private var walkRoutesView: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(routeVm.walkRouteInfos){ routeInfo in
                    Button {
                        withAnimation{
                            uiStateVm.activeSheet = .startedNavigation
                            let userLocation = locationManager.region.center
                            
                            // Kamerayı 3D görünüm için ayarla
                            let targetRegion = MapCamera(
                                centerCoordinate: CLLocationCoordinate2D(latitude: userLocation.latitude, longitude: userLocation.longitude),
                                distance: 300,
                                heading: 0,
                                pitch: 30    // Kuzey yönüyle başlar (rota yönüne göre ayarlanabilir)
                            )

                            // Kamerayı animasyonlu bir şekilde uygulayın
                            withAnimation(.easeInOut(duration: 1)) { // Yumuşak geçiş animasyonu
                                routeVm.cameraPosition = .camera(targetRegion)
                            }
                            
                            // Seçilen rotayı güncelle
                                    if selectedTransport == .car {
                                        routeVm.selectedRoute = routeInfo
                                    } else {
                                        routeVm.selectedRoute = routeInfo
                                    }
                        }
                 
                        
                    } label: {
                    HStack {
                        //
                        
                        VStack(alignment: .leading){
                            Text("\(routeInfo.readableTime)")
                                .fontWeight(.semibold)
                                .foregroundStyle( Color.hex("F2F2F7"))
                               
                            
                            //                    Text("\(routeInfo.distanceKm, specifier: "%.2f") km")
                            HStack{
                                Text("\(routeInfo.distanceKm, specifier: "%.2f") km")
                                    .foregroundStyle( Color.hex("F2F2F7"))
                                Image(systemName: "figure.walk.circle")
                                    .foregroundStyle( Color.hex("F2F2F7"))
                                
                            }
                            
                        }
                        
                        Spacer()
                        
                            
                            ZStack {
                                Circle()
                                    .frame(width: 35, height: 35)
                                    .foregroundStyle(.green.opacity(0.25))
                                
                                Circle()
                                    .frame(width: 25, height: 25)
                                    .foregroundStyle(.white)
                                
                                Image(systemName: "arrow.up.forward")
                                    .resizable()
                                    .frame(width: 12, height: 12)
                                    .foregroundStyle(.blue)
                            }
                            
                            
                        }
                        
                        
                    }
                    .padding()
                    .background(colorScheme == .light ? Color.hex("0C7B93").opacity(0.7):Color.gray)
                    .cornerRadius(15)
                    .padding(.bottom, 5)
//                    .shadow(color: .gray.opacity(0.4), radius: 20, x: 0, y: 20)
                   
                    
                }
            }
        }
        .scrollIndicators(.hidden)
       
    }
}
