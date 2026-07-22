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
    
    var renderedViewModel: ProfileViewModel?
    var renderCallCount = 0
    var didShowLogoutConfirmation = false
    
    var renderCalled: Bool = false
    
    func render(viewModel: ProfileViewModel) {
        renderCalled = true
        renderCallCount += 1
        renderedViewModel = viewModel
    }
    
    func showLogoutConfirmation() {
        didShowLogoutConfirmation = true
    }
    

}

