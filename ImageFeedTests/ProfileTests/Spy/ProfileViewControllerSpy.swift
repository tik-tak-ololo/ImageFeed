//
//  ProfileViewControllerSpy.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 17.04.2026.
//

import Foundation
@testable import ImageFeed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    
    var presenter: ProfilePresenterProtocol?
    
    var renderCalled: Bool = false
    
    func render(viewModel: ImageFeed.ProfileViewModel) {
        renderCalled = true
    }
    
    func showLogoutConfirmation() {

    }
    
    func switchToSplashScreen() {
        //given
        
    }
}

