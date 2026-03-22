//
//  InstagramAPI.swift
//  moers festival
//
//  Created by Lennart Fischer on 27.04.18.
//  Copyright © 2018 CodeForNiederrhein. All rights reserved.
//

import Core
import UIKit

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
    
    func fetchPosts() async throws -> [InstagramPost] {
        
        let url = URLBuilder().build(for: "vereinzeltversammelt")
        
        guard let requestURL = url else { throw APIError.unavailableURL }
        
        var request = URLRequest(url: requestURL)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, _) = try await session.data(for: request)
        let json = try JSONSerialization.jsonObject(
            with: data,
            options: JSONSerialization.ReadingOptions.mutableContainers
        ) as? [String: Any]
        
        guard let d = json?["graphql"] as? [String: AnyObject] else { return [] }
        guard let hashtag = d["hashtag"] as? [String: AnyObject] else { return [] }
        guard let edgeHashtag = hashtag["edge_hashtag_to_media"] as? [String: AnyObject] else { return [] }
        guard let edges = edgeHashtag["edges"] as? [[String: AnyObject]] else { return [] }
        
        var posts: [InstagramPost] = []
        
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
        
        posts.sort(by: { $0.publishDate > $1.publishDate })
        
        return posts
        
    }
    
    public func getSocial() async throws -> [InstagramPost] {
        try await fetchPosts()
    }
    
}
