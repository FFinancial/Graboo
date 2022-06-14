//
//  Client.swift
//  Graboo
//
//  Created by James Shiffer on 6/13/22.
//

import Foundation

struct GelbooruSearchResults: Decodable {
    let post: [GelbooruImage];
}

struct GelbooruImage: Decodable, Hashable {
    let id: Int;
    let fileUrl: String;
    let width: Int;
    let height: Int;
    let previewWidth: Int;
    let previewUrl: String;
    let previewHeight: Int;
    let sampleUrl: String;
    let sampleWidth: Int;
    let sampleHeight: Int;
    let tags: String;
    let rating: String;
}

class GelbooruClient {
    let baseUrl: String
    
    init(baseUrl: String = "https://gelbooru.com") {
        self.baseUrl = baseUrl
    }
    
    func searchTagImages(tags: [String], completionHandler: @escaping ([GelbooruImage]?, Error?) -> Void) {
        let joinedTags = tags.joined(separator: " ").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: String(format: "%@/?page=dapi&s=post&q=index&json=1&tags=%@", self.baseUrl, joinedTags))!
        let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            
            let parser = JSONDecoder()
            parser.keyDecodingStrategy = .convertFromSnakeCase
            var searchResults: GelbooruSearchResults
            do {
                searchResults = try parser.decode(GelbooruSearchResults.self, from: data)
            } catch let e {
                DispatchQueue.main.async {
                    completionHandler(nil, e)
                }
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(searchResults.post, nil)
            }
        }
        task.resume()
    }
}
