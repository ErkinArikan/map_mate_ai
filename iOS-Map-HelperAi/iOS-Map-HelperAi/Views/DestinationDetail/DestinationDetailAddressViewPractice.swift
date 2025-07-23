//
//  DestinationDetailAddressViewPractice.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 23.09.2024.
//

import SwiftUI
import MapKit

struct DestinationDetailAddressViewPractice: View {
    //    @EnvironmentObject var searchViewModel:SearchViewModel
    //    @EnvironmentObject var directionsViewModel:DirectionViewModel
    
    @EnvironmentObject var locationManager:LocationManagerDummy
    @EnvironmentObject var vm:MapViewModel
    @EnvironmentObject var routeVm:RouteViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    @Environment(\.modelContext) var context
    var body: some View {
        VStack(alignment:.leading) {
            Text(routeVm.selectedLocation?.mapItem.placemark.name ?? "NO INFO")
                .font(.system(size:21))
                .fontWeight(.medium)
                .foregroundStyle(colorScheme == .light ? Color.hex("0C7B93"): Color("TextColor"))
                .padding(.horizontal)
                .padding(.top)
            
            Text("\(routeVm.selectedLocation?.mapItem.placemark.title ?? "NO INFO")")
                .font(.system(size: 12))
                .foregroundStyle(colorScheme == .light ? Color.hex("0C7B93").opacity(0.6):Color.gray)
                .padding(.horizontal)
        }
    }
}


//#Preview {
//    DestinationDetailAddressViewPractice()
//}
