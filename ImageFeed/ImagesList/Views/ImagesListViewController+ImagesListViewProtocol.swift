//
//  ImagesListViewController+ImagesListViewProtocol.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 17.04.2026.
//

import Foundation
import UIKit

extension ImagesListViewController: ImagesListViewControllerProtocol {
    func insertRows(from oldCount: Int, to newCount: Int) {
        guard oldCount != newCount else { return }

        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map {
                IndexPath(row: $0, section: 0)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }

    func reloadRows(at indexPaths: [IndexPath]) {
        tableView.reloadRows(at: indexPaths, with: .automatic)
    }

    func showLoading() {
        UIBlockingProgressHUD.show()
    }

    func hideLoading() {
        UIBlockingProgressHUD.dismiss()
    }

    func showLikeError(message: String) {
        let alert = UIAlertController(
            title: "Не удалось поставить лайк.",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
