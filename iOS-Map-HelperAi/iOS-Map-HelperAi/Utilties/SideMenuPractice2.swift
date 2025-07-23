//
//  SideMenuPractice2.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 22.10.2024.
//

import SwiftUI

struct SideMenuView: View {
    @EnvironmentObject var vm:MapViewModel
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Binding var isShowing:Bool
    var body: some View {
        ZStack{
            if isShowing{
//                Rectangle()
//                    .opacity(0.3)
//                    .ignoresSafeArea()
//                    .onTapGesture {
//                        withAnimation {
//                            isShowing.toggle()
//                        }
//                        
//                    }
                
                HStack{
                    VStack(alignment:.leading){
                        HStack {
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20,height: 20)
                                .foregroundStyle(.black)
                                .padding(7)
                                .background(Color.white)
                                .clipShape(Circle())
                                .padding()
                            
                            Spacer()
                            
                            Button {
                                withAnimation {
                                    vm.sideMenuShow.toggle()
                                    vm.activeSheet = .search
                                }
                                
                            } label: {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(Color("TextColor"))
                                    .fontWeight(.medium)
                                    .frame(width: 20,height: 20)
                            }
                            .padding(.trailing)

                        }
                        
                        Spacer()
                        
                        Toggle("Dark Mode", isOn: $isDarkMode)
                            .padding()
                            .foregroundStyle(Color("TextColor"))
                      
                        
                    } //:VStack
                    
                    .frame(maxWidth: 200,maxHeight: .infinity,alignment: .leading)
                  
                    .foregroundStyle(.white)
                    
                    .background(Color(.systemGray6))
                    
                 
                    
                    Spacer()
                }//:HStack
                .transition(.move(edge: .leading))
               
            } //:if
        }//:ZStack
        .animation(.spring, value: isShowing)
        
    }
}

#Preview {
    SideMenuView(isShowing: .constant(true))
}
