//
//  Photo.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 28.03.2026.
//

import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let smallImageURL: String
    let regularImageURL: String
    let largeImageURL: String
    var isLiked: Bool
}
