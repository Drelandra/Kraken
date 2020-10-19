//
//  Plist.swift
//  Unsplash The Kraken
//
//  Created by Andre Elandra on 19/10/20.
//  Copyright © 2020 Andre Elandra. All rights reserved.
//

import Foundation

var apiKey: String?

func retrievePlistData() {
    guard let path = Bundle.main.path(forResource: K.Plist.name, ofType: K.Plist.plist) else { assert(false, "Plist file not found") }
    
    do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        let plist = try PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as! [String:String]
        if let unsplashAPIKey = plist[K.Plist.apiKey] {
            apiKey = unsplashAPIKey
        }
    }catch {
        displayAlert(title: K.Alert.error, message: error.localizedDescription, action: .default)
    }
}
