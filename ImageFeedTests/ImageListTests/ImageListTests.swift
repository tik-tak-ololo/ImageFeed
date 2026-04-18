//
//  ImageListTests.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 17.04.2026.
//


@testable import ImageFeed
import XCTest

@MainActor
final class ImagesListTests: XCTestCase {

    // MARK: - Tests
    
    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = ImagesListViewController()
        let presenter = ImageListPresenterSpy()
        viewController.presenter = presenter
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testViewDidLoad_WhenServiceHasNoPhotos_FetchesInitialPageAndStartsObserving() {
        let view = ImagesListViewControllerSpy()
        let service = ImagesListServiceMock()
        let router = ImagesListRouterSpy()

        let sut = makeSUT(view: view, service: service, router: router)

        sut.viewDidLoad()

        XCTAssertTrue(service.observePhotosCalled)
        XCTAssertEqual(service.fetchPhotosNextPageCallCount, 1)
        XCTAssertEqual(view.reloadDataCallCount, 0)
    }

    func testViewDidLoad_WhenServiceAlreadyHasPhotos_ReloadsDataAndDoesNotFetch() {
        let view = ImagesListViewControllerSpy()
        let service = ImagesListServiceMock()
        let router = ImagesListRouterSpy()

        service.photos = [
            makePhoto(id: "1")
        ]

        let sut = makeSUT(view: view, service: service, router: router)

        sut.viewDidLoad()

        XCTAssertTrue(service.observePhotosCalled)
        XCTAssertEqual(service.fetchPhotosNextPageCallCount, 0)
        XCTAssertEqual(view.reloadDataCallCount, 1)
        XCTAssertEqual(sut.numberOfRows, 1)
    }

    func testViewDidLoad_CalledTwice_DoesNotRequestInitialLoadTwice() {
        let view = ImagesListViewControllerSpy()
        let service = ImagesListServiceMock()
        let router = ImagesListRouterSpy()

        let sut = makeSUT(view: view, service: service, router: router)

        sut.viewDidLoad()
        sut.viewDidLoad()

        XCTAssertEqual(service.fetchPhotosNextPageCallCount, 1)
    }

    func testDidSelectRow_WithValidPhoto_RoutesToSingleImage() {
        let view = ImagesListViewControllerSpy()
        let service = ImagesListServiceMock()
        let router = ImagesListRouterSpy()

        service.photos = [
            makePhoto(id: "1", largeImageURL: "https://example.com/large.jpg")
        ]

        let sut = makeSUT(view: view, service: service, router: router)
        sut.viewDidLoad()

        sut.didSelectRow(at: IndexPath(row: 0, section: 0))

        XCTAssertEqual(router.showSingleImageCallCount, 1)
        XCTAssertEqual(router.receivedURL?.absoluteString, "https://example.com/large.jpg")
    }

    func testDidSelectRow_WithInvalidIndexPath_DoesNothing() {
        let view = ImagesListViewControllerSpy()
        let service = ImagesListServiceMock()
        let router = ImagesListRouterSpy()

        service.photos = [makePhoto(id: "1")]

        let sut = makeSUT(view: view, service: service, router: router)
        sut.viewDidLoad()

        sut.didSelectRow(at: IndexPath(row: 99, section: 0))

        XCTAssertEqual(router.showSingleImageCallCount, 0)
    }

    func testWillDisplayRow_WhenLastRow_FetchesNextPage() {
        let view = ImagesListViewControllerSpy()
        let service = ImagesListServiceMock()
        let router = ImagesListRouterSpy()

        service.photos = [
            makePhoto(id: "1"),
            makePhoto(id: "2")
        ]

        let sut = makeSUT(view: view, service: service, router: router)
        sut.viewDidLoad()

        sut.willDisplayRow(at: IndexPath(row: 1, section: 0))

        XCTAssertEqual(service.fetchPhotosNextPageCallCount, 1) // только initial load не был вызван, т.к. фото уже были
    }

    func testWillDisplayRow_WhenNotLastRow_DoesNotFetchNextPage() {
        let view = ImagesListViewControllerSpy()
        let service = ImagesListServiceMock()
        let router = ImagesListRouterSpy()

        service.photos = [
            makePhoto(id: "1"),
            makePhoto(id: "2"),
            makePhoto(id: "3")
        ]

        let sut = makeSUT(view: view, service: service, router: router)
        sut.viewDidLoad()

        sut.willDisplayRow(at: IndexPath(row: 0, section: 0))

        XCTAssertEqual(service.fetchPhotosNextPageCallCount, 0)
    }

