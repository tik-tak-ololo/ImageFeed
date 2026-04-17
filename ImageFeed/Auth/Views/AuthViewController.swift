//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 22.02.2026.
//

import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    
    private let oauth2Service = OAuth2Service.shared
    weak var delegate: AuthViewControllerDelegate?
    
    private let logoImageView: UIImageView = {
        let logoImageView = UIImageView()
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        return logoImageView
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Войти", for: .normal)
        button.setTitleColor(.ypBlackIOS, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.backgroundColor = .ypWhiteIOS
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    override func viewDidLoad() {
        
        setupView()
        setupSubviews()
        setupConstraints()
        setupContent()
        setupActions()
        
        configureBackButton()
    }
    
    private func setupView() {
        view.backgroundColor = .ypBlackIOS
    }
    
    private func setupSubviews() {
        view.addSubview(logoImageView)
        view.addSubview(loginButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90),
            loginButton.heightAnchor.constraint(equalToConstant: 48)

        ])
    }
    
    private func setupContent() {
        logoImageView.image = UIImage(resource: .authScreenLogo )
    }
    
    private func setupActions() {
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(resource: .navBackButton)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(resource: .navBackButton)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .ypBlackIOS
    }
    
    @objc private func didTapLoginButton() {
        presentWebViewViewController()
    }
    
    private func presentWebViewViewController() {
        
        let webViewViewController = WebViewViewController()
        webViewViewController.delegate = self
        
        let authHelper = AuthHelper()
        let webViewPresenter = WebViewPresenter(authHelper: authHelper)
        webViewPresenter.view = webViewViewController
        webViewViewController.presenter = webViewPresenter
        
        webViewViewController.modalPresentationStyle = .fullScreen
        present(webViewViewController, animated: true)
    }
    
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        
        vc.dismiss(animated: true)
        
        UIBlockingProgressHUD.show()
        
        fetchOAuthToken(code) { [weak self] result in
            
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.delegate?.didAuthenticate(self)
            case let .failure(error):
                print("Ошибка при аутентификации: \(error.localizedDescription)")
                self.showAuthErrorAlert()  // Показываем алерт при ошибке
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}

extension AuthViewController {
    private func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        oauth2Service.fetchOAuthToken(code) { result in
            completion(result)
        }
    }
}

extension AuthViewController {
    func showAuthErrorAlert() {
        let alertController = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "Ок", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
