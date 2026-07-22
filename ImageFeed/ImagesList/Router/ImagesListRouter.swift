//
//  ImagesListRouter.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 17.04.2026.
//

import UIKit

final class ImagesListRouter: ImagesListRouterProtocol {
    weak var viewController: UIViewController?

    func showSingleImage(with imageURL: URL) {
        let singleImageViewController = SingleImageViewController()
        singleImageViewController.imageURL = imageURL
        viewController?.present(singleImageViewController, animated: true)
    }
}
