//
//  Client.swift
//  Graboo
//
//  Created by James Shiffer on 6/13/22.
//

import Foundation
import CoreGraphics


protocol BooruClient {
    associatedtype T: BooruImage
    
    var baseUrl: String { get }
    func searchTagImages(tags: String, completionHandler: @escaping ([T]?, Error?) -> Void)
}

protocol BooruSearchResults: Decodable {
    
}

protocol BooruImage: Decodable, Hashable {
    func aspectRatio() -> CGFloat
    func displayUrl() -> String
}

struct GelbooruSearchResults: BooruSearchResults {
    let post: [GelbooruImage];
}

struct GelbooruImage: BooruImage {
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
    
    
    func aspectRatio() -> CGFloat {
        return CGFloat(self.width) / CGFloat(self.height);
    }
    
    func displayUrl() -> String {
        if sampleWidth > 0 && sampleHeight > 0 {
            return sampleUrl;
        } else {
            return fileUrl;
        }
    }
}

func httpGetJson<T: Decodable>(url: String, completionHandler: @escaping (T?, Error?) -> Void) {
    let task = URLSession.shared.dataTask(with: URL(string: url)!) { (data, _, error) in
        guard let data = data, error == nil else {
            DispatchQueue.main.async {
                completionHandler(nil, error)
            }
            return
        }
        
        let parser = JSONDecoder()
        parser.keyDecodingStrategy = .convertFromSnakeCase
        var result: T
        do {
            result = try parser.decode(T.self, from: data)
        } catch let e {
            DispatchQueue.main.async {
                completionHandler(nil, e)
            }
            return
        }
        
        DispatchQueue.main.async {
            completionHandler(result, nil)
        }
    }
    task.resume()
}

class GelbooruClient: BooruClient {
    private(set) var baseUrl: String
    
    init() {
        self.baseUrl = "https://gelbooru.com"
    }
    
    func searchTagImages(tags: String, completionHandler: @escaping ([GelbooruImage]?, Error?) -> Void) {
        let joinedTags = tags.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        httpGetJson(url: String(format: "%@/?page=dapi&s=post&q=index&json=1&tags=%@", self.baseUrl, joinedTags)) { (data: GelbooruSearchResults?, error) in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(data.post, nil)
            }
        }
    }
}


struct SafebooruImage: BooruImage {
    let id: Int;
    let image: String;
    let width: Int;
    let height: Int;
    let sample: Bool;
    let sampleWidth: Int;
    let sampleHeight: Int;
    let tags: String;
    let rating: String;
    let directory: String;
    
    
    func aspectRatio() -> CGFloat {
        return CGFloat(self.width) / CGFloat(self.height);
    }
    
    func displayUrl() -> String {
        return String(format: "https://safebooru.org/images/%@/%@", self.directory, self.image);
    }
}

class SafebooruClient: BooruClient {
    private(set) var baseUrl: String
        
    init() {
        self.baseUrl = "https://safebooru.org"
    }
        
    func searchTagImages(tags: String, completionHandler: @escaping ([SafebooruImage]?, Error?) -> Void) {
        let joinedTags = tags.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        httpGetJson(url: String(format: "%@/?page=dapi&s=post&q=index&json=1&tags=%@", self.baseUrl, joinedTags), completionHandler: completionHandler)
    }
}
