//
//  ImagesListServiceAdapter.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 17.04.2026.
//

import Foundation

final class ImagesListServiceAdapter: ImagesListServiceProtocol {
    private let service: ImagesListService
    private var observers: [ObjectIdentifier: NSObjectProtocol] = [:]

    init(service: ImagesListService = ImagesListService()) {
        self.service = service
    }

    var photos: [Photo] {
        service.photos
    }

    func observePhotos(_ observer: AnyObject, using closure: @escaping () -> Void) {
        let token = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            closure()
        }

        observers[ObjectIdentifier(observer)] = token
    }

    func removeObserver(_ observer: AnyObject) {
        let key = ObjectIdentifier(observer)
        guard let token = observers[key] else { return }
        NotificationCenter.default.removeObserver(token)
        observers.removeValue(forKey: key)
    }

    func fetchPhotosNextPage(completion: @escaping (Result<String, Error>) -> Void) {
        service.fetchPhotosNextPage(completion: completion)
    }

    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        service.changeLike(photoId: photoId, isLike: isLike, completion: completion)
    }
}
