//
//  Constants.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 21.02.2026.
//

import Foundation

enum Constants {
    static let accessKey: String = "iKlq5DYF1ntFW79_W_E83DKPHWPS_t_KFJZViI7tv98"
    static let secretKey: String = "_zfiT_dRjRgweT9qvOVWuviyKoBR3PSX_kzXkKAHpJQ"
    static let redirectURI: String = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
}
