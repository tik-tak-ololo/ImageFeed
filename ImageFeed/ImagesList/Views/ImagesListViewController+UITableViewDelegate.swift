//
//  ImagesListViewController+.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 04.02.2026.
//

import UIKit

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter?.didSelectRow(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        presenter?.heightForRow(at: indexPath, tableWidth: tableView.bounds.width) ?? 200
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.willDisplayRow(at: indexPath)
    }
    
}
