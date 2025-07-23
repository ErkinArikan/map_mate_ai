//
//  RouteViewDummy.swift
//  AI-HelperMap
//
//  Created by Erkin Arikan on 8.09.2024.
//

import SwiftUI

import MapKit
struct DestinationDetailsView: View {
 

    @EnvironmentObject var locationManager:LocationManagerDummy
    @EnvironmentObject var vm:MapViewModel
    @EnvironmentObject var routeVm:RouteViewModel
    @EnvironmentObject var uiStateVm:UIStateViewModel
    
   
    @Binding var show:Bool
    
    @Binding var getDirections:Bool
 
    @EnvironmentObject var languageManager:LanguageManager

    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        ZStack {
            Color("DarkBg2")
                  .ignoresSafeArea(.all)
            VStack(alignment:.leading,spacing: 3) {
               

                HStack{
                    DestinationDetailAddressViewPractice()
                    
                    DestinationDetailTopView()
                    
                }
//                .padding(.top,70)
                .padding(.trailing)
                .padding(.bottom)
                Divider()
                    .overlay(content: {
                        Color.hex("0C7B93")
                    })

                
                if uiStateVm.selectedDetent != .height(60){
                    DestinationDetailsButtonsViewPractice(getDirections: $getDirections, show: $show)
                    
                    VStack{


                        
                        Button {
                            if let url = URL(string: "tel://\(routeVm.selectedLocation?.mapItem.phoneNumber ?? "Numara Yok")"), UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "phone.fill")
                                    .foregroundColor(.green)
                                Text("\(routeVm.selectedLocation?.mapItem.phoneNumber ?? "No Phone")")
                                    .foregroundStyle(colorScheme == .light ? Color.hex("0C7B93") : Color("TextColor"))
                            }
                        }
//                            .foregroundStyle()
    //                    Text("\(String(describing: mapSelection?.url ?? URL("sdasd")) )")
                    }
                    .padding(.top,14)
                    .padding(.leading)
                    
                    DestinationDetailFooterViewPractice()
                    
                    
                    Spacer()
                }
                
               
                
                
            }
            .padding(.top)
        }
        

   
        /*.animation(.easeInOut, value: vm.showDestinationDetailsView) */ // Kapatma animasyonu için
        
    }
    
       
    
}



#Preview {
    DestinationDetailsView( show: .constant(false), getDirections: .constant(false))
        .environmentObject(LocationManagerDummy())
        .environmentObject(MapViewModel(locationManager: LocationManagerDummy()))
        .environmentObject(RouteViewModel(locationManager: LocationManagerDummy()))
}

