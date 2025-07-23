//
//  DirectionAddressView.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 26.10.2024.
//

import SwiftUI

struct DirectionAddressView: View {
    @EnvironmentObject var vm:MapViewModel
    @EnvironmentObject var iosVm:RouteViewModel
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var languageManager:LanguageManager
    var body: some View {
        HStack(alignment:.top){
            
            VStack(alignment:.center){
                Image(systemName: "location.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(colorScheme == .light ? Color.hex("0C7B93"):Color.hex("F2F2F7"))
                 
                    .frame(height: 20)
                    .padding(.top,5)
                
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .light ? Color.hex("0C7B93"): Color(.systemGray6))
                    .frame(width:2,height: 11)
                
                Image(systemName: "mappin.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(colorScheme == .light ? Color.hex("0C7B93"): Color.hex("F2F2F7"))
                   
                    .frame(height: 20)
                
             
            
                
                
            }
            
            
            VStack(alignment:.leading,spacing: 11) {
                
                // First Text with Background
                ZStack(alignment:.leading) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colorScheme == .light ? Color("BabyBlue"):Color(.systemGray6))
                        .frame(width: 280, height: 35)
                    
                    Text("My Location".addLocalizableString(str: languageManager.language))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 10)
                        .foregroundStyle(colorScheme == .light ?  Color.hex("0C7B93"):Color.hex("F2F2F7"))
                }
                
                // Second Text with Background
                ZStack(alignment:.leading) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colorScheme == .light ? Color("BabyBlue"):Color(.systemGray6))
                        .frame(width: 280, height: 35)
                    
                 

                    Text(iosVm.selectedLocation?.mapItem.placemark.name ?? "No address")
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .foregroundStyle(colorScheme == .light ?  Color.hex("0C7B93"):Color.hex("F2F2F7"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 10)
                        .padding(.trailing,60)
                }
                
              
            }
            
//            Spacer()
        }
        .padding(.leading)
        .padding(.top)
    }
}

#Preview {
    DirectionAddressView()
        .environmentObject(LocationManagerDummy())
        .environmentObject(MapViewModel(locationManager: LocationManagerDummy()))
        .environmentObject(RouteViewModel( locationManager: LocationManagerDummy()))
        .environmentObject(SearchViewModel())
}
