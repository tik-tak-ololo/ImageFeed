//
//  ImagesListServiceMock.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 18.04.2026.
//

import Foundation
@testable import ImageFeed

final class ImagesListServiceMock: ImagesListServiceProtocol {
    var photos: [Photo] = []

    private(set) var observePhotosCalled = false
    private(set) var removeObserverCalled = false
    private(set) var fetchPhotosNextPageCallCount = 0
    private(set) var changeLikeCallCount = 0

    private var observerClosure: (() -> Void)?

    var fetchPhotosNextPageHandler: ((@escaping (Result<String, Error>) -> Void) -> Void)?
    var changeLikeHandler: ((String, Bool, @escaping (Result<Void, Error>) -> Void) -> Void)?

    func observePhotos(_ observer: AnyObject, using closure: @escaping () -> Void) {
        observePhotosCalled = true
        observerClosure = closure
    }

    func removeObserver(_ observer: AnyObject) {
        removeObserverCalled = true
    }

    func fetchPhotosNextPage(completion: @escaping (Result<String, Error>) -> Void) {
        fetchPhotosNextPageCallCount += 1

        if let fetchPhotosNextPageHandler {
            fetchPhotosNextPageHandler(completion)
        } else {
            completion(.success("OK"))
        }
    }

    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCallCount += 1

        if let changeLikeHandler {
            changeLikeHandler(photoId, isLike, completion)
        } else {
            completion(.success(()))
        }
    }

    func notifyPhotosChanged() {
        observerClosure?()
    }
}
