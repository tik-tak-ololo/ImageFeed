import UIKit

final class ImagesListPresenter: ImagesListPresenterProtocol {

    weak var view: ImagesListViewControllerProtocol?

    private let service: ImagesListServiceProtocol
    private let router: ImagesListRouterProtocol

    private var photos: [Photo] = []
    private var isInitialLoadRequested = false

    private var isNextPageLoading = false
    private var hasMorePages = true
    private let preloadMargin = 2

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

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
        syncPhotosFromService()
        observePhotos()
        fetchInitialPhotosIfNeeded()
    }

    func didSelectRow(at indexPath: IndexPath) {
        guard let photo = photo(at: indexPath),
              let url = URL(string: photo.largeImageURL) else {
            return
        }

        router.showSingleImage(with: url)
    }

    func willDisplayRow(at indexPath: IndexPath) {
        guard shouldFetchNextPage(for: indexPath) else { return }
        fetchNextPage()
    }

    func didTapLike(at indexPath: IndexPath) {
        guard let photo = photo(at: indexPath) else {
            assertionFailure("Invalid indexPath for like: \(indexPath)")
            return
        }

        view?.showLoading()

        service.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }

            self.performOnMain {
                defer { self.view?.hideLoading() }

                switch result {
                case .success:
                    self.syncPhotosFromService()
                    self.reloadRowForPhoto(withId: photo.id)

                case .failure(let error):
                    self.view?.showError(
                        title: "Не удалось поставить лайк!",
                        message: error.localizedDescription
                    )
                }
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
            dateText: formattedDate(from: photo.createdAt),
            isLiked: photo.isLiked
        )
    }

    func heightForRow(at indexPath: IndexPath, tableWidth: CGFloat) -> CGFloat {
        guard let photo = photo(at: indexPath),
              photo.size.width > 0,
              photo.size.height > 0 else {
            return 200
        }

        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableWidth - imageInsets.left - imageInsets.right

        guard imageViewWidth > 0 else {
            return 200
        }

        let scale = imageViewWidth / photo.size.width
        let imageHeight = photo.size.height * scale

        return imageHeight + imageInsets.top + imageInsets.bottom
    }

    private func observePhotos() {
        service.observePhotos(self) { [weak self] in
            guard let self else { return }

            self.performOnMain {
                self.handlePhotosUpdated()
            }
        }
    }

    private func handlePhotosUpdated() {
        let oldPhotos = photos
        let newPhotos = service.photos

        let oldCount = oldPhotos.count
        let newCount = newPhotos.count

        photos = newPhotos

        if newCount == oldCount {
            view?.reloadData()
            return
        }

        if newCount < oldCount {
            view?.reloadData()
            return
        }

        guard hasSamePrefix(lhs: oldPhotos, rhs: newPhotos, prefixCount: oldCount) else {
            view?.reloadData()
            return
        }

        view?.insertRows(from: oldCount, to: newCount)
    }

    private func fetchInitialPhotosIfNeeded() {
        guard !isInitialLoadRequested else { return }
        isInitialLoadRequested = true

        if !service.photos.isEmpty {
            syncPhotosFromService()
            view?.reloadData()
            return
        }

        fetchNextPage()
    }

    private func fetchNextPage() {
        guard !isNextPageLoading else { return }
        guard hasMorePages else { return }

        isNextPageLoading = true

        service.fetchPhotosNextPage { [weak self] result in
            guard let self else { return }

            self.performOnMain {
                self.isNextPageLoading = false

                switch result {
                case .success:
                    break

                case .failure(let error):
                    if case NetworkError.request​In​Progress = error {
                        return
                    }

                    self.view?.showError(
                        title: "Не удалось загрузить фотографии!",
                        message: error.localizedDescription
                    )
                }
            }
        }
    }

    private func shouldFetchNextPage(for indexPath: IndexPath) -> Bool {
        guard !photos.isEmpty else { return false }
        guard !isNextPageLoading else { return false }
        guard hasMorePages else { return false }

        let thresholdIndex = max(photos.count - preloadMargin, 0)
        return indexPath.row >= thresholdIndex
    }

    private func reloadRowForPhoto(withId id: String) {
        guard let row = photos.firstIndex(where: { $0.id == id }) else {
            view?.reloadData()
            return
        }

        view?.reloadRows(at: [IndexPath(row: row, section: 0)])
    }

    private func syncPhotosFromService() {
        photos = service.photos
    }

    private func photo(at indexPath: IndexPath) -> Photo? {
        guard photos.indices.contains(indexPath.row) else { return nil }
        return photos[indexPath.row]
    }

    private func formattedDate(from date: Date?) -> String {
        guard let date else { return "" }
        return dateFormatter.string(from: date)
    }

    private func hasSamePrefix(lhs: [Photo], rhs: [Photo], prefixCount: Int) -> Bool {
        guard prefixCount <= lhs.count, prefixCount <= rhs.count else { return false }

        for index in 0..<prefixCount {
            guard lhs[index].id == rhs[index].id else { return false }
        }

        return true
    }

    private func performOnMain(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async(execute: block)
        }
    }
}
