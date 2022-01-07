//
//  NewsManager.swift
//  Moers
//
//  Created by Lennart Fischer on 24.06.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation
//import TwitterKit
import FeedKit

protocol NewsManagerDelegate: AnyObject {
    
//    func receivedTweets(tweets: [TWTRTweet])
    
}

struct NewsManager {
    
    static var shared = NewsManager()
    
//    private let client = TWTRAPIClient()
    
    public weak var delegate: NewsManagerDelegate?
    
//    public func getTweets() {
//
//        var clientError: NSError?
//        let params: [String: String] = [:]
//        let request = client.urlRequest(
//            withMethod: "GET",
//            urlString: "https://api.twitter.com/1.1/lists/statuses.json?slug=MeinMoers&owner_screen_name=LambdaDigamma&include_rts=false&count=100",
//            parameters: params,
//            error: &clientError
//        )
//
//        var tweets: [TWTRTweet] = []
//
//        client.sendTwitterRequest(request) { (_, data, error) in
//
//            if let error = error {
//
//                print(error.localizedDescription)
//
//                self.delegate?.receivedTweets(tweets: tweets)
//
//                return
//
//            }
//
//            do {
//
//                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [[AnyHashable: Any]]
//
//                for jsonTweet in json {
//
//                    let tweet = TWTRTweet(jsonDictionary: jsonTweet)!
//
//                    tweets.append(tweet)
//
//                }
//
//                let ids = tweets.map { $0.tweetID }
//
//                self.client.loadTweets(withIDs: ids, completion: { (tweets, error) in
//
//                    if let error = error {
//                        print(error.localizedDescription)
//                    }
//
//                    self.delegate?.receivedTweets(tweets: tweets ?? [])
//
//                })
//
//            } catch let jsonError as NSError {
//                print("json error: \(jsonError.localizedDescription)")
//            }
//
//        }
//
//    }
    
    public func getRheinischePost(completion: @escaping ((Error?, RSSFeed?) -> Void)) {
        
        guard let feedURL = URL(string: "https://rp-online.de/nrw/staedte/moers/feed.rss") else { return }
        
        let parser = FeedParser(URL: feedURL)
        
        parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { (result) in
            
            switch result {
                case .success(let feed):
                    DispatchQueue.main.async {
                        completion(nil, feed.rssFeed)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
            }
            
        }
        
    }
    
    public func getLokalkompass(completion: @escaping ((Error?, RSSFeed?) -> Void)) {
        
        guard let feedURL = URL(string: "https://www.lokalkompass.de/feed/action/mode/realm/ID/35/") else { return }
        
        let parser = FeedParser(URL: feedURL)
        
        parser.parseAsync(queue: .global(qos: .userInitiated)) { (result) in
            
            switch result {
                case .success(let feed):
                    DispatchQueue.main.async {
                        completion(nil, feed.rssFeed)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
            }
            
        }
        
    }
    
    public func getNRZ(completion: @escaping ((Error?, RSSFeed?) -> Void)) {
        
        guard let feedURL = URL(string: "https://www.nrz.de/?config=rss_moers_app") else { return }
        
        let parser = FeedParser(URL: feedURL)
        
        parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { (result) in
            
            switch result {
                case .success(let feed):
                    DispatchQueue.main.async {
                        completion(nil, feed.rssFeed)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
            }
            
        }
        
    }
    
}
