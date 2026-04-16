//
//  KingfisherImageLoader.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 17.04.2026.
//

import UIKit
import Kingfisher

final class KingfisherImageLoader: ImageLoader {
    
    func setImage(
        on imageView: UIImageView,
        from url: URL?,
        placeholder: UIImage?
    ) {
        guard let url else {
            imageView.image = placeholder
            return
        }
        
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [
                .processor(RoundCornerImageProcessor(cornerRadius: imageView.bounds.height / 2)),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .forceRefresh
            ]
        )
    }
}
