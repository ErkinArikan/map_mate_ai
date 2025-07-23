//
//  UserModel.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 27.11.2024.
//

import Foundation
struct UserModel:Codable{
    let id :String
    var name:String
    var email:String
    var favoritesPlaces: [FavoritePlaceModel]
    var userPromptLimit:Int = 5
    var joined:TimeInterval
    var userAgreement:Bool

    var messages: [MessageModelCodable] = [] // Firestore ile uyumlu MessageModel dizisi

    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "email": email,
            "favoritesPlaces": favoritesPlaces.map { $0.toDictionary() },
            "userPromptLimit": userPromptLimit, // Bu alan eklendi mi kontrol edin
            "joined": joined,
            "userAgreement": userAgreement,
            "messages": messages.map { $0.toDictionary() }
        ]
    }


    static func fromDictionary(_ dictionary: [String: Any]) -> UserModel? {
            guard
                let id = dictionary["id"] as? String,
                let name = dictionary["name"] as? String,
                let email = dictionary["email"] as? String,
                let joined = dictionary["joined"] as? TimeInterval,
                let userAgreement = dictionary["userAgreement"] as? Bool
            else {
                print("❌ Kullanıcı verisinde eksik alanlar var: \(dictionary)")
                return nil
            }

            let userPromptLimit = dictionary["userPromptLimit"] as? Int ?? 3

            let favoritesArray = dictionary["favoritesPlaces"] as? [[String: Any]] ?? []
            let favoritesPlaces = favoritesArray.compactMap { FavoritePlaceModel.fromDictionary($0) } // ✅ Favori yerleri parse et
            
            let messagesArray = dictionary["messages"] as? [[String: Any]] ?? []
            let messages = messagesArray.compactMap { MessageModelCodable.fromDictionary($0) }

            return UserModel(
                id: id,
                name: name,
                email: email,
                favoritesPlaces: favoritesPlaces,
                userPromptLimit: userPromptLimit,
                joined: joined,
                userAgreement: userAgreement,
                messages: messages
            )
        }

}


struct MessageModelCodable: Codable {
    var id: String // UUID yerine String (Firestore için)
    var isInteracting: Bool
    var sendImage: String
    var send: MessageTypeCodable
    var responseImage: String
    var response: MessageTypeCodable?
    var responseError: String?

    func toDictionary() -> [String: Any] {
        var dictionary: [String: Any] = [
            "id": id,
            "isInteracting": isInteracting,
            "sendImage": sendImage,
            "send": send.toDictionary(),
            "responseImage": responseImage,
            "responseError": responseError ?? ""
        ]
        if let response = response {
            dictionary["response"] = response.toDictionary()
        }
        return dictionary
    }

    static func fromDictionary(_ dictionary: [String: Any]) -> MessageModelCodable? {
        guard
            let id = dictionary["id"] as? String,
            let isInteracting = dictionary["isInteracting"] as? Bool,
            let sendImage = dictionary["sendImage"] as? String,
            let sendDict = dictionary["send"] as? [String: Any],
            let send = MessageTypeCodable.fromDictionary(sendDict),
            let responseImage = dictionary["responseImage"] as? String
        else {
            print("Eksik veya hatalı mesaj alanı: \(dictionary)")
            return nil
        }

        let response = (dictionary["response"] as? [String: Any]).flatMap { MessageTypeCodable.fromDictionary($0) }
        let responseError = dictionary["responseError"] as? String

        return MessageModelCodable(
            id: id,
            isInteracting: isInteracting,
            sendImage: sendImage,
            send: send,
            responseImage: responseImage,
            response: response,
            responseError: responseError
        )
    }

}
struct MessageTypeCodable: Codable {
    var type: String
    var text: String

    func toDictionary() -> [String: Any] {
        return ["type": type, "text": text]
    }

    static func fromDictionary(_ dictionary: [String: Any]) -> MessageTypeCodable? {
        guard let type = dictionary["type"] as? String, let text = dictionary["text"] as? String else {
            return nil
        }
        return MessageTypeCodable(type: type, text: text)
    }
}

extension MessageModel {
    func toCodable() -> MessageModelCodable {
        return MessageModelCodable(
            id: id.uuidString,
            isInteracting: isInteracting,
            sendImage: sendImage,
            send: MessageTypeCodable(type: "text", text: send.text),
            responseImage: responseImage,
            response: response.map { MessageTypeCodable(type: "text", text: $0.text) },
            responseError: responseError
        )
    }
}

extension MessageModelCodable {
    func toMessageModel() -> MessageModel {
        return MessageModel(
            isInteracting: isInteracting,
            sendImage: sendImage,
            send: .simpleText(send.text),
            responseImage: responseImage,
            response: response.map { .simpleText($0.text) },
            responseError: responseError,
            attributedResponse: nil // Firestore'da `NSAttributedString` desteği olmadığı için manuel eklenebilir.
        )
    }
}

struct FavoritePlaceModel: Codable {
    var il: String
    var ilce: String
    var lat: Double
    var lon: Double
    var poiadi: String
    var timestamp: TimeInterval // Firestore timestamp’i için
    
    func toDictionary() -> [String: Any] {
        return [
            "il": il,
            "ilce": ilce,
            "lat": lat,
            "lon": lon,
            "poiadi": poiadi,
            "timestamp": timestamp
        ]
    }
    
    static func fromDictionary(_ dictionary: [String: Any]) -> FavoritePlaceModel? {
        guard
            let il = dictionary["il"] as? String,
            let ilce = dictionary["ilce"] as? String,
            let lat = dictionary["lat"] as? Double,
            let lon = dictionary["lon"] as? Double,
            let poiadi = dictionary["poiadi"] as? String,
            let timestamp = dictionary["timestamp"] as? TimeInterval
        else {
            print("❌ Favori yer eksik alanlar: \(dictionary)")
            return nil
        }
        
        return FavoritePlaceModel(il: il, ilce: ilce, lat: lat, lon: lon, poiadi: poiadi, timestamp: timestamp)
    }
}
