//
//  ImageListTests.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 17.04.2026.
//


@testable import ImageFeed
import XCTest

@MainActor
final class ImageListTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = ImagesListViewController()
        
        let presenter = ImageListPresenterSpy()

        viewController.presenter = presenter
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
}
