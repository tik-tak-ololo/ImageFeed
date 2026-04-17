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
    
    func testViewDidLoadRendersProfileWithProvidedData() {
        //given
        let view = ProfileViewControllerSpy()
        let dataProvider = ProfileDataProviderStub()
        dataProvider.profile = Profile(
            username: "id",
            name: "Sergey Khmelow",
            loginName: "@tik_tak_ololo",
            bio: "iOS Developer"
        )
        
        let avatarProvider = ProfileAvatarURLProviderStub()
        avatarProvider.avatarURL = "https://example.com/avatar.jpg"
        
        let logoutService = ProfileLogoutServiceSpy()
        
        let presenter = ProfilePresenter(
            profileDataProvider: dataProvider,
            profileAvatarURLProvider: avatarProvider,
            profileLogoutService: logoutService
        )
        presenter.view = view
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertEqual(view.renderCallCount, 1)
        XCTAssertEqual(view.renderedViewModel?.fullName, "Sergey Khmelow")
        XCTAssertEqual(view.renderedViewModel?.username, "@tik_tak_ololo")
        XCTAssertEqual(view.renderedViewModel?.bio, "iOS Developer")
        XCTAssertEqual(view.renderedViewModel?.avatarURL?.absoluteString, "https://example.com/avatar.jpg")
    }
    
    func testViewDidLoadRendersFallbackNameWhenNameIsBlank() {
        let view = ProfileViewControllerSpy()
        let dataProvider = ProfileDataProviderStub()
        dataProvider.profile = Profile(
            username: "id",
            name: "   ",
            loginName: "@sergey",
            bio: "Bio"
        )
        
        let avatarProvider = ProfileAvatarURLProviderStub()
        let logoutService = ProfileLogoutServiceSpy()
        
        let presenter = ProfilePresenter(
            profileDataProvider: dataProvider,
            profileAvatarURLProvider: avatarProvider,
            profileLogoutService: logoutService
        )
        presenter.view = view
        
        presenter.viewDidLoad()
        
        XCTAssertEqual(view.renderedViewModel?.fullName, "Имя не указано")
    }
    
    func testDidTapLogoutAsksViewToShowConfirmation() {
        let view = ProfileViewControllerSpy()
        let presenter = ProfilePresenter(
            profileDataProvider: ProfileDataProviderStub(),
            profileAvatarURLProvider: ProfileAvatarURLProviderStub(),
            profileLogoutService: ProfileLogoutServiceSpy()
        )
        presenter.view = view
        
        presenter.didTapLogout()
        
        XCTAssertTrue(view.didShowLogoutConfirmation)
    }
    
    func testDidConfirmLogoutCallsLogoutAndSwitchesToSplash() {
        let view = ProfileViewControllerSpy()
        let logoutService = ProfileLogoutServiceSpy()
        
        let presenter = ProfilePresenter(
            profileDataProvider: ProfileDataProviderStub(),
            profileAvatarURLProvider: ProfileAvatarURLProviderStub(),
            profileLogoutService: logoutService
        )
        presenter.view = view
        
        presenter.didConfirmLogout()
        
        XCTAssertEqual(logoutService.logoutCallCount, 1)
        XCTAssertTrue(view.didSwitchToSplashScreen)
    }
    
}
