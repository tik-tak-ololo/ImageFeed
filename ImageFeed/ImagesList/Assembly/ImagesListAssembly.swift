//
//  ImagesListAssembly.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 17.04.2026.
//

import UIKit

enum ImagesListAssembly {
    static func build() -> UIViewController {
        let viewController = ImagesListViewController()

        let router = ImagesListRouter()
        router.viewController = viewController

        let service = ImagesListServiceAdapter(service: ImagesListService())

        let presenter = ImagesListPresenter(
            view: viewController,
            service: service,
            router: router
        )

        viewController.presenter = presenter

        return viewController
    }
}
