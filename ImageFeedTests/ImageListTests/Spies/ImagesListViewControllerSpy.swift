//
//  ImagesListViewControllerSpy.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 18.04.2026.
//

import Foundation
import UIKit
@testable import ImageFeed

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    private(set) var reloadDataCallCount = 0
    private(set) var insertRowsCallCount = 0
    private(set) var reloadRowsCallCount = 0
    private(set) var showLoadingCallCount = 0
    private(set) var hideLoadingCallCount = 0
    private(set) var showLikeErrorMessages: [String] = []

    private(set) var insertedFrom: Int?
    private(set) var insertedTo: Int?
    private(set) var reloadedIndexPaths: [IndexPath]?

    func reloadData() {
        reloadDataCallCount += 1
    }

    func insertRows(from: Int, to: Int) {
        insertRowsCallCount += 1
        insertedFrom = from
        insertedTo = to
    }

    func reloadRows(at indexPaths: [IndexPath]) {
        reloadRowsCallCount += 1
        reloadedIndexPaths = indexPaths
    }

    func showLoading() {
        showLoadingCallCount += 1
    }

    func hideLoading() {
        hideLoadingCallCount += 1
    }

    func showLikeError(message: String) {
        showLikeErrorMessages.append(message)
    }
}

enum TestError: LocalizedError {
    case someError

    var errorDescription: String? {
        "Test error"
    }
}
