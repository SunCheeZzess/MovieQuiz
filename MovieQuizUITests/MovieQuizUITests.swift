//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Александр Котельников on 27.02.2024.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    
    
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        
        try super.setUpWithError()
        app = XCUIApplication()
        app.launch()
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        app.terminate()
        app = nil
    }
    
    func testYesButton() throws {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData  = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        let indexLabel = app.staticTexts["IndexLabel"]
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2 / 10")
    }
    
    
    func testNoButton() throws {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData  = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        
        let indexLabel = app.staticTexts["IndexLabel"]
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2 / 10")
        
    }
    
    func testFinishGame() throws {
        sleep(2)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        let app = XCUIApplication()
        let actionButton = app.buttons["Action Button"]
        XCTAssert(actionButton.exists)
        
    }
    
    func testAlertDismiss() {
        let app = XCUIApplication()
        app.launch()
        
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        let alert = app.alerts["Этот раунд окончен!"]
        let actionButton = alert.buttons["Action Button"]
        
        
        XCTAssert(actionButton.exists)
        actionButton.tap()
        
        sleep(2)
        
        
        let indexLabel = app.staticTexts["IndexLabel"]
        
        
        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1 / 10")
    }
}


