//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 01.03.2026.
//

import Foundation

struct OAuthTokenResponseBody: Codable {
    let access_token: String
    let token_type: String
    let scope: String
    let created_at: Int
}

final class OAuth2Service {
    
    private let tokenStorage = OAuth2TokenStorage()
    static let shared = OAuth2Service()
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private init() { }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        if task != nil {
            if lastCode != code {
                task?.cancel()
            } else {
                completion(.failure(NetworkError.invalidRequest))
                return
            }
        } else {
            if lastCode == code {
                completion(.failure(NetworkError.invalidRequest))
                return
            }
        }
        lastCode = code
        
        let request = makeOAuthTokenRequest(code: code)
        
        guard let request else {
            completion(.failure(NetworkError.invalidRequest))
            print("Ошибка создания запроса: \(NetworkError.invalidRequest)")
            return
        }
        
        let task = URLSession.shared.data(for: request) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                
                do {
                    let dataToken = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    self.tokenStorage.token = dataToken.access_token
                    completion(.success(dataToken.access_token))
                } catch {
                    print("Ошибка: \(error)")
                    completion(.failure(error))
                }
                
            case .failure(let error):
                print("Ошибка: \(error)")
                completion(.failure(error))
            }
            
            self.task = nil
            self.lastCode = nil
                
        }
        
        self.task = task
        
        task.resume()
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            return nil
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]

        guard let authTokenUrl = urlComponents.url else {
            return nil
        }

        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = "POST"
        return request
    }
     
}
