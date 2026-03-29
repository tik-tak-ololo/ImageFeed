//
//  ImagesListViewController+.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 04.02.2026.
//

import UIKit
import Kingfisher

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)

        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        let photo = photos[indexPath.row]
        
        configureCell(imageListCell: imageListCell, with: photo)
        
        imageListCell.delegate = self
        
        return imageListCell
    }
    
    func configureCell(imageListCell: ImagesListCell, with photo: Photo) {

        imageListCell.cellImage.kf.indicatorType = .activity
        let placeholder = UIImage(named: "placeholder_image")
        if let thumbURL = URL(string: photo.thumbImageURL) {
            imageListCell.cellImage.kf.setImage(
                with: thumbURL,
                placeholder: placeholder,
                options: [.transition(.fade(0.2)), .cacheOriginalImage])
        }
        
        imageListCell.dateLabel.text = photo.createdAt != nil ? DateFormatter.localizedString(from: photo.createdAt!, dateStyle: .long, timeStyle: .none) : ""
        
        let likeImage = photo.isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        imageListCell.likeButton.setImage(likeImage, for: .normal)
        
    }
    
}
