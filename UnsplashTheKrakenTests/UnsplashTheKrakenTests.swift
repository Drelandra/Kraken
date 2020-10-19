//
//  UnsplashTheKrakenTests.swift
//  UnsplashTheKrakenTests
//
//  Created by Andre Elandra on 20/09/20.
//  Copyright © 2020 Andre Elandra. All rights reserved.
//

import XCTest
@testable import Unsplash_The_Kraken

class UnsplashTheKrakenTests: XCTestCase {

    var session: URLSession!
    var vc: WallpapersViewController!
    
    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForResource = 120
        session = URLSession(configuration: config)
        
        vc = UIStoryboard(name: "Main", bundle: nil)
        .instantiateInitialViewController() as? WallpapersViewController
    }

    override func tearDown() {
        session = nil
        vc = nil
        super.tearDown()
    }
    
    func testSearchResultIsFetchedWithHTTPStatusCode200() {
        // given
        let url =
            URL(string: "https://api.unsplash.com/search/photos?query=Random&page=1&per_page=30&client_id=\(apiKey!)")
        
        let promise = expectation(description: "Status code: 200")
        
        // when
        let dataTask = session.dataTask(with: url!) { data, response, error in
            // then
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
                return
            } else if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode == 200 {
                    promise.fulfill()
                } else {
                    XCTFail("Status code: \(statusCode)")
                }
            }
        }
        dataTask.resume()
        wait(for: [promise], timeout: 5)
    }
    
    func testCallToUnsplashCompletes() {
        // given
        let url =
            URL(string: "https://api.unsplash.com/search/photos?query=Random&page=1&per_page=30&client_id=\(apiKey!)")
        
        let promise = expectation(description: "Completion handler invoked")
        var statusCode: Int?
        var responseError: Error?
        
        // when
        let dataTask = session.dataTask(with: url!) { data, response, error in
            statusCode = (response as? HTTPURLResponse)?.statusCode
            responseError = error
            promise.fulfill()
        }
        dataTask.resume()
        wait(for: [promise], timeout: 5)
        
        //then
        XCTAssertNil(responseError)
        XCTAssertEqual(statusCode, 200)
    }
    
}