    func testDidTapLike_OnSuccess_ShowsAndHidesLoading_ChangesLikeAndReloadsRow() {
        let view = ImagesListViewControllerSpy()
        let service = ImagesListServiceMock()
        let router = ImagesListRouterSpy()

        service.photos = [
            makePhoto(id: "1", isLiked: false)
        ]

        let sut = makeSUT(view: view, service: service, router: router)
        sut.viewDidLoad()

        let exp = expectation(description: "like completion")

        service.changeLikeHandler = {photoId, isLike, completion in
            XCTAssertEqual(photoId, "1")
            XCTAssertEqual(isLike, true)

            service.photos = [
                self.makePhoto(id: "1", isLiked: true)
            ]

            completion(.success(()))
            exp.fulfill()
        }

        sut.didTapLike(at: IndexPath(row: 0, section: 0))

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(view.showLoadingCallCount, 1)
        XCTAssertEqual(view.hideLoadingCallCount, 1)
        XCTAssertEqual(view.reloadRowsCallCount, 1)
        XCTAssertEqual(view.reloadedIndexPaths, [IndexPath(row: 0, section: 0)])
        XCTAssertEqual(view.showLikeErrorMessages.count, 0)
    }

    func testDidTapLike_OnFailure_ShowsAndHidesLoading_AndShowsError() {
        let view = ImagesListViewControllerSpy()
        let service = ImagesListServiceMock()
        let router = ImagesListRouterSpy()

        service.photos = [
            makePhoto(id: "1", isLiked: false)
        ]

        let sut = makeSUT(view: view, service: service, router: router)
        sut.viewDidLoad()

        let exp = expectation(description: "like failure")

        service.changeLikeHandler = { _, _, completion in
            completion(.failure(TestError.someError))
            exp.fulfill()
        }

        sut.didTapLike(at: IndexPath(row: 0, section: 0))

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(view.showLoadingCallCount, 1)
        XCTAssertEqual(view.hideLoadingCallCount, 1)
        XCTAssertEqual(view.reloadRowsCallCount, 0)
        XCTAssertEqual(view.showLikeErrorMessages.count, 1)
    }

    func testCellViewModel_ReturnsCorrectData() {
        let view = ImagesListViewControllerSpy()
        let service = ImagesListServiceMock()
        let router = ImagesListRouterSpy()

        let date = Date(timeIntervalSince1970: 1_700_000_000)

        service.photos = [
            makePhoto(
                id: "1",
                createdAt: date,
                smallImageURL: "https://example.com/small.jpg",
                isLiked: true
            )
        ]

        let sut = makeSUT(view: view, service: service, router: router)
        sut.viewDidLoad()

        let viewModel = sut.cellViewModel(for: IndexPath(row: 0, section: 0))

        XCTAssertEqual(viewModel.imageURL?.absoluteString, "https://example.com/small.jpg")
        XCTAssertFalse(viewModel.dateText.isEmpty)
        XCTAssertTrue(viewModel.isLiked)
    }

    func testCellViewModel_WithInvalidIndexPath_ReturnsFallbackViewModel() {
        let view = ImagesListViewControllerSpy()
        let service = ImagesListServiceMock()
        let router = ImagesListRouterSpy()

        let sut = makeSUT(view: view, service: service, router: router)

        let viewModel = sut.cellViewModel(for: IndexPath(row: 0, section: 0))

        XCTAssertNil(viewModel.imageURL)
        XCTAssertEqual(viewModel.dateText, "")
        XCTAssertFalse(viewModel.isLiked)
    }

    func testHeightForRow_ReturnsCalculatedHeight() {
        let view = ImagesListViewControllerSpy()
        let service = ImagesListServiceMock()
        let router = ImagesListRouterSpy()

        service.photos = [
            makePhoto(id: "1", size: CGSize(width: 100, height: 200))
        ]

        let sut = makeSUT(view: view, service: service, router: router)
        sut.viewDidLoad()

        let height = sut.heightForRow(at: IndexPath(row: 0, section: 0), tableWidth: 332)
        // tableWidth - 16 - 16 = 300
        // scale = 300 / 100 = 3
        // imageHeight = 200 * 3 = 600
        // total = 600 + 4 + 4 = 608
        XCTAssertEqual(height, 608, accuracy: 0.001)
    }

