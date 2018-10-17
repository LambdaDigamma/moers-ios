//
//  NewsManager.swift
//  Moers
//
//  Created by Lennart Fischer on 24.06.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation
import TwitterKit
import FeedKit

protocol NewsManagerDelegate {
    
    func receivedTweets(tweets: [TWTRTweet])
    
}

struct NewsManager {
    
    static var shared = NewsManager()
    
    private let client = TWTRAPIClient()
    
    public var delegate: NewsManagerDelegate? = nil
    
    public func getTweets() {
        
        var clientError: NSError?
        let params: [String: String] = [:]
        let request = client.urlRequest(withMethod: "GET", urlString: "https://api.twitter.com/1.1/lists/statuses.json?slug=MeinMoers&owner_screen_name=LambdaDigamma&include_rts=false&count=100", parameters: params, error: &clientError)
        
        var tweets: [TWTRTweet] = []
        
        client.sendTwitterRequest(request) { (response, data, error) in
            
            if let error = error {
                
                print(error.localizedDescription)
                
                self.delegate?.receivedTweets(tweets: tweets)
                
                return
                
            }
            
            do {
                
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! Array<[AnyHashable: Any]>
                
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
    
    public func getRSS() {
        
//        guard let feedURL = URL(string: "https://rp-online.de/nrw/staedte/moers/feed.rss") else { return } // RP Online Moers
        guard let feedURL = URL(string: "https://www.lokalkompass.de/feed/action/mode/realm/ID/35/") else { return } // Lokalkompass
        
        let parser = FeedParser(URL: feedURL)
        
        parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { (result) in
            
            guard let feed = result.rssFeed else { return }
            
            feed.items?.forEach { print($0.pubDate) }
            
            DispatchQueue.main.async {
                // ..and update the UI
            }
        }
        
        
    }
    
}
