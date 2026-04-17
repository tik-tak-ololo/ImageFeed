//
//  ImagesListViewController+.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 29.03.2026.
//

import UIKit

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.didTapLike(at: indexPath)
    }
}
