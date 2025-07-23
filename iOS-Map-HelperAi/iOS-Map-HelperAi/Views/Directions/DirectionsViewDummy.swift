//
//  RouteViewDirectionDummy.swift
//  AI-HelperMap
//
//  Created by Erkin Arikan on 9.09.2024.
//

import SwiftUI
import SwiftData
import MapKit

struct DirectionsViewDummy: View {
    
    //MARK: - VARIABLE
    
    @EnvironmentObject var locationManager:LocationManagerDummy
    @EnvironmentObject var vm:MapViewModel
    @EnvironmentObject var routeVm:RouteViewModel
    @EnvironmentObject var uiStateVm:UIStateViewModel
    @Environment(\.colorScheme) private var colorScheme
    //MARK: - BODY
    var body: some View {
        
        ZStack {
          
            VStack(alignment:.leading){
                
                HStack{
                    //MARK: - ADDRESSES
                    DirectionAddressView()
                    
                    //MARK: - CLOSE BUTTON
                    DirectionsTopView()
                    
                } //:HStack
                .padding(.trailing)
                
                Divider()
                
                //MARK: - BUTTONS
                if uiStateVm.selectedDetent != .height(100) {
                    
                    DirectionsButtonsView()
                
               
                Spacer()
                }
                    
                    
               
            } //:VStack
          
            .background{
                colorScheme == .light ?  Color.hex("F2F2F7").ignoresSafeArea(.all):Color("NewBlack1").ignoresSafeArea(.all)
            }
        } //:ZStack
        .ignoresSafeArea()
    } //:BODY
    
}

//MARK: PREVIEW
#Preview {
    DirectionsViewDummy()
        .environmentObject(LocationManagerDummy())
        .environmentObject(MapViewModel(locationManager: LocationManagerDummy()))
        .environmentObject(RouteViewModel( locationManager: LocationManagerDummy()))
        .environmentObject(SearchViewModel())
}

