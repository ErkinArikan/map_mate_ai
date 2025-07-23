//
//  IllusturationRowView.swift
//  MapUITestingApp
//
//  Created by Erkin Arikan on 4.12.2024.
//

import SwiftUI
import SDWebImageSwiftUI
import Lottie

struct IllusturationRowView: View {
    var ilusturation:IlusturationModel
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    
    let animationView = LottieAnimationView(name: "")
    @EnvironmentObject var languageManager:LanguageManager
    @State var isAnimating:Bool = false
    //MARK: - BODY
    var body: some View{
        
        VStack(alignment:.leading, spacing:20){

//            LottieView2(lottiFile: ilusturation.imageName).frame(width: 300, height: 240)
            Image(ilusturation.imageName)
                .resizable()
                .scaledToFit()
                
                .frame(width: 300, height: 240)
            
            
            Text(ilusturation.name.addLocalizableString(str: languageManager.language))
                .font(.system(size: 20))
                .fontWeight(.medium)
                .foregroundStyle(Color.white)
                .multilineTextAlignment(.leading)
            
         
            
            Text(ilusturation.description.addLocalizableString(str: languageManager.language))
                .foregroundStyle(Color.white)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
              
            
            
        }
        .frame(maxHeight: 450)
        .padding()
        .padding(.bottom,22)
        .cornerRadius(30)
        .background(Color.hex("0C7B93").opacity(0.8))
        .cornerRadius(20)
        .padding()
        .shadow(color: Color(UIColor.black).opacity(0.3), radius: 20,x:0,y:20)
        .onAppear(perform: {
        isAnimating = true
        })
    
        
    } //:Body

}

#Preview {
    IllusturationRowView(ilusturation: IlusturationModel.sampleIllustration)
}


//
//struct LottieView: UIViewRepresentable {
//    var name: String
//    @Binding var isAnimating: Bool
//
//    func makeUIView(context: Context) -> AnimationView {
//        let animationView = AnimationView(name: name)
//        animationView.loopMode = .loop
//        animationView.play()
//        return animationView
//    }
//
//    func updateUIView(_ uiView: AnimationView, context: Context) {
//        if isAnimating {
//            uiView.play()
//        } else {
//            uiView.stop()
//        }
//    }
//}
