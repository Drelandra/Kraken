//
//  Alert.swift
//  Unsplash The Kraken
//
//  Created by Andre Elandra on 19/09/20.
//  Copyright © 2020 Andre Elandra. All rights reserved.
//

import UIKit

enum AlertAction {
    case `default`, off, defaultWithIndicator, offWithIndicator, download, chooseQuality
}

func displayAlert(title: String?, message: String?, style: UIAlertController.Style? = nil, action: AlertAction, actionTitle: String? = nil, actionStyle: UIAlertAction.Style? = nil, handler: ((UIAlertAction) -> Void?)? = nil) {
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: style ?? .alert)
    
    switch action {
    case .default: alert.addAction(UIAlertAction(title: actionTitle ?? K.Alert.ok, style: actionStyle ?? .default, handler: { actions in
        handler?(actions)
    }))
    
    case .off: break
        
    case .defaultWithIndicator:
        alert.addAction(UIAlertAction(title: actionTitle ?? K.Alert.ok, style: actionStyle ?? .default, handler: { actions in
            handler?(actions)
        }))
        alert.view.addSubview(addIndicator())
        
    case .offWithIndicator: alert.view.addSubview(addIndicator())
        
    case .download:
        alert.addAction(UIAlertAction(title: K.Alert.openPhotosTitle, style: .default, handler: { actions in
            handler?(actions)
        }))
        alert.addAction(UIAlertAction(title: actionTitle, style: actionStyle ?? .default, handler: nil))
    case .chooseQuality:
        alert.addAction(UIAlertAction(title: K.Alert.highTitle, style: .default, handler: { (action) in
            handler?(action)
        }))
        alert.addAction(UIAlertAction(title: K.Alert.mediumTitle, style: .default, handler: { (action) in
            handler?(action)
        }))
        alert.addAction(UIAlertAction(title: K.Alert.lowTitle, style: .default, handler: { (action) in
            handler?(action)
        }))
        alert.addAction(UIAlertAction(title: K.Alert.cancel, style: .cancel, handler: nil))
    }
    
    if let topVC = getTopMostViewController() {
        topVC.present(alert, animated: true, completion: nil)
    }
}

func dismissAlert() {
    if let topVC = getTopMostViewController(), topVC is UIAlertController {
        topVC.dismiss(animated: true, completion: nil)
    }
}

fileprivate func addIndicator() -> UIActivityIndicatorView {
    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 5, width: 50, height: 50))
    loadingIndicator.hidesWhenStopped = true
    loadingIndicator.style = UIActivityIndicatorView.Style.medium
    
    loadingIndicator.startAnimating()
    return loadingIndicator
}

fileprivate func getTopMostViewController() -> UIViewController? {
    let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
    
    if var topController = keyWindow?.rootViewController {
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        return topController
    }
    return nil
}
