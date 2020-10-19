//
//  UnsplashManager.swift
//  Unsplash The Kraken
//
//  Created by Andre Elandra on 17/09/20.
//  Copyright © 2020 Andre Elandra. All rights reserved.
//

import Foundation
import UIKit

protocol UnsplashDelegate: class {
    func didSearchUnsplash(_ unsplashManager: UnsplashManager, _ unsplashSearchModel: UnsplashSearchModel)
    func didDownload(_ unsplashManager: UnsplashManager, _ unsplashDownloadModel: UnsplashDownloadModel)
    func didFailWithError(error: Error)
}

struct UnsplashManager {
    
    weak var delegate: UnsplashDelegate?
    
    private let baseURL = K.UnsplashAPI.baseURL
    private let clientID = K.UnsplashAPI.clientID

    /**
    Fetch Unsplash Data  from search input.
    
    - Parameters:
       - query: Search terms.
       - page: Page number to retrieve. (default: 1)
    */
    func fetchSearchResult(from query: String, page: Int) {
        performSearchRequest(query: query, page: page, perPage: 30)
    }
    
    func fetchDownload(id: String) {
        let downloadURL = "\(baseURL)photos/\(id)/download"
        performDownloadRequest(url: downloadURL)
    }
    
    /**
     Performing a request to Unsplash API.
     
     - Parameters:
        - query: Search terms.
        - page: Page number to retrieve. (default: 1)
        - perPage: Total item per page. (default: 10, maximum: 30)
     */
    func performSearchRequest(query: String, page: Int, perPage: Int) {
    
        guard let apiURL = URL(string: baseURL) else {
            assert(false, K.Error.convertToURL)
        }
        
        var urlComponents = URLComponents(url: apiURL, resolvingAgainstBaseURL: true)
        urlComponents?.path = K.UnsplashAPI.searchPath
        urlComponents?.queryItems = [
            URLQueryItem(name: K.UnsplashAPI.query, value: "\(query)"),
            URLQueryItem(name: K.UnsplashAPI.page, value: "\(page)"),
            URLQueryItem(name: K.UnsplashAPI.perPage, value: "\(perPage)")
        ]
        
        guard let url = urlComponents?.url else {
            assert(false, K.Error.getURLFromURLComponent)
        }
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForResource = 300
        
        var request = URLRequest(url: url)
        request.addValue(clientID, forHTTPHeaderField: K.UnsplashAPI.header)
        request.timeoutInterval = 30
        
        let task = URLSession(configuration: config, delegate: NetworkingHandler(), delegateQueue: .main).dataTask(with: request) { (data, response, error) in
            if error != nil {
                self.delegate?.didFailWithError(error: error!)
                return
            }
            if let safeData = data {
                
                if let wallpapers = self.parseSearchJSON(safeData) {
                    self.delegate?.didSearchUnsplash(self, wallpapers)
                }
            }
        }
        task.resume()
    }
    
    func performDownloadRequest(url: String) {
        guard let apiURL = URL(string: url) else {
            assert(false, K.Error.convertToURL)
        }
        
        var request = URLRequest(url: apiURL)
        request.addValue(clientID, forHTTPHeaderField: K.UnsplashAPI.header)
        
        let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let err = error {
                self.delegate?.didFailWithError(error: err)
                return
            }
            if let safeData = data {
                if let downloadData = self.parseDownloadJSON(safeData) {
                self.delegate?.didDownload(self, downloadData)
                }
            }
        }
        task.resume()
    }
    
    func parseSearchJSON(_ unsplashData: Data) -> UnsplashSearchModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(UnsplashSearchData.self, from: unsplashData)
            let total = decodedData.total!
            let totalPages = decodedData.totalPages!
            let photo = decodedData.results!
            
            let unsplashSearchModel = UnsplashSearchModel(total: total, totalPages: totalPages, photo: photo)
            return unsplashSearchModel
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    func parseDownloadJSON(_ unsplashData: Data) -> UnsplashDownloadModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(UnsplashDownloadData.self, from: unsplashData)
            let url = decodedData.url!
            
            let unsplashDownloadModel = UnsplashDownloadModel(url: url)
            return unsplashDownloadModel
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
