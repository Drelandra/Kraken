//
//  UnsplashData.swift
//  Unsplash The Kraken
//
//  Created by Andre Elandra on 17/09/20.
//  Copyright © 2020 Andre Elandra. All rights reserved.
//

import Foundation

struct UnsplashSearchData: Codable {
    let total, totalPages: Int?
    let results: [Photo]?

    enum CodingKeys: String, CodingKey {
        case total
        case totalPages = "total_pages"
        case results
    }
}

struct Photo: Codable {
    let id: String?
    let width, height: Int?
    let urls: Urls?
    let user: User?

    enum CodingKeys: String, CodingKey {
        case id
        case width, height
        case urls
        case user
    }
}

struct Urls: Codable {
    let raw, full, regular, small: String?
    let thumb: String?
}

struct User: Codable {
    let id: String?
    let username: String?

    enum CodingKeys: String, CodingKey {
        case id, username
    }
}

struct UnsplashDownloadData: Codable {
    let url: String?
}
