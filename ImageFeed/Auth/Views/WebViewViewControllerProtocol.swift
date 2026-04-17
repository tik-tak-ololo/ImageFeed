//
//  WebViewViewControllerProtocol.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 14.04.2026.
//

import Foundation

public protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}
