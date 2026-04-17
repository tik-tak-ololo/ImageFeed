//
//  ImagesListViewControllerProtocol.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 17.04.2026.
//

import UIKit

protocol ImagesListViewControllerProtocol: AnyObject {
    func insertRows(from oldCount: Int, to newCount: Int)
    func reloadRows(at indexPaths: [IndexPath])
    func showLoading()
    func hideLoading()
    func showLikeError(message: String)
}
