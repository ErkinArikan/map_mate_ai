//
//  LottieView2.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 22.12.2024.
//

import SwiftUI
import Lottie

struct LottieView2: UIViewRepresentable {
  
    
    let lottiFile:String
    let animationView = LottieAnimationView()
    
    func makeUIView(context: Context) -> some UIView{
        let view = UIView(frame: .zero)
        animationView.animation = LottieAnimation.named(lottiFile)
        animationView.play()
        animationView.loopMode = .loop
        animationView.backgroundBehavior = .stop
        view.addSubview(animationView)
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.heightAnchor.constraint(equalTo:view.heightAnchor).isActive = true
        animationView.widthAnchor.constraint(equalTo:view.widthAnchor).isActive = true
        animationView.animationSpeed = 1
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}


