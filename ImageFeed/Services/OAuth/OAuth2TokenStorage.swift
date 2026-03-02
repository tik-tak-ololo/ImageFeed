//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 01.03.2026.
//

import Foundation

final class OAuth2TokenStorage {
    
    private let storage: UserDefaults = .standard
    
    var token: String? {
        get {
            return storage.string(forKey: Keys.token.rawValue)
        }
        
        set {
            storage.set(newValue, forKey: Keys.token.rawValue)
        }
    }
    
    private enum Keys: String {
        case token          // access_token
    }
}
