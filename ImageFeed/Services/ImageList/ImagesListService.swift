//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 28.03.2026.
//

import Foundation


struct PhotoResult: Decodable {
    let id: String
    let width: CGFloat
    let height: CGFloat
    let createdAt: String?
    let description: String?
    let altDescription: String?
    let urls: UrlsResult
    let likedByUser: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case createdAt = "created_at"
        case description
        case altDescription = "alt_description"
        case urls
        case likedByUser = "liked_by_user"
    }
}

struct UrlsResult: Decodable {
    let thumb: String
    let full: String
}

extension PhotoResult {

    func getPhoto(dateFormatter: ISO8601DateFormatter) -> Photo {
        let date: Date?
        if let createdAt {
            date = dateFormatter.date(from: createdAt)
        } else {
            date = nil
        }

        return Photo(
            id: id,
            size: CGSize(width: width, height: height),
            createdAt: date,
            welcomeDescription: description ?? altDescription,
            thumbImageURL: urls.thumb,
            largeImageURL: urls.full,
            isLiked: likedByUser
        )
    }
}

final class ImagesListService {
    private(set) var photos: [Photo] = []
    private var task: URLSessionTask?
    private var lastLoadedPage: Int?
    private let dateFormatter: ISO8601DateFormatter
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    init() {
        self.dateFormatter = ISO8601DateFormatter()
    }
    
    
    func fetchPhotosNextPage(completion: @escaping (Result<String, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        
        if task != nil {
            completion(.failure(NetworkError.request​In​Progress))
            return
        }
        
        guard let token = OAuth2TokenStorage.shared.token else {
            completion(.failure(NSError(domain: "ImagesListService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authorization token missing"])))
            return
        }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        let perPage = 10                                                                                // TODO: ???
        
        guard let request = makePhotosNextPageRequest(nextPage: nextPage, perPage: perPage, token: token) else {
            completion(.failure(NetworkError.invalidRequest))
            print("Ошибка создания запроса: \(NetworkError.invalidRequest)")
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let photoResults):
                let newPhotos = photoResults.map { $0.getPhoto(dateFormatter: self.dateFormatter) }
                photos.append(contentsOf: newPhotos)
                lastLoadedPage = nextPage
                
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self,
                    userInfo: ["photos": self.photos]
                )
                
                completion(.success("Загружено \(newPhotos.count) изображений! Текущий размер списка: \(self.photos.count) изображений!"))

            case .failure(let error):
                print("[fetchPhotosNextPage]: Ошибка запроса: \(error.localizedDescription)")
                completion(.failure(error))
            }
            
            self.task = nil
        }
        
        self.task = task
        
        task.resume()

    }
    
    private func makePhotosNextPageRequest(nextPage: Int, perPage: Int, token: String) -> URLRequest? {
        
        guard var urlComponents = URLComponents(string: "\(Constants.defaultBaseURL)/photos") else {
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(nextPage)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        
        guard let url = urlComponents.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
    
