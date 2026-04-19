//
//  ImagesListPresenterProtocol.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 17.04.2026.
//

import UIKit

protocol ImagesListPresenterProtocol: AnyObject {
    var numberOfRows: Int { get }

    func viewDidLoad()
    func didSelectRow(at indexPath: IndexPath)
    func willDisplayRow(at indexPath: IndexPath)
    func didTapLike(at indexPath: IndexPath)

    func cellViewModel(for indexPath: IndexPath) -> ImagesListCellViewModel
    func heightForRow(at indexPath: IndexPath, tableWidth: CGFloat) -> CGFloat
}
