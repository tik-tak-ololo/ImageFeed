//
//  ImagesListRouterSpy.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 18.04.2026.
//

@testable import ImageFeed
import Foundation

final class ImagesListRouterSpy: ImagesListRouterProtocol {
    private(set) var showSingleImageCallCount = 0
    private(set) var receivedURL: URL?

    func showSingleImage(with imageURL: URL) {
        showSingleImageCallCount += 1
        receivedURL = imageURL
    }
}
