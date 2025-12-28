//
//  AdminManager.swift
//  moers festival
//
//  Created by Lennart Fischer on 03.04.18.
//  Copyright © 2018 CodeForNiederrhein. All rights reserved.
//

import UIKit
//import FirebaseMessaging

class AdminManager {

    static let shared = AdminManager()
    
    private let authKey = "key=AAAAdxkghAM:APA91bE9OLFvyz-_O042_O7921GFMoNgiBCxCNlWy8SFiQr1mZ7vRn0fRiV6zdHd7OVSj_NNYHoM9UogBEcub6oUBU-uOEyJJEnwsOwgnORjOM8JW8zZCRXYt271xUySMUaUP4mnTSB3"
    
    public var isAdmin: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "UserIsAdmin")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "UserIsAdmin")
        }
    }
    
    func login(with password: String) -> Bool {
        
        if password == "J2TH6dQa" {
            
            isAdmin = true
            
            return true
            
        } else {
            
            return false
            
        }
        
    }
    
    func sendPushMessage(title: String, text: String) {
        
        guard let url = URL(string: "https://fcm.googleapis.com/fcm/send") else { return }
        var request = URLRequest(url: url)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(authKey, forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        let postString = "{ \"notification\": { \"title\": \"\(title)\", \"text\": \"\(text)\" }, \"to\" : \"/topics/all\" }"
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            guard let data = data, error == nil else { return }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")

            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print(responseString)
            }
            
        }
        
        task.resume()
        
    }
    
}
