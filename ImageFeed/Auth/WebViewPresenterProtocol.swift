//
//  WebViewPresenterProtocol.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 14.04.2026.
//

import Foundation

public protocol WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}
