//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 01.03.2026.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: Keys.token.rawValue)
        }
        
        set {
            if let token = newValue {
                // Сохраняем токен в Keychain
                KeychainWrapper.standard.set(token, forKey: Keys.token.rawValue)
            } else {
                // Удаляем токен из Keychain
                KeychainWrapper.standard.removeObject(forKey: Keys.token.rawValue)
            }
        }
    }
    
    private enum Keys: String {
        case token          // access_token
    }
}
