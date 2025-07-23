//
//  FavoritesPreviewView.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 24.10.2024.
//

import SwiftUI

struct FavoritesPreviewView: View {
    @EnvironmentObject var languageManager:LanguageManager
    var body: some View {
        HStack{
            Spacer()
            
            VStack{
                
                Image("taskView")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250,height: 250)
                    .opacity(0.6)
                
                Label("No Favorite Place Yet".addLocalizableString(str: languageManager.language), systemImage: "list.bullet.rectangle.portrait")
                    .foregroundStyle(Color(.systemGray))
                    .padding(.bottom,7)
                
                Text("If you search for a place, it will be added to your favorites list.".addLocalizableString(str: languageManager.language))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color(.systemGray))
                
                
            }
          
            Spacer()
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    FavoritesPreviewView()
        .environmentObject(RouteViewModel( locationManager: LocationManagerDummy()))
        .environmentObject(SearchViewModel())
        .environmentObject(MapViewModel(locationManager: LocationManagerDummy()))
        .environmentObject(LocationManagerDummy())
}
