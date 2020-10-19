//
//  K.swift
//  Unsplash The Kraken
//
//  Created by Andre Elandra on 17/09/20.
//  Copyright © 2020 Andre Elandra. All rights reserved.
//

//Static
struct K {
    
    static let title = "Kraken"
    static let userPageKey = "UserPage"
    static let previewSegueID = "PreviewSegue"
    static let backTitle = "Back"
    static let randomQuery = "Random"
    static let searchBarTextFieldPlaceholder = "Search wallpapers"
    static let emptySearchBarTextFieldPlaceholder = "Type something..."
    static let wallpapersNibName = "WallpapersCollectionViewCell"
    static let reuseCellID = "WallpapersReuseCell"
    static let photosAppURLScheme = "photos-redirect://"
    static let themeColor = "Theme"
    static let themeInvertedColor = "ThemeInverted"
    
    struct UnsplashAPI {
        static let baseURL = "https://api.unsplash.com/"
        //Change the apiKey into your unsplash api key in order for the app to work.
        static let clientID = "Client-ID \(apiKey!)"
        static let header = "Authorization"
        static let searchPath = "/search/photos"
        static let query = "query"
        static let page = "page"
        static let perPage = "per_page"
    }
    
    struct Alert {
        static let ok = "Ok"
        static let error = "Error"
        static let save = "Save"
        static let share = "Share"
        static let cancel = "Cancel"
        static let chooseImageQualityTitle = "Save Image"
        static let chooseImageQualityTitleMessage = "Choose the image quality"
        static let highTitle = "High"
        static let mediumTitle = "Medium"
        static let lowTitle = "Low"
        static let successTitle = "Success!"
        static let successDownloadTitle = "Successfully download the image"
        static let openPhotosTitle = "Open in Photos app"
        static let searchedMessage = "Please wait..."
        static let waitingConnectionMessage = "Waiting for connection"
        static let dismissTitle = "Dismiss"
        static let reachPageLimitTitle = "Notice"
        static let reachPageLimitMessage = "You have reached the page limit"
        static let saveImage = "square.and.arrow.down"
    }
    
    struct Error {
        static let convertToURL = "Failed to convert string to URL"
        static let getURLFromURLComponent = "Failed to get URL from URL component"
    }
 
    struct Plist {
        static let name = "Secret"
        static let plist = "plist"
        static let apiKey = "API Key"
    }
    
}
