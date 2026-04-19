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
        // 1) Ждём, пока откроется экран ленты
        let table = app.tables.firstMatch
        XCTAssertTrue(table.waitForExistence(timeout: 20), "Лента не открылась")

        // 2) Скроллим вверх, чтобы гарантированно появились реальные ячейки
        table.swipeUp()

        // 3) Находим видимую ячейку
        let cell = try visibleFeedCell(in: table)
        XCTAssertTrue(cell.exists, "Не найдена видимая ячейка ленты")

        // 4) Запоминаем исходное состояние likeButton
        let likeButton = cell.buttons["likeButton"]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 10), "В ячейке нет likeButton")

        let initialValue = (likeButton.value as? String) ?? "not_liked"
        let toggledValue = initialValue == "liked" ? "not_liked" : "liked"

        // 5) Ставим/снимаем лайк
        tapIfNeededAfterScroll(element: likeButton, container: table)

        // 6) Проверяем, что accessibilityValue изменился
        wait(forValue: toggledValue, of: likeButton, timeout: 10)
        XCTAssertEqual(likeButton.value as? String, toggledValue)

        // 7) Нажимаем ещё раз
        tapIfNeededAfterScroll(element: likeButton, container: table)

        // 8) Проверяем возврат в исходное состояние
        wait(forValue: initialValue, of: likeButton, timeout: 10)
        XCTAssertEqual(likeButton.value as? String, initialValue)

        // 9) Тап по ячейке
        tapIfNeededAfterScroll(element: cell, container: table)

        // 10) Ждём открытия картинки на весь экран
        let fullScreenImage = app.scrollViews["singleImageScrollView"]
        XCTAssertTrue(fullScreenImage.waitForExistence(timeout: 15), "Экран одиночной картинки не открылся")

        // 11) Увеличиваем картинку
        fullScreenImage.pinch(withScale: 3.0, velocity: 1.0)

        // 12) Уменьшаем картинку
        fullScreenImage.pinch(withScale: 0.5, velocity: -1.0)

        // 13) Возвращаемся на экран ленты
        let backButton = app.buttons["singleImageBackButton"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 10), "Кнопка назад не найдена")
        backButton.tap()

        XCTAssertTrue(table.waitForExistence(timeout: 10), "Не удалось вернуться на экран ленты")
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
    func visibleFeedCell(in table: XCUIElement) throws -> XCUIElement {
        let cells = table.cells
        XCTAssertGreaterThan(cells.count, 0, "В таблице нет ячеек")

        for index in 0..<cells.count {
            let cell = cells.element(boundBy: index)
            if cell.exists && cell.isHittable {
                return cell
            }
        }

        // Если после первого свайпа hittable-ячейка не нашлась — пробуем ещё немного прокрутить
        for _ in 0..<3 {
            table.swipeUp()

            for index in 0..<cells.count {
                let cell = cells.element(boundBy: index)
                if cell.exists && cell.isHittable {
                    return cell
                }
            }
        }

        XCTFail("Не удалось найти видимую hittable-ячейку")
        throw NSError(domain: "ImageFeedUITests", code: 0)
    }

    func wait(forValue value: String, of element: XCUIElement, timeout: TimeInterval) {
        let predicate = NSPredicate(format: "value == %@", value)
        expectation(for: predicate, evaluatedWith: element)
        waitForExpectations(timeout: timeout)
    }

    func tapIfNeededAfterScroll(element: XCUIElement, container: XCUIElement) {
        if element.isHittable {
            element.tap()
            return
        }

        container.swipeUp()

        if element.isHittable {
            element.tap()
            return
        }

        container.swipeDown()

        XCTAssertTrue(element.isHittable, "Элемент существует, но недоступен для нажатия")
        element.tap()
    }
}
