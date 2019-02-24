//
//  HomePresenterTest.swift
//  DynamicTableViewTests
//
//  Created by Jitesh Sharma on 21/02/19.
//  Copyright © 2019 Jitesh Sharma. All rights reserved.
//

import XCTest

let emptyServiceString = ""
let serviceStringMock = "http://surya-interview.appspot.com/list"
let badServiceStringMock = "http://surya-interview.appspot"
let controllerMock = UIViewController()

func readDataFromMockJson() -> Item? {
    
    let urlBar = Bundle.main.url(forResource: "MockInfoModelData", withExtension: "geojson")!
    
    do {
        let jsonData = try Data(contentsOf: urlBar)
        let infoModel = try? JSONDecoder().decode(Item.self, from: jsonData)
        return infoModel
    } catch {
        XCTFail("Missing Mock Json file: MockInfoModelData.json") }
    return nil
}

func testWithValidURL() {
    
    // Initializing viewControllerPresenter with Valid URL
    let viewControllerPresenter = ViewControllerPresenter(serviceString: serviceStringMock)
    // Attaching viewControllerPresenter with Mock UIViewController
    viewControllerPresenter.attachedController(controler: controllerMock)
    viewControllerPresenter.getDataFromService(completionHandler: { (status, rows) in
        
        XCTAssertTrue(status)
        XCTAssertNotNil(rows)
        
//        let mockData = readDataFromMockJson()
        viewControllerPresenter.detachController()
        
    })
}

func testWithBadValidURL() {
    
    // Initializing viewControllerPresenter with Valid URL
    let viewControllerPresenter = ViewControllerPresenter(serviceString: badServiceStringMock)
    // Attaching viewControllerPresenter with Mock UIViewController
    viewControllerPresenter.attachedController(controler: controllerMock)
    viewControllerPresenter.getDataFromService(completionHandler: { (status, rows) in
        XCTAssertFalse(status)
        viewControllerPresenter.detachController()
    })
}

func testWithEmptyValidURL() {
    
    // Initializing viewControllerPresenter with Valid URL
    let viewControllerPresenter = ViewControllerPresenter(serviceString: emptyServiceString)
    // Attaching viewControllerPresenter with Mock UIViewController
    viewControllerPresenter.attachedController(controler: controllerMock)
    viewControllerPresenter.getDataFromService(completionHandler: { (status, rows) in
        XCTAssertFalse(status)
        viewControllerPresenter.detachController()
    })
}
