//
//  SingleImageViewController+ UIScrollViewDelegate.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 10.02.2026.
//

import UIKit

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
