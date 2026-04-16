//
//  ImageLoader.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 17.04.2026.
//

import UIKit

protocol ImageLoader {
    func setImage(
        on imageView: UIImageView,
        from url: URL?,
        placeholder: UIImage?
    )
}
