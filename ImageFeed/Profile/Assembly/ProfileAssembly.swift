//
//  ProfileAssembly.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 16.04.2026.
//

import UIKit

enum ProfileAssembly {
    static func build() -> UIViewController {
        
        let profileService = ProfileService.shared
        let profileImageService = ProfileImageService.shared
        let logoutService = ProfileLogoutService.shared
        let imageLoader = KingfisherImageLoader()
        let router = ProfileRouter()
        
        let presenter = ProfilePresenter(profileDataProvider: profileService,
                                         profileAvatarURLProvider: profileImageService,
                                         profileLogoutService: logoutService,
                                         profileRouter: router)
        
        let viewController = ProfileViewController(
            presenter: presenter,
            imageLoader: imageLoader
        )
        
        presenter.view = viewController
        
        return viewController
    }
}
