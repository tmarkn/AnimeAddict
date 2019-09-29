//
//  getData.swift
//  AnimeAddict
//
//  Created by Tony Mark on 4/8/19.
//  Copyright © 2019 Tony Mark. All rights reserved.
//

import Foundation
import Dispatch
import WebKit

class httpHandler {
    
    
    func get(url: String) -> ([Anime], Int) {
        var list = [Anime]()
        let addr = URL(string: url)
        let headers = [
            "Accept": "*/*",
            "Cache-Control": "no-cache",
            "Host": "api.jikan.moe",
            "accept-encoding": "gzip, deflate",
            "cache-control": "no-cache"
        ]
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        
        let config = URLSessionConfiguration.default
//        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
//        config.urlCache = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        
        let session = URLSession(configuration: config)
        let sem = DispatchSemaphore(value: 0)
        var responseCode = 0
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse)
                responseCode = httpResponse?.statusCode as! Int
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse)
                responseCode = httpResponse?.statusCode as! Int
            }
            let animeList: Jikan
            guard let data = data else { return }
            do {
                animeList = try JSONDecoder().decode(Jikan.self, from: data)
                list = animeList.anime
                sem.signal()
            } catch let jsonError {
                print("Failed to decode:", jsonError)
                sem.signal()
            }
        })
        .resume()
        sem.wait()
        print("### response code:", responseCode)
        return (list, responseCode)
    }
    
    func getAiring(url: String) -> [AiringAnime]{
        var list = [AiringAnime]()
        let addr = URL(string: url)
        let headers = [
            "Accept": "*/*",
            "Cache-Control": "no-cache",
            "Host": "api.jikan.moe",
            "accept-encoding": "gzip, deflate",
            "cache-control": "no-cache"
        ]
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        config.urlCache = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        
        let session = URLSession(configuration: config)
        let sem = DispatchSemaphore(value: 0)
        //var responseCode = 0
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse)
                //responseCode = httpResponse?.statusCode as! Int
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse)
                //responseCode = httpResponse?.statusCode as! Int
            }
            let animeList: AiringJikan
            guard let data = data else { return }
            do {
                animeList = try JSONDecoder().decode(AiringJikan.self, from: data)
                list = animeList.top
                sem.signal()
            } catch let jsonError {
                print("Failed to decode:", jsonError)
                sem.signal()
            }
        })
        .resume()
        sem.wait()
        
        return list
    }
    
    func update(mal_id: Int, watched_episodes: Int, status: Int, tags: String?, csrf_token: String, cookies: [HTTPCookie]) -> Int {
        let addr = "https://myanimelist.net/ownlist/anime/edit.json"
        var header = ""
        for cookie in cookies {
            header.append(cookie.name + "=" + cookie.value)
            header.append("; ")
        }
        header.removeLast(2)
        
        var headers = [
            "Content-Type": "text/plain",
            "Accept": "*/*",
            "Cache-Control": "no-cache",
            "Host": "myanimelist.net",
            "accept-encoding": "gzip, deflate",
            "content-length": "111",
            "cache-control": "no-cache"
        ]
        headers.updateValue(header, forKey: "cookie")
        headers.updateValue(csrf_token, forKey: "x-csrf-token")
        
        var newTags: String
        if tags == nil || tags == "animeAddict" {
            newTags = "animeAddict"
        } else {
            newTags = tags! + ", animeAddict"
        }
        
        let query = String(format: "{\"num_watched_episodes\":%d,\"anime_id\":%d,\"status\":%d,\"tags\":\"%@\"}", watched_episodes, mal_id, status, newTags)
        print(query)
        print(headers)
        print(newTags)
        let postData = NSData(data: query.data(using: String.Encoding.utf8)!)
        
        let request = NSMutableURLRequest(url: NSURL(string: addr)! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        var responseCode = 0
        let session = URLSession(configuration: config)
        let sem = DispatchSemaphore(value: 0)
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse)
                responseCode = httpResponse?.statusCode as! Int
                sem.signal()
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse)
                responseCode = httpResponse?.statusCode as! Int
                sem.signal()
            }
        })
        .resume()
        sem.wait()
        print(responseCode)
        return responseCode
    }
    
    func add(mal_id: Int, watched_episodes: Int, status: Int, tags: String?, csrf_token: String, cookies: [HTTPCookie]) -> Int {
        let addr = "https://myanimelist.net/ownlist/anime/add.json"
        var header = ""
        for cookie in cookies {
            header.append(cookie.name + "=" + cookie.value)
            header.append("; ")
        }
        header.removeLast(2)
        
        var headers = [
            "Content-Type": "text/plain",
            "Accept": "*/*",
            "Cache-Control": "no-cache",
            "Host": "myanimelist.net",
            "accept-encoding": "gzip, deflate",
            "content-length": "111",
            "cache-control": "no-cache"
        ]
        headers.updateValue(header, forKey: "cookie")
        headers.updateValue(csrf_token, forKey: "x-csrf-token")
        
        var newTags: String
        if tags == nil || tags == "animeAddict" {
            newTags = "animeAddict"
        } else {
            newTags = tags! + ", animeAddict"
        }
        
        let query = String(format: "{\"num_watched_episodes\":%d,\"anime_id\":%d,\"status\":%d,\"tags\":\"%@\"}", watched_episodes, mal_id, status, newTags)
        print(query)
        print(headers)
        print(newTags)
        let postData = NSData(data: query.data(using: String.Encoding.utf8)!)
        
        let request = NSMutableURLRequest(url: NSURL(string: addr)! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        var responseCode = 0
        let session = URLSession(configuration: config)
        let sem = DispatchSemaphore(value: 0)
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse)
                responseCode = httpResponse?.statusCode as! Int
                sem.signal()
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse)
                responseCode = httpResponse?.statusCode as! Int
                sem.signal()
            }
        })
            .resume()
        sem.wait()
        print(responseCode)
        return responseCode
    }
}
