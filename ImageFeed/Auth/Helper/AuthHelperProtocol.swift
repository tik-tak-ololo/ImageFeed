//
//  AuthHelper.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 14.04.2026.
//

import Foundation

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}
