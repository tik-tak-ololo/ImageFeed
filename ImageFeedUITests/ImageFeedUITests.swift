//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Сергей Хмелёв on 18.04.2026.
//

import XCTest

final class ImageFeedUITests: XCTestCase {

    private let app = XCUIApplication() // переменная приложения
    
    override func setUpWithError() throws {
        continueAfterFailure = false // настройка выполнения тестов, которая прекратит выполнения тестов, если в тесте что-то пошло не так
        app.launch() // запускаем приложение перед каждым тестом
    }
    
    func testAuth() throws {
            let authScreen = AuthScreen(app: app)
            let webAuthScreen = WebAuthScreen(app: app)
            let feedScreen = FeedScreen(app: app)

            authScreen.tapAuthenticate()
            webAuthScreen.login(
                email: "email",
                password: "password"
            )

            XCTAssertTrue(feedScreen.isOpened)
    }
    
    func testFeedBook() throws {
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
        cell.swipeUp()
        
        sleep(10)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        cellToLike.buttons["likeButton"].tap()
        sleep(10)
        cellToLike.buttons["likeButton"].tap()
        
        sleep(10)
        
        cellToLike.tap()
        
        sleep(10)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        // Zoom in
        image.pinch(withScale: 3, velocity: 1) // zoom in
        // Zoom out
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["singleImageBackButton"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        // GIVEN
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))

        // WHEN: открываем профиль
        let profileTab = tabBar.buttons.element(boundBy: 1)
        XCTAssertTrue(profileTab.waitForExistence(timeout: 5))
        profileTab.tap()
        
        // THEN: проверяем данные профиля
        let nameLabel = app.staticTexts["Sergey Khmelow"]
        XCTAssertTrue(nameLabel.waitForExistence(timeout: 5))
        
        let usernameLabel = app.staticTexts["@tik_tak_ololo"]
        XCTAssertTrue(usernameLabel.waitForExistence(timeout: 5))
        
        // WHEN: нажимаем logout
        let logoutButton = app.buttons["logoutButton"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5))
        logoutButton.tap()
        
        // THEN: подтверждаем alert
        let alert = app.alerts["Пока, пока!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        
        let confirmButton = alert.buttons["Да"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 5))
        confirmButton.tap()
        
        // OPTIONAL: проверка, что вернулись на экран авторизации
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
    }
    
}

private struct AuthScreen {
    let app: XCUIApplication

    var authenticateButton: XCUIElement {
        app.buttons["Authenticate"]
    }

    func tapAuthenticate() {
        XCTAssertTrue(authenticateButton.waitForExistence(timeout: 10))
        authenticateButton.tap()
    }
}

private struct WebAuthScreen {
    let app: XCUIApplication

    var webView: XCUIElement {
        app.webViews["UnsplashWebView"]
    }

    var loginTextField: XCUIElement {
        webView.descendants(matching: .textField).firstMatch
    }

    var passwordTextField: XCUIElement {
        webView.descendants(matching: .secureTextField).firstMatch
    }

    var loginButton: XCUIElement {
        webView.buttons["Login"]
    }

    func login(email: String, password: String) {
        XCTAssertTrue(webView.waitForExistence(timeout: 15))
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 15))

        loginTextField.tap()
        loginTextField.typeText(email)
        dismissKeyboardIfNeeded()

        if !passwordTextField.isHittable {
            webView.swipeUp()
        }

        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 15))
        passwordTextField.tap()
        passwordTextField.typeText(password)
        dismissKeyboardIfNeeded()

        if !loginButton.isHittable {
            webView.swipeUp()
        }

        XCTAssertTrue(loginButton.waitForExistence(timeout: 10))
        loginButton.tap()
    }

    private func dismissKeyboardIfNeeded() {
        let keyboard = app.keyboards.firstMatch
        guard keyboard.exists else { return }

        let doneButton = app.toolbars.buttons["Done"]
        let returnButton = app.keyboards.buttons["Return"]
        let nextButton = app.keyboards.buttons["Next"]

        if doneButton.exists && doneButton.isHittable {
            doneButton.tap()
        } else if returnButton.exists && returnButton.isHittable {
            returnButton.tap()
        } else if nextButton.exists && nextButton.isHittable {
            nextButton.tap()
        } else {
            webView.tap()
        }
    }
}

private struct FeedScreen {
    let app: XCUIApplication

    var firstCell: XCUIElement {
        app.tables.cells.firstMatch
    }

    var isOpened: Bool {
        firstCell.waitForExistence(timeout: 20)
    }
}
