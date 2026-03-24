//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 13.03.2026.
//

import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })
    }

    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }

    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