    func testHeightForRow_WithInvalidPhotoSize_ReturnsFallbackHeight() {
        let view = ImagesListViewControllerSpy()
        let service = ImagesListServiceMock()
        let router = ImagesListRouterSpy()

        service.photos = [
            makePhoto(id: "1", size: .zero)
        ]

        let sut = makeSUT(view: view, service: service, router: router)
        sut.viewDidLoad()

        let height = sut.heightForRow(at: IndexPath(row: 0, section: 0), tableWidth: 320)

        XCTAssertEqual(height, 200)
    }

    func testObserver_WhenNewPhotosAppended_InsertsRows() {
        let view = ImagesListViewControllerSpy()
        let service = ImagesListServiceMock()
        let router = ImagesListRouterSpy()

        service.photos = [
            makePhoto(id: "1"),
            makePhoto(id: "2")
        ]

        let sut = makeSUT(view: view, service: service, router: router)
        sut.viewDidLoad()

        service.photos = [
            makePhoto(id: "1"),
            makePhoto(id: "2"),
            makePhoto(id: "3"),
            makePhoto(id: "4")
        ]

        service.notifyPhotosChanged()

        XCTAssertEqual(view.insertRowsCallCount, 1)
        XCTAssertEqual(view.insertedFrom, 2)
        XCTAssertEqual(view.insertedTo, 4)
    }

    func testObserver_WhenPrefixChanged_ReloadsData() {
        let view = ImagesListViewControllerSpy()
        let service = ImagesListServiceMock()
        let router = ImagesListRouterSpy()

        service.photos = [
            makePhoto(id: "1"),
            makePhoto(id: "2")
        ]

        let sut = makeSUT(view: view, service: service, router: router)
        sut.viewDidLoad()

        let reloadDataCallCountBeforeUpdate = view.reloadDataCallCount
        let insertRowsCallCountBeforeUpdate = view.insertRowsCallCount

        service.photos = [
            makePhoto(id: "999"),
            makePhoto(id: "2")
        ]

        service.notifyPhotosChanged()

        XCTAssertEqual(view.reloadDataCallCount, reloadDataCallCountBeforeUpdate + 1)
        XCTAssertEqual(view.insertRowsCallCount, insertRowsCallCountBeforeUpdate)
    }
    
    func testFetchNextPageFailure_ShowsError() {
        let view = ImagesListViewControllerSpy()
        let service = ImagesListServiceMock()
        let router = ImagesListRouterSpy()

        let exp = expectation(description: "fetch failure")

        service.fetchPhotosNextPageHandler = { completion in
            completion(.failure(TestError.someError))
            exp.fulfill()
        }

        let sut = makeSUT(view: view, service: service, router: router)
        sut.viewDidLoad()

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(view.showLikeErrorMessages.count, 1)
    }
}

// MARK: - Helpers

private extension ImagesListTests {
    func makeSUT(
        view: ImagesListViewControllerSpy = ImagesListViewControllerSpy(),
        service: ImagesListServiceMock = ImagesListServiceMock(),
        router: ImagesListRouterSpy = ImagesListRouterSpy()
    ) -> ImagesListPresenter {
        ImagesListPresenter(
            view: view,
            service: service,
            router: router
        )
    }

    func makePhoto(
        id: String,
        size: CGSize = CGSize(width: 100, height: 100),
        createdAt: Date? = nil,
        smallImageURL: String = "https://example.com/small.jpg",
        regularImageURL: String = "https://example.com/regular.jpg",
        largeImageURL: String = "https://example.com/large.jpg",
        isLiked: Bool = false
    ) -> Photo {
        Photo(
            id: id,
            size: size,
            createdAt: createdAt,
            welcomeDescription: nil,
            thumbImageURL: "https://example.com/thumb.jpg",
            smallImageURL: smallImageURL,
            regularImageURL: regularImageURL,
            largeImageURL: largeImageURL,
            isLiked: isLiked
        )
    }
}

