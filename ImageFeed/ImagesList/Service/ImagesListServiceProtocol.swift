//
//  ImagesListServiceProtocol.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 17.04.2026.
//

import Foundation

protocol ImagesListServiceProtocol: AnyObject {
    var photos: [Photo] { get }

    func observePhotos(_ observer: AnyObject, using closure: @escaping () -> Void)
    func removeObserver(_ observer: AnyObject)

    func fetchPhotosNextPage(completion: @escaping (Result<String, Error>) -> Void)
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void)
}
