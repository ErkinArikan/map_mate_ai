//
//  DestinationDetailFooterViewPractice.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 23.09.2024.
//

import SwiftUI
import MapKit

struct DestinationDetailFooterViewPractice: View {
    @EnvironmentObject var locationManager:LocationManagerDummy
    @EnvironmentObject var vm:MapViewModel
    @EnvironmentObject var routeVm:RouteViewModel
    
//    @EnvironmentObject var searchViewModel:SearchViewModel
//    @EnvironmentObject var directionsViewModel:DirectionViewModel
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        
            HStack{
                VStack(alignment:.leading){
                   
                    
                    HStack{
                        Image(systemName: "location")
                            .foregroundStyle(colorScheme == .light ? Color.hex("0C7B93"): Color("TextColor"))
                        Text("\(routeVm.selectedLocation?.mapItem.placemark.coordinate.latitude ?? 0.0)  \(routeVm.selectedLocation?.mapItem.placemark.coordinate.longitude ?? 0.0)")
                            .foregroundStyle(colorScheme == .light ? Color.hex("0C7B93"): Color("TextColor"))
                       
                    }
                }
                
//                Spacer()
                
                
//                Button{
//                    if let mapSelection{
//                        mapSelection.openInMaps()
//                    }
//                } label: {
//                    Text("Open in Maps")
//                        .padding(.horizontal)
//                        .font(.headline)
//                        .foregroundStyle(.white)
//                        .frame(height: 48)
//                        .background(.green)
//                        .cornerRadius(12)
//                }
            
            
            
            
            
        }
        .padding(.horizontal)
        .padding(.top,10)
    }
}

#Preview {
    DestinationDetailFooterViewPractice()
}
