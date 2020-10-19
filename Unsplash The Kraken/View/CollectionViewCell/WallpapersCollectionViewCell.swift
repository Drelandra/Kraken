//
//  WallpapersCollectionViewCell.swift
//  Unsplash The Kraken
//
//  Created by Andre Elandra on 17/09/20.
//  Copyright © 2020 Andre Elandra. All rights reserved.
//

import UIKit

class WallpapersCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var wallpaperImage: ImageLoaderView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        wallpaperImage.clipsToBounds = true
        wallpaperImage.layer.cornerRadius = 10
        wallpaperImage.backgroundColor = .gray
        wallpaperImage.contentMode = .scaleAspectFill
    }

}
