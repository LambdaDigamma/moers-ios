//
//  API.swift
//  Moers
//
//  Created by Lennart Fischer on 14.09.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit
import CoreLocation
import InfoKit
import Reachability
import MMAPI

class API: NSObject, XMLParserDelegate {

    static let shared = API()
    
    private let reachability = Reachability()!
    
    private var session = URLSession.shared
    private var xmlBuffer = String()
    private var valueBuffer: [String: AnyObject]? = [:]
    
    private var parkingLots: [ParkingLot] = []
    
    public var cachedParkingLots: [ParkingLot] = []
    public var cachedCameras: [Camera] = []
    public var cachedBikeCharger: [BikeChargingStation] = []
    
    override private init() {
        session = URLSession.shared
    }
    
    public func login(email: String, password: String, completion: @escaping ((Error?) -> Void)) {
        
        let params = ["grant_type": "password",
                      "client_id": "\(Environment.clientID)",
                      "client_secret": Environment.clientSecret,
                      "username": email,
                      "password": password,
                      "scope": "*"]
        
        if reachability.connection != .none {
            
            guard let url = URL(string: Environment.rootURL + "oauth/token") else {
                completion(APIError.noConnection)
                return
            }
            
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = "POST"
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            } catch let error {
                print(error.localizedDescription)
            }
            
            let task = session.dataTask(with: request) { (data, response, error) in
                
                guard error == nil else {
                    completion(error)
                    return
                }
                
                guard let data = data else {
                    completion(APIError.noData)
                    return
                }
                
                do {
                    
                    guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] else { completion(APIError.noData); return }
                    
                    guard let _ = json["token_type"] as? String else { completion(APIError.noData); return }
                    guard let _ = json["expires_in"] as? Int else { completion(APIError.noData); return }
                    guard let accessToken = json["access_token"] as? String else { completion(APIError.noData); return }
                    guard let refreshToken = json["refresh_token"] as? String else { completion(APIError.noData); return }
                    
                    self.token = accessToken
                    self.refreshToken = refreshToken
                    
                    completion(nil)
                    
                } catch {
                    completion(error)
                }
                
            }
            
            task.resume()
            
        } else {
            completion(APIError.noConnection)
        }
        
    }
    
    public func register(name: String, email: String, password: String, completion: @escaping ((Error?) -> Void)) {
        
        if reachability.connection != .none {
            
            guard let url = URL(string: Environment.rootURL + "api/v1/register") else {
                completion(APIError.noConnection)
                return
            }
            
            let params = ["name": name,
                          "email": email,
                          "password": password]

            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = "POST"
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            } catch let error {
                print(error.localizedDescription)
            }
            
            let task = session.dataTask(with: request) { (data, response, error) in
                
                guard error == nil else {
                    completion(error)
                    return
                }
                
                guard let data = data else {
                    completion(APIError.noData)
                    return
                }
                
                do {
                    
                    guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] else { completion(APIError.noData); return }
                    
                    print(json)
                    
                    completion(nil)
                    
                } catch {
                    completion(error)
                }
                
            }
            
            task.resume()
            
        } else {
            completion(APIError.noConnection)
        }
        
    }
    
    public func getUser(completion: @escaping ((Error?, User?) -> Void)) {
        
        if reachability.connection != .none {
            
            guard let token = token else { completion(APIError.noToken, nil); return }
            
            guard let url = URL(string: Environment.rootURL + "api/v1/user") else {
                completion(APIError.noConnection, nil)
                return
            }
            
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let task = session.dataTask(with: request) { (data, response, error) in
                
                guard error == nil else {
                    completion(error, nil)
                    return
                }
                
                guard let data = data else {
                    completion(APIError.noData, nil)
                    return
                }
                
                do {
                    
                    guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] else { completion(APIError.noData, nil); return }
                    
                    print(json)
                    
                    var storedUser = UserManager.shared.user
                    
                    storedUser.name = json["name"] as? String
                    storedUser.id = json["id"] as? Int
                    storedUser.description = json["description"] as? String
                    
                    completion(nil, storedUser)
                    
                } catch {
                    completion(error, nil)
                }
                
            }
            
            task.resume()
            
        } else {
            completion(APIError.noConnection, nil)
        }
        
    }
    
    public func storeShop(shopEntry: ShopEntry, completion: @escaping ((Error?, Bool?) -> Void)) {
        
        if reachability.connection != .none {
            
//            guard let token = token else { completion(APIError.noToken, nil); return }
            
            guard let url = URL(string: Environment.rootURL + "api/v1/shops") else {
                completion(APIError.noConnection, nil)
                return
            }
            
            let data: [String: Any] = ["secret": "tzVQl34i6SrYSzAGSkBh",
                                       "name": shopEntry.title,
                                       "branch": shopEntry.branch,
                                       "street": shopEntry.street,
                                       "house_number": shopEntry.houseNr,
                                       "postcode": shopEntry.postcode,
                                       "place": shopEntry.place,
                                       "lat": shopEntry.coordinate.latitude,
                                       "lng": shopEntry.coordinate.longitude,
                                       "url": shopEntry.website ?? "",
                                       "phone": shopEntry.phone ?? "",
                                       "monday": shopEntry.monday ?? "",
                                       "tuesday": shopEntry.tuesday ?? "",
                                       "wednesday": shopEntry.wednesday ?? "",
                                       "thursday": shopEntry.thursday ?? "",
                                       "friday": shopEntry.friday ?? "",
                                       "saturday": shopEntry.saturday ?? "",
                                       "sunday": shopEntry.sunday ?? "",
                                       "other": shopEntry.other ?? ""]
            
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = "POST"
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            } catch {
                print(error.localizedDescription)
            }
            
            let task = session.dataTask(with: request) { (data, response, error) in
                
                guard error == nil else {
                    completion(error, nil)
                    return
                }
                
                guard let data = data else {
                    completion(APIError.noData, nil)
                    return
                }
                
                do {
                    
                    guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] else { completion(APIError.noData, nil); return }
                    
                    print(json)
                    
                    completion(nil, true)
                    
                } catch {
                    completion(error, false)
                }
                
            }
            
            task.resume()
            
        } else {
            completion(APIError.noConnection, nil)
        }
        
    }
    
    func loadBikeChargingStations() {
        
        
        
    }
    
    private let kToken = "token"
    private let kRefreshToken = "refreshToken"
    
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: kToken)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: kToken)
        }
    }
    
    var refreshToken: String? {
        get {
            return UserDefaults.standard.string(forKey: kRefreshToken)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: kRefreshToken)
        }
    }
    
}
