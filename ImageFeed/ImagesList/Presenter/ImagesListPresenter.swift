//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 17.04.2026.
//

import UIKit

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?

    private let service: ImagesListServiceProtocol
    private let router: ImagesListRouterProtocol

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    private var photos: [Photo] = []

    init(
        view: ImagesListViewControllerProtocol,
        service: ImagesListServiceProtocol,
        router: ImagesListRouterProtocol
    ) {
        self.view = view
        self.service = service
        self.router = router
    }

    deinit {
        service.removeObserver(self)
    }

    var numberOfRows: Int {
        photos.count
    }

    func viewDidLoad() {
        observePhotos()
        fetchInitialPhotos()
    }

    func didSelectRow(at indexPath: IndexPath) {
        guard let photo = photo(at: indexPath) else { return }
        guard let url = URL(string: photo.largeImageURL) else { return }
        router.showSingleImage(with: url)
    }

    func willDisplayRow(at indexPath: IndexPath) {
        let lastRowIndex = max(photos.count - 1, 0)
        guard indexPath.row == lastRowIndex else { return }

        service.fetchPhotosNextPage { _ in }
    }

    func didTapLike(at indexPath: IndexPath) {
        guard let photo = photo(at: indexPath) else { return }

        view?.showLoading()

        service.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }

            self.view?.hideLoading()

            switch result {
            case .success:
                self.photos = self.service.photos
                self.view?.reloadRows(at: [indexPath])

            case .failure(let error):
                self.view?.showLikeError(message: error.localizedDescription)
            }
        }
    }

    func cellViewModel(for indexPath: IndexPath) -> ImagesListCellViewModel {
        guard let photo = photo(at: indexPath) else {
            return ImagesListCellViewModel(
                imageURL: nil,
                dateText: "",
                isLiked: false
            )
        }

        return ImagesListCellViewModel(
            imageURL: URL(string: photo.smallImageURL),
            dateText: photo.createdAt.map { dateFormatter.string(from: $0) } ?? "",
            isLiked: photo.isLiked
        )
    }

    func heightForRow(at indexPath: IndexPath, tableWidth: CGFloat) -> CGFloat {
        guard let photo = photo(at: indexPath), photo.size.width > 0 else {
            return 200
        }

        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableWidth - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photo.size.width
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom

        return cellHeight
    }

    private func observePhotos() {
        service.observePhotos(self) { [weak self] in
            guard let self else { return }

            let oldCount = self.photos.count
            let newCount = self.service.photos.count
            self.photos = self.service.photos

            self.view?.insertRows(from: oldCount, to: newCount)
        }
    }

    private func fetchInitialPhotos() {
        service.fetchPhotosNextPage { _ in }
    }
    
    private func photo(at indexPath: IndexPath) -> Photo? {
        guard photos.indices.contains(indexPath.row) else { return nil }
        return photos[indexPath.row]
    }
}
