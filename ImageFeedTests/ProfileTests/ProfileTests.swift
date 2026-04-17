//
//  ProfileTests.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 17.04.2026.
//

@testable import ImageFeed
import XCTest

@MainActor
final class ProfileTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        //given
        let imageLoader = ImageLoaderDummy()
        let presenter = ProfilePresenterSpy()
        
        let viewController = ProfileViewController(
            presenter: presenter,
            imageLoader: imageLoader
        )
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsRender() {
        //given
        let viewController = ProfileViewControllerSpy()
        
        let profileDataProvider = ProfileDataProviderDummy()
        let profileAvatarURLProvider = ProfileAvatarURLProviderDummy()
        let profileLogoutService = ProfileLogoutServiceDummy()
        
        let presenter = ProfilePresenter(profileDataProvider: profileDataProvider,
                                         profileAvatarURLProvider: profileAvatarURLProvider,
                                         profileLogoutService: profileLogoutService)
        
        presenter.view = viewController
        viewController.presenter = presenter
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertTrue(viewController.renderCalled)
    }
    
}
