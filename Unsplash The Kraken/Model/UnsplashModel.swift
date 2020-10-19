//
//  UnsplashModel.swift
//  Unsplash The Kraken
//
//  Created by Andre Elandra on 17/09/20.
//  Copyright © 2020 Andre Elandra. All rights reserved.
//

struct UnsplashSearchModel: Codable {
    let total, totalPages: Int
    let photo: [Photo]
}

struct UnsplashDownloadModel: Codable {
    let url: String
}
