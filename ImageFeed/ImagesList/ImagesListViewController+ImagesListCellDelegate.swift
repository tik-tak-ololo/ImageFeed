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
        let photo = photos[indexPath.row]
        // Покажем лоадер
       UIBlockingProgressHUD.show()
       imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
          switch result {
          case .success:
             // Синхронизируем массив картинок с сервисом
             self.photos = self.imagesListService.photos
             // Изменим индикацию лайка картинки
              cell.setIsLiked(self.photos[indexPath.row].isLiked)
             // Уберём лоадер
             UIBlockingProgressHUD.dismiss()
          case .failure:
             // Уберём лоадер
             UIBlockingProgressHUD.dismiss()
             // Покажем, что что-то пошло не так
             // TODO: Показать ошибку с использованием UIAlertController
             }
          }
    }
}
