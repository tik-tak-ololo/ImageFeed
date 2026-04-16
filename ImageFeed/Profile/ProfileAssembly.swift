//
//  ProfileAssembly.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 16.04.2026.
//

import UIKit

enum ProfileAssembly {
    static func build() -> UIViewController {
        let viewController = ProfileViewController()
        let presenter = ProfilePresenter(view: viewController)
        viewController.presenter = presenter
        return viewController
    }
}
