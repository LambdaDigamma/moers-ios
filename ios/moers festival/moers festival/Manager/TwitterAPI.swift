//
//  TwitterAPI.swift
//  moers festival
//
//  Created by Lennart Fischer on 17.03.18.
//  Copyright © 2018 CodeForNiederrhein. All rights reserved.
//

import UIKit
//import TwitterKit
import Combine

//class TwitterAPI {
//
//    static let shared: TwitterAPI = TwitterAPI()
//
//    private let consumerKey = "K42rlEyEyNlYuAFuVfU3vyLVz"
//    private let consumerSecret = "E44M4hYP1NuAM1pbK1BTjLZaBLNQ9JUICCHaxdHxiHbOd8FbHN"
//
//    private let moersFestivalUserID = "25681559"
//    private let client = TWTRAPIClient()
//
//    public func fetchTweets(completion: @escaping (Result<[TWTRTweet], Error>) -> ()) {
//
//        var clientError: NSError?
//        let params = ["id": moersFestivalUserID]
//        let request = client.urlRequest(withMethod: "GET", urlString: "https://api.twitter.com/1.1/statuses/user_timeline.json?include_rts=false", parameters: params, error: &clientError)
//
//        client.sendTwitterRequest(request) { (response, data, error) in
//
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//
//            guard let data = data else {
//                completion(.failure(APIError.noData))
//                return
//            }
//
//            do {
//
//                let json = try JSONSerialization.jsonObject(with: data, options: []) as! Array<[AnyHashable: Any]>
//
//                var tweets: [TWTRTweet] = []
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
//                        completion(.failure(error))
//                        return
//                    }
//
//                    var tweets = tweets ?? []
//
////                    tweets.sort(by: { $0.date > $1.date })
//
//                    completion(.success(tweets))
//
//                })
//
//            } catch {
//                completion(.failure(error))
//            }
//
//        }
//
//    }
//
//    public func fetchSocialTweets(completion: @escaping (Result<[TWTRTweet], Error>) -> ()) {
//
//        var clientError: NSError?
//        let request = client.urlRequest(withMethod: "GET", urlString: "https://api.twitter.com/1.1/search/tweets.json?q=%23vereinzeltversammelt&include_rts=false", parameters: nil, error: &clientError)
//
//        client.sendTwitterRequest(request) { (response, data, error) in
//
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//
//            guard let data = data else {
//                completion(.failure(APIError.noData))
//                return
//            }
//
//            do {
//
//                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable: Any] else {
//                    completion(.failure(APIError.noData))
//                    return
//                }
//
//                guard let tweetArray = json["statuses"] as? [[AnyHashable: Any]] else {
//                    completion(.failure(APIError.noData))
//                    return
//                }
//
//                var tweets: [TWTRTweet] = []
//
//                for jsonTweet in tweetArray {
//
//                    if let tweet = TWTRTweet(jsonDictionary: jsonTweet) {
//                        tweets.append(tweet)
//                    }
//
//                }
//
//                let ids = tweets.map { $0.tweetID }
//
//                self.client.loadTweets(withIDs: ids, completion: { (tweets, error) in
//
//                    if let error = error {
//                        completion(.failure(error))
//                        return
//                    }
//
//                    var tweets = tweets ?? []
//
////                    tweets.sort(by: { $0.date > $1.date })
//
//                    completion(.success(tweets))
//
//                })
//
//            } catch {
//                completion(.failure(error))
//            }
//
//        }
//
//    }
//
//    public func getSocial() -> AnyPublisher<[TWTRTweet], Error> {
//
//        return Deferred {
//            return Future { promise in
//
//                self.fetchSocialTweets(completion: { (result) in
//
//                    switch result {
//
//                        case .success(let tweets):
//                            promise(.success(tweets))
//
//                        case .failure(let error):
//                            promise(.failure(error))
//
//                    }
//
//                })
//
//            }
//        }
//        .eraseToAnyPublisher()
//
//    }
//
//}
