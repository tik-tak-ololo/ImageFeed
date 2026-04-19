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
    
    func testAuth_SuccessfullyLogsIn_AndOpensFeed() throws {
            let authScreen = AuthScreen(app: app)
            let webAuthScreen = WebAuthScreen(app: app)
            let feedScreen = FeedScreen(app: app)

            authScreen.tapAuthenticate()
            webAuthScreen.login(
                email: "tik-tak-ololo@outlook.com",
                password: "V@v@vskfhfve1320"
            )

            XCTAssertTrue(feedScreen.isOpened)
    }
    
    func testFeed() throws {
        let tableView = app.tables.firstMatch
        XCTAssertTrue(
            tableView.waitForExistence(timeout: 20),
            "Экран ленты не открылся"
        )
        
        XCTAssertTrue(
            tableView.cells.firstMatch.waitForExistence(timeout: 15),
            "Не удалось дождаться первой ячейки ленты"
        )
        
        XCTContext.runActivity(named: "Прокрутить ленту вверх") { _ in
            tableView.swipeUp()
            XCTAssertTrue(
                tableView.cells.firstMatch.waitForExistence(timeout: 10),
                "После прокрутки не найдена верхняя ячейка"
            )
        }
        
        XCTContext.runActivity(named: "Поставить и снять лайк у верхней картинки") { _ in
            let initialLikeValue = readLikeValueInTopCell(tableView: tableView, timeout: 10)
            let toggledValue = initialLikeValue == "liked" ? "not_liked" : "liked"
            
            tapLikeInTopCell(tableView: tableView)
            waitForLikeValueInTopCell(tableView: tableView, expected: toggledValue, timeout: 15)
            
            waitUntilTopCellLikeButtonIsInteractable(tableView: tableView, timeout: 15)
            
            tapLikeInTopCell(tableView: tableView)
            waitForLikeValueInTopCell(tableView: tableView, expected: initialLikeValue, timeout: 15)
        }
        
        XCTContext.runActivity(named: "Открыть верхнюю картинку") { _ in
            let topCell = topVisibleCell(in: tableView)
            tapCellSafely(topCell)
        }
        
        XCTContext.runActivity(named: "Дождаться открытия экрана одной картинки") { _ in
            let singleImageScrollView = app.scrollViews["singleImageScrollView"].firstMatch
            XCTAssertTrue(
                singleImageScrollView.waitForExistence(timeout: 15),
                "Экран одной картинки не открылся. Добавьте accessibilityIdentifier = \"singleImageScrollView\""
            )
        }
        
        XCTContext.runActivity(named: "Увеличить и уменьшить картинку") { _ in
            let singleImageScrollView = app.scrollViews["singleImageScrollView"].firstMatch
            singleImageScrollView.pinch(withScale: 2.0, velocity: 1.0)
            singleImageScrollView.pinch(withScale: 0.5, velocity: -1.0)
        }
        
        XCTContext.runActivity(named: "Вернуться на экран ленты") { _ in
            let backButton = app.buttons["singleImageBackButton"].firstMatch
            XCTAssertTrue(
                backButton.waitForExistence(timeout: 10),
                "Кнопка назад не найдена. Добавьте accessibilityIdentifier = \"singleImageBackButton\""
            )
            backButton.tap()
            
            XCTAssertTrue(
                tableView.waitForExistence(timeout: 10),
                "Не удалось вернуться на экран ленты"
            )
        }
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

private extension ImageFeedUITests {
    
    func topVisibleCell(in tableView: XCUIElement) -> XCUIElement {
        let cell = tableView.cells.element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 10), "Верхняя ячейка не найдена")
        return cell
    }
    
    func likeButtonInTopCell(tableView: XCUIElement) -> XCUIElement {
        let cell = topVisibleCell(in: tableView)
        let button = cell.buttons["likeButton"]
        XCTAssertTrue(button.waitForExistence(timeout: 10), "Кнопка лайка в верхней ячейке не найдена")
        return button
    }
    
    func readLikeValueInTopCell(tableView: XCUIElement, timeout: TimeInterval) -> String {
        let deadline = Date().addingTimeInterval(timeout)
        
        while Date() < deadline {
            let button = likeButtonInTopCell(tableView: tableView)
            if let value = button.value as? String {
                return value
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        }
        
        XCTFail("Не удалось получить текущее состояние лайка в верхней ячейке")
        return "not_liked"
    }
    
    func waitForLikeValueInTopCell(tableView: XCUIElement, expected: String, timeout: TimeInterval) {
        let deadline = Date().addingTimeInterval(timeout)
        
        while Date() < deadline {
            let button = likeButtonInTopCell(tableView: tableView)
            if let value = button.value as? String, value == expected {
                return
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        }
        
        let current = (try? currentLikeValueDescription(tableView: tableView)) ?? "nil"
        XCTFail("Не дождались состояния лайка = \(expected). Текущее значение = \(current)")
    }
    
    func currentLikeValueDescription(tableView: XCUIElement) throws -> String {
        let button = likeButtonInTopCell(tableView: tableView)
        return (button.value as? String) ?? "nil"
    }
    
    func tapLikeInTopCell(tableView: XCUIElement) {
        let button = likeButtonInTopCell(tableView: tableView)
        
        if button.isHittable {
            button.tap()
            return
        }
        
        // Делаем очень маленькие подскроллы, чтобы не уехать на другую ячейку
        tableView.swipeDown()
        let afterSwipeDown = likeButtonInTopCell(tableView: tableView)
        if afterSwipeDown.isHittable {
            afterSwipeDown.tap()
            return
        }
        
        tableView.swipeUp()
        let afterSwipeUp = likeButtonInTopCell(tableView: tableView)
        if afterSwipeUp.isHittable {
            afterSwipeUp.tap()
            return
        }
        
        // fallback: тап по центру кнопки внутри текущей верхней ячейки
        let fallbackButton = likeButtonInTopCell(tableView: tableView)
        fallbackButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
    }
    
    func waitUntilTopCellLikeButtonIsInteractable(tableView: XCUIElement, timeout: TimeInterval) {
        let deadline = Date().addingTimeInterval(timeout)
        
        while Date() < deadline {
            let button = likeButtonInTopCell(tableView: tableView)
            if button.exists && button.isHittable {
                return
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        }
        
        // После reloadRows/HUD кнопка может не сразу стать hittable,
        // но нам важно хотя бы, что она снова существует в верхней ячейке.
        let button = likeButtonInTopCell(tableView: tableView)
        XCTAssertTrue(button.exists, "Кнопка лайка исчезла после обновления строки")
    }
    
    func tapCellSafely(_ cell: XCUIElement) {
        XCTAssertTrue(cell.exists, "Ячейка не существует")
        
        if cell.isHittable {
            cell.tap()
            return
        }
        
        cell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
    }
}
