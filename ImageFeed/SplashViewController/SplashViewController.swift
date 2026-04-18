//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 02.03.2026.
//

import UIKit

final class SplashViewController: UIViewController {
    private let storage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared

    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .logo))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlackIOS
        setupImageView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let token = storage.token {
            fetchProfile(token: token)
        } else {
            presentAuthFlow()
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
        guard imageView.superview == nil else { return }

        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func presentAuthFlow() {
        let authViewController = AuthViewController()
        authViewController.delegate = self

        let navigationController = UINavigationController(rootViewController: authViewController)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.setNavigationBarHidden(true, animated: false)

        present(navigationController, animated: true)
    }

    private func switchToTabBarController() {
        guard let window = view.window else {
            assertionFailure("SplashViewController is not attached to window")
            return
        }

        window.rootViewController = TabBarController()
    }

    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()

        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self else { return }

            switch result {
            case let .success(profile):
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                self.switchToTabBarController()

            case let .failure(error):
                print(error)
            }
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.navigationController?.dismiss(animated: true) { [weak self] in
            guard let self else { return }

            if let token = OAuth2TokenStorage.shared.token {
                self.fetchProfile(token: token)
            }
        }
    }
}
