//
//  PreviewViewController.swift
//  Unsplash The Kraken
//
//  Created by Andre Elandra on 21/09/20.
//  Copyright © 2020 Andre Elandra. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {
    
    //MARK: - Properties
    @IBOutlet weak var imageView: ImageLoaderView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var resultArray: [Photo]?
    var index: Int?
    var username: String?
    var lowDataMode: Bool?
    private lazy var userPressed = false
    
    //MARK: - Internal Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if let safeUsername = username {
            title = "Photo by @\(safeUsername)"
        }
        setupScrollView()
        loadImageBasedOnNetwork()
    }
    
    func setupScrollView() {
        scrollView.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        scrollView.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        userPressed = !userPressed
        if userPressed == true {
            navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        imageView = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNeedsUpdateOfHomeIndicatorAutoHidden()
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    func loadImageBasedOnNetwork() {
        if let safeIndex = index {
            if lowDataMode == true {
                if let urlString = resultArray?[safeIndex].urls?.small {
                    loadImageFromURL(from: urlString)
                }
            } else {
                if let urlString = resultArray?[safeIndex].urls?.full {
                    loadImageFromURL(from: urlString)
                }
            }
            
        }
    }
    
    func loadImageFromURL(from urlString: String) {
        guard let safeUrl = URL(string: urlString) else {
            assert(false, K.Error.convertToURL)
        }
        imageView.loadImage(from: safeUrl)
    }
    
    enum Quality {
        case high, medium, low
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        
        displayAlert(title: K.Alert.chooseImageQualityTitle, message: K.Alert.chooseImageQualityTitleMessage, style: .actionSheet, action: .chooseQuality) { (action) -> Void? in
            switch action.title {
            case K.Alert.highTitle:
                return self.saveImage(url: self.setupImageURL(.high, at: self.index!))
            case K.Alert.mediumTitle:
                return self.saveImage(url: self.setupImageURL(.medium, at: self.index!))
            case K.Alert.lowTitle:
                return self.saveImage(url: self.setupImageURL(.low, at: self.index!))
            default: break
            }
            return nil
        }
        
    }
    
    func setupImageURL(_ quality: Quality, at indexPath: Int) -> URL {
        var imageQualityURL = [String]()
        if let results = self.resultArray {
            for result in results {
                switch quality {
                case .high:
                    if let high = result.urls?.full {
                        imageQualityURL.append(high)
                    }
                case .medium:
                    if let medium = result.urls?.regular {
                        imageQualityURL.append(medium)
                    }
                case .low:
                    if let low = result.urls?.small {
                        imageQualityURL.append(low)
                    }
                }
            }
        }
        
        guard let url = URL(string: imageQualityURL[indexPath]) else {
            assert(false, K.Error.convertToURL)
        }
        
        return url
    }
    
    func saveImage(url: URL) {
        if let data = try? Data(contentsOf: url) {
            if let image = UIImage(data: data) {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(updateStatus(image:error:contextInfo:)), nil)
            }
        }
    }
    
    @objc func updateStatus(image: UIImage, error: Error?, contextInfo: UnsafeRawPointer?) {
        if let err = error {
            displayAlert(title: K.Alert.error, message: err.localizedDescription, action: .default)
        } else {
            displayAlert(title: K.Alert.successTitle, message: K.Alert.successDownloadTitle, style: .alert, action: .download, actionTitle: K.Alert.ok, actionStyle: .default) { _ in
                UIApplication.shared.open(URL(string: K.photosAppURLScheme)!)
            }
        }
    }
    
}

//MARK: - Scroll View Delegate
extension PreviewViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
}
