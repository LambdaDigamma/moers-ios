//
//  TwitterManager.swift
//  Moers
//
//  Created by Lennart Fischer on 24.06.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation
import TwitterKit

protocol TwitterManagerDelegate: AnyObject {
    
    func receivedTweets(tweets: [TWTRTweet])
    
}

struct NewsManager {
    
    static var shared = NewsManager()
    
    private let client = TWTRAPIClient()
    
    public weak var delegate: TwitterManagerDelegate?
    
    public func getTweets() {
        
        var clientError: NSError?
        let params: [String: String] = [:]
        let request = client.urlRequest(
            withMethod: "GET",
            urlString: "https://api.twitter.com/1.1/lists/statuses.json?slug=MeinMoers&owner_screen_name=LambdaDigamma&include_rts=false&count=100",
            parameters: params,
            error: &clientError
        )
        
        var tweets: [TWTRTweet] = []
        
        client.sendTwitterRequest(request) { (_, data, error) in
            
            if let error = error {
                
                print(error.localizedDescription)
                
                self.delegate?.receivedTweets(tweets: tweets)
                
                return
                
            }
            
            do {
                
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [AnyHashable: Any]
                
                for jsonTweet in json {

                    let tweet = TWTRTweet(jsonDictionary: jsonTweet)!

                    tweets.append(tweet)

                }

                let ids = tweets.map { $0.tweetID }
                
                self.client.loadTweets(withIDs: ids, completion: { (tweets, error) in
                    
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    
                    self.delegate?.receivedTweets(tweets: tweets ?? [])
                    
                })
                
            } catch let jsonError as NSError {
                print("json error: \(jsonError.localizedDescription)")
            }
            
        }
        
    }
    
}
