//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 02.03.2026.
//

import UIKit

final class SplashViewController: UIViewController {
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"

    private let storage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupImageView()
        
        if let token = storage.token {
            fetchProfile(token: token)
        } else {
            presentAuthViewController()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func setupImageView() {
        let imageSplashScreenLogo = UIImage(named: "splashScreenLogo")

        imageView.image = imageSplashScreenLogo

        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func presentAuthViewController() {
        
        let authViewController = AuthViewController()
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }

    private func switchToTabBarController() {
        
        // Получаем активную сцену и её ключевое окно
         guard let window = UIApplication.shared.connectedScenes
             .compactMap({ $0 as? UIWindowScene })
             .flatMap({ $0.windows })
             .first(where: { $0.isKeyWindow })
         else {
             assertionFailure("Invalid window configuration")
             return
         }
        
        let tabBarController = TabBarController()
        window.rootViewController = tabBarController
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self = self else { return }

            switch result {
            case let .success(profile):
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                self.switchToTabBarController()

            case let .failure(error):
                print(error)
                break
            }
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        
        if let token = OAuth2TokenStorage.shared.token {
            fetchProfile(token: token)
        }
    }
}
