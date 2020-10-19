//
//  ImageLoaderView.swift
//  Unsplash The Kraken
//
//  Created by Andre Elandra on 17/09/20.
//  Copyright © 2020 Andre Elandra. All rights reserved.
//

import UIKit

struct Config {
    let countLimit: Int
    let memoryLimit: Int
    
    static let defaultConfig = Config(countLimit: 100, memoryLimit: 1024 * 1024 * 100) // 100 MB
}

class ImageLoaderView: UIImageView {
    
    private let spinner = UIActivityIndicatorView(style: .medium)
    private let imageCache: NSCache<AnyObject, AnyObject> = {
        let cache = NSCache<AnyObject, AnyObject>()
        let defaultConfig = Config.defaultConfig
        cache.countLimit = defaultConfig.countLimit
        cache.totalCostLimit = defaultConfig.memoryLimit
        return cache
    }()
    private lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 5
        return queue
    }()
    func loadImage(from url: URL) {
        
        image = nil
        
        queue.waitUntilAllOperationsAreFinished()
        
        addSpinner()
        
        if let imageFromCache = imageCache.object(forKey: url.absoluteString as AnyObject) as? UIImage {
            self.image = imageFromCache
            spinner.stopAnimating()
            return
        }
        
        queue.addOperation { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let newImage = UIImage(data: data) {
                    self?.imageCache.setObject(newImage, forKey: url.absoluteString as AnyObject)
                    DispatchQueue.main.async {
                        self?.image = newImage
                        self?.spinner.stopAnimating()
                    }
                }
            }
        }
        
    }
    
    private func addSpinner() {
        addSubview(spinner)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        spinner.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        spinner.startAnimating()
    }
    
}
