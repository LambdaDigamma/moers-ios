//
//  UserManager.swift
//  Moers
//
//  Created by Lennart Fischer on 25.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation
import Core

public class UserManager {
    
    static let shared = UserManager()
    
    private let kUserType = "userType"
    private let kUserName = "userName"
    private let kUserID = "userID"
    private let kDescription = "userDescription"
    
    public init() {
        
    }
    
    var user: User {
        return loadUser()
    }
    
    var loggedIn: Bool {
        return UserDefaults.standard.integer(forKey: kUserID) != 0 && UserDefaults.standard.string(forKey: kUserName) != nil
    }
    
    func register(_ user: User) {
        
        UserDefaults.standard.set(user.type.rawValue, forKey: kUserType)
        UserDefaults.standard.set(user.name, forKey: kUserName)
        UserDefaults.standard.set(user.id, forKey: kUserID)
        UserDefaults.standard.set(user.description, forKey: kDescription)
        
    }
    
    private func loadUser() -> User {
        
        let userTypeString = UserDefaults.standard.string(forKey: kUserType) ?? "tourist"
        let userName = UserDefaults.standard.string(forKey: kUserName)
        let userID = UserDefaults.standard.integer(forKey: kUserID)
        let userDescription = UserDefaults.standard.string(forKey: kDescription)
        
        let userType = User.UserType(rawValue: userTypeString) ?? .tourist
        
        let user = User(type: userType, id: userID, name: userName, description: userDescription)
        
        return user
        
    }
    
    public var theme: ApplicationTheme {
        get {
            
            return ApplicationTheme.current
            
        }
        set {
//            UserDefaults.standard.set(newValue.identifier, forKey: "Theme")
        }
    }
    
    public func getID() {
        
        let endpoint = AppEnvironment.rootURL + "api/v1/user/new"
        
        guard let url = URL(string: endpoint) else { return }
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        Task {
            await loadAndRegisterRemoteID(request: request)
        }
        
    }

    private func loadAndRegisterRemoteID(request: URLRequest) async {

        do {

            let (data, _) = try await URLSession.shared.data(for: request)

            guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] else { return }

            let id = json["id"] as? Int
            var user = loadUser()

            user.id = id ?? -1

            register(user)

        } catch {
            print(error.localizedDescription)
        }

    }
    
    public func nextRubbishActivity() -> NSUserActivity {
        
        let activity = NSUserActivity(activityType: Self.rubbishScheduleActivityIdentifier)
        
        if #available(iOS 12.0, *) {
            activity.isEligibleForPrediction = true
            activity.suggestedInvocationPhrase = "Nächste Abholtermine"
            activity.persistentIdentifier = "de.okfn.niederrhein.Moers.nextRubbish"
        }
        
        activity.isEligibleForPublicIndexing = true
        activity.isEligibleForSearch = true
        activity.keywords = ["Müll", "Moers"]
        activity.title = "Nächste Abholtermine"
        
        return activity
        
    }
    
    public static let rubbishScheduleActivityIdentifier = "de.okfn.niederrhein.Moers.nextRubbish"
    
}
