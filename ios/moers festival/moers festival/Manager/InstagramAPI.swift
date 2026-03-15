//
//  InstagramAPI.swift
//  moers festival
//
//  Created by Lennart Fischer on 27.04.18.
//  Copyright © 2018 CodeForNiederrhein. All rights reserved.
//

import Core
import UIKit
import Combine

protocol InstagramAPIDelegate {
    
    func didReceivePosts(posts: [InstagramPost])
    
}

class InstagramAPI {
    
    static let shared = InstagramAPI()
    
    private var session = URLSession.shared
    
    struct URLBuilder {
        func build(for hashtag: String) -> URL? {
            
            let urlString = "https://www.instagram.com/explore/tags/\(hashtag)?__a=1".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            
            return URL(string: urlString)
            
        }
    }
    
    func fetchPosts(completion: @escaping (Result<[InstagramPost], Error>) -> ()) {
        
        let url = URLBuilder().build(for: "vereinzeltversammelt")
        
        guard let requestURL = url else { return }
        
        var request = URLRequest(url: requestURL)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        session.dataTask(with: request) { (data, response, error) in
            
            var posts: [InstagramPost] = []
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            do {
                
                guard let data = data else {
                    completion(.failure(APIError.noData))
                    return
                }
                
                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
                
                guard let d = json?["graphql"] as? [String: AnyObject] else { return }
                guard let hashtag = d["hashtag"] as? [String: AnyObject] else { return }
                guard let edgeHashtag = hashtag["edge_hashtag_to_media"] as? [String: AnyObject] else { return }
                guard let edges = edgeHashtag["edges"] as? [[String: AnyObject]] else { return }
                
                for edge in edges {
                    
                    if let node = edge["node"] as? [String: AnyObject] {
                        
                        let id = node["id"] as? String ?? "-1"
                        var caption = ""
                        let timestamp = node["taken_at_timestamp"] as? Double ?? 0
                        let imageURLString = node["display_url"] as? String ?? ""
                        
                        if let edgeMediaCaption = node["edge_media_to_caption"] as? [String: AnyObject] {
                            if let edges = edgeMediaCaption["edges"] as? [[String: AnyObject]] {
                                if let node = edges.first?["node"] as? [String: AnyObject] {
                                    if let cap = node["text"] as? String {
                                        caption = cap
                                    }
                                }
                            }
                        }
                        
                        var height: CGFloat = 0
                        var width: CGFloat = 0
                        
                        if let dimensions = node["dimensions"] as? [String: AnyObject] {
                            if let h = dimensions["height"] as? Int {
                                height = CGFloat(h)
                            }
                            if let w = dimensions["width"] as? Int {
                                width = CGFloat(w)
                            }
                        }
                        
                        let date = Date(timeIntervalSince1970: timestamp)
                        
                        if let url = URL(string: imageURLString) {
                            
                            let post = InstagramPost(id: id,
                                                     caption: caption,
                                                     publishDate: date,
                                                     imageURL: url,
                                                     imageWidth: width,
                                                     imageHeight: height)
                            
                            posts.append(post)
                            
                        }
                        
                    }
                    
                }
                
                posts.sort(by: { $0.date > $1.date })
                
                completion(.success(posts))
                
            } catch {
                completion(.failure(error))
            }
            
        }.resume()
        
    }
    
    public func getSocial() -> AnyPublisher<[InstagramPost], Error> {
        
        return Deferred {
            return Future { promise in
                
                self.fetchPosts(completion: { (result) in
                    
                    switch result {
                            
                        case .success(let posts):
                            promise(.success(posts))
                            
                        case .failure(let error):
                            promise(.failure(error))
                            
                    }
                    
                })
                
            }
        }
        .eraseToAnyPublisher()
        
    }
    
}
