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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = storage.token {
            fetchProfile(token: token)
        } else {
            // Show Auth Screen
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
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
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
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

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                return
            }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.navigationController?.popViewController(animated: true)
        
        if let token = OAuth2TokenStorage.shared.token {
            fetchProfile(token: token)
        }
    }
}
