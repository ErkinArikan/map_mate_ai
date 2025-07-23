//
//  CustomAnnotationView.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 15.10.2024.
//

import SwiftUI

struct CustomAnnotationView: View {
    @State var iconName:String? = nil
    @State var iconColor:Color = .white
    
    var body: some View {
        ZStack{
            Circle()
                .frame(width:40,height:40)
                .foregroundStyle(iconColor.opacity(0.25))
            
            Circle()
                .frame(width:30,height:30)
                .foregroundStyle(.white)
            
            Image(systemName: iconName ?? "questionmark.circle.fill")
                .resizable()
                .frame(width:20,height:20)
                .foregroundStyle(iconColor)
           
        }
        
    }
}

#Preview {
    CustomAnnotationView()
}
