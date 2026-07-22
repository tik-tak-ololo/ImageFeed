//
//  HitAreaButton.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 19.04.2026.
//

import UIKit

final class HitAreaButton: UIButton {
    
    // Насколько расширяем область (в пикселях)
    var hitTestInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let extendedBounds = bounds.inset(by: hitTestInsets)
        return extendedBounds.contains(point)
    }
}
