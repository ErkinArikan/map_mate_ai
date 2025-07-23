//
//  IllusturationListView.swift
//  MapUITestingApp
//
//  Created by Erkin Arikan on 4.12.2024.
//

import SwiftUI

struct IllusturationListView: View {
    
    @AppStorage("isOnTutorial") var isOnTutorial:Bool = true
    @State private var pageIndex = 0
    private let ilusturations: [IlusturationModel] = IlusturationModel.sampleIllustrations
    private let dotAppearance = UIPageControl.appearance()

    @State private var isAnimating: Bool = false
    @State private var navigateToWelcome: Bool = false // New state for navigation
    let haptic = UIImpactFeedbackGenerator(style: .soft)
    @EnvironmentObject var languageManager:LanguageManager
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6).ignoresSafeArea(.all)
                TabView(selection: $pageIndex) {
                    ForEach(ilusturations) { page in
                        VStack {
                            Spacer()
                            IllusturationRowView(ilusturation: page)
                            Spacer()
                            if page == ilusturations.last {
                                // "Home" Button
                                Button {
                                    withAnimation {
                                        navigateToWelcome = true // Trigger navigation
                                        isOnTutorial = false
                                        haptic.impactOccurred()
                                    }
                                } label: {
                                    HStack {
                                        Text("Home".addLocalizableString(str: languageManager.language))
                                    }
                                    .padding()
                                    .padding(.horizontal)
                                    .foregroundStyle(.white)
                                    .background(Color("Mor"))
                                    .mask(RoundedRectangle(cornerRadius: 13))
                                }
                                .shadow(color: Color(UIColor.black).opacity(0.3), radius: 10,x:0,y:20)
                            } else {
                                // "Next" Button
                                Button {
                                    withAnimation {
                                        incrementPage()
                                        haptic.impactOccurred()
                                    }
                                } label: {
                                    HStack {
                                        Text("Next".addLocalizableString(str: languageManager.language))
                                        Image(systemName: "arrow.right")
                                    }
                                    .padding()
                                    .padding(.horizontal)
                                    .foregroundStyle(.white)
                                    .background(Color.hex("0C7B93").opacity(0.8))
                                    .mask(RoundedRectangle(cornerRadius: 13))
                                }
                                .shadow(color:.black,radius:1)
                                .offset(y: isAnimating ? 0 : 50)
                                .animation(.spring(), value: isAnimating)
                            }
                            
                            Spacer()
                            Spacer()
                        }
                        .tag(page.tag)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            withAnimation {
                                isOnTutorial = false
                            }
                        } label: {
                            Text("Skip".addLocalizableString(str: languageManager.language))
                                .fontWeight(.medium)
                                .foregroundStyle(Color.hex("0C7B93").opacity(0.8))
                        }
                        .padding(.horizontal)
                    }
                    
                    ToolbarItem(placement: .topBarLeading) {
                        DarkLightModeButton(hexStringDark: "0C7B93", hexStringLight: "0C7B93")
                    }
                }
                .animation(.easeInOut, value: pageIndex)
                .indexViewStyle(.page(backgroundDisplayMode: .interactive))
                .tabViewStyle(PageTabViewStyle())
                .onAppear {
                    isAnimating = true
                    dotAppearance.currentPageIndicatorTintColor = .black
                    dotAppearance.pageIndicatorTintColor = .gray
                }
            }

        }
    }
    
    func incrementPage() {
        pageIndex += 1
    }
}


#Preview {
    IllusturationListView()
}
