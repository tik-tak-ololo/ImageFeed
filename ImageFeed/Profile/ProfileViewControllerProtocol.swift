//
//  ProfileViewProtocol.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 15.04.2026.
//

import WebKit

protocol ProfileViewControllerProtocol: AnyObject {
    func displayProfile(name: String, login: String, bio: String)
    func displayAvatar(from url: URL?)
    func showLogoutConfirmation()
    func switchToSplashScreen()
}
