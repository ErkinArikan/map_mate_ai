//
//  ilusturationModel.swift
//  AtilimKariyerApp
//
//  Created by Erkin Arikan on 13.03.2024.
//

import Foundation

struct IlusturationModel:Identifiable,Equatable {
    let id = UUID()
    var name:String
    var description:String
    var imageName:String
    var tag:Int
    
    static var sampleIllustration = IlusturationModel(name: "Sample Text", description: "This is a sample description for purpose of debugging", imageName: "firstJ", tag: 0)
    
    static var sampleIllustrations:[IlusturationModel]  = [
//        IlusturationModel(name: "Hayal Ettiğiniz Her Yerde Olun!", description: "İstediğiniz her yere kolayca ulaşın. Hedefinizi seçin, gerisini bize bırakın!", imageName: "firstJ", tag: 0) ,
//        
//        IlusturationModel(name: "Kafeden Hastaneye, İhtiyacınız Olan Her Şey!", description: "Etrafınızdaki tüm mekanları anında keşfedin. Aramadan bulun, zaman kazanın!", imageName: "aiJ", tag: 1),
//        
//        IlusturationModel(name: "Sevdiğiniz Yerleri Bir Araya Getirin!", description: "Gittiğiniz yerleri favorileyin ve tek dokunuşla ulaşın. Her anınız daha özel olsun!", imageName: "aiJ", tag: 2),
//        
//        IlusturationModel(name: "\"Bu Akşam Nereye Gitsek?\" Sorun Olmaktan Çıktı!", description: "Özel asistanınızla mekanları keşfedin, sorularınıza anında yanıt alın. Size en yakın yol arkadaşınız!", imageName: "chatJ", tag: 3),
//        
//        IlusturationModel(name: "Fikriniz Bizim İçin Değerli!", description: "Geri bildirimlerinizle gelişiyoruz. Düşüncelerinizi paylaşın, birlikte daha iyisini yapalım!", imageName: "feedbackJ", tag: 4)
        
        
        
//        IlusturationModel(name: "Hayal Ettiğiniz Her Yerde Olun!", description: "İstediğiniz her yere kolayca ulaşın. Hedefinizi seçin, gerisini bize bırakın!", imageName: "1", tag: 0) ,
//        
//        IlusturationModel(name: "Kafeden Hastaneye, İhtiyacınız Olan Her Şey!", description: "Etrafınızdaki tüm mekanları anında keşfedin. Aramadan bulun, zaman kazanın!", imageName: "2", tag: 1),
//        
//        IlusturationModel(name: "Sevdiğiniz Yerleri Bir Araya Getirin!", description: "Gittiğiniz yerleri favorileyin ve tek dokunuşla ulaşın. Her anınız daha özel olsun!", imageName: "3", tag: 2),
//        
//        IlusturationModel(name: "\"Bu Akşam Nereye Gitsek?\" Sorun Olmaktan Çıktı!", description: "Özel asistanınızla mekanları keşfedin, sorularınıza anında yanıt alın. Size en yakın yol arkadaşınız!", imageName: "4", tag: 3),
//        
//        IlusturationModel(name: "Fikriniz Bizim İçin Değerli!", description: "Geri bildirimlerinizle gelişiyoruz. Düşüncelerinizi paylaşın, birlikte daha iyisini yapalım!", imageName: "5", tag: 4)
        IlusturationModel(name: "Be Anywhere You Imagine!", description: "Easily reach anywhere you desire. Choose your destination, and leave the rest to us!", imageName: "1", tag: 0),
       
        IlusturationModel(name: "From Cafes to Hospitals, Everything You Need!", description: "Instantly discover all the places around you. Find without searching, save time!", imageName: "2", tag: 1),

        IlusturationModel(name: "Bring Together Your Favorite Places!", description: "Favorite the places you've been to and access them with a single touch. Make every moment more special!", imageName: "3", tag: 2),
        IlusturationModel(name: "Find On-Duty Pharmacies Instantly!",
                          description: "Need a pharmacy at any hour? With our on-duty pharmacy feature, find the nearest open pharmacy anytime, anywhere, hassle-free!",
                          imageName: "pharmacy",
                          tag: 3),


        IlusturationModel(name: "\"Where Should We Go Tonight?\" Is No Longer a Problem!", description: "Discover places with your personal assistant and get instant answers to your questions. Your closest companion on the road!", imageName: "4", tag: 4),

        IlusturationModel(name: "Your Feedback Matters to Us!", description: "We improve with your feedback. Share your thoughts and let’s create something better together!", imageName: "5", tag: 5)

    ]
        
    
   
}
