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
}
