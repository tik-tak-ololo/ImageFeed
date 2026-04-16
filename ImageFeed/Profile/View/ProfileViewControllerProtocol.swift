//
//  ProfileViewProtocol.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 15.04.2026.
//

import WebKit

protocol ProfileViewControllerProtocol: AnyObject {
    func render(viewModel: ProfileViewModel)
    func showLogoutConfirmation()
    func switchToSplashScreen()
}
