//
//  LandingPageViewModel.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 7.12.2024.
//

import Foundation
import FirebaseAuth


class LandingPageViewModel:ObservableObject{
    @Published var currentUserId:String = ""
    
    init(){
        Auth.auth().addStateDidChangeListener { [weak self] _,user in
            DispatchQueue.main.async {
                self?.currentUserId = user?.uid ?? ""
            }
        }
    }
    
    public var isSignedIn:Bool {
        
        return Auth.auth().currentUser != nil
    }
    
}
