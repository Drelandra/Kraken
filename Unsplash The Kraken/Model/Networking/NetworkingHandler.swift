//
//  NetworkingHandler.swift
//  Unsplash The Kraken
//
//  Created by Andre Elandra on 19/09/20.
//  Copyright © 2020 Andre Elandra. All rights reserved.
//

import Foundation

class NetworkingHandler: NSObject, URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        displayAlert(title: nil, message: K.Alert.waitingConnectionMessage, style: .alert, action: .defaultWithIndicator, actionTitle: K.Alert.dismissTitle, actionStyle: .cancel)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        dismissAlert()
    }
    
}
