//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 07.02.2026.
//

import UIKit

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    
    private let avatarImageView: UIImageView = {
        let avatarImageView = UIImageView()
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 35
        return avatarImageView
    }()
    
    private let nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        nameLabel.textColor = .ypWhiteIOS
        nameLabel.numberOfLines = 0
        return nameLabel
    }()
    
    private let loginNameLabel: UILabel = {
        let loginNameLabel = UILabel()
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        loginNameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        loginNameLabel.textColor = .ypGrayIOS
        loginNameLabel.numberOfLines = 1
        return loginNameLabel
    }()
    
    private let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = .ypWhiteIOS
        descriptionLabel.numberOfLines = 0
        return descriptionLabel
    }()
    
    private let logoutButton: UIButton = {
        let logoutButton = UIButton(type: .custom)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        return logoutButton
    }()
    
    let presenter: ProfilePresenterProtocol
    private let imageLoader: ImageLoader
    
    init(
        presenter: ProfilePresenterProtocol,
        imageLoader: ImageLoader
    ) {
        self.presenter = presenter
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupSubviews()
        setupConstraints()
        setupContent()
        setupActions()
        
        presenter.viewDidLoad()
    }
    
    private func setupView() {
        view.backgroundColor = .ypBlackIOS
    }
    
    private func setupSubviews() {
        view.addSubview(avatarImageView)
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            
            loginNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            loginNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
        ])
    }
    
    private func setupContent() {
        logoutButton.setImage(UIImage(resource: .exitButton), for: .normal)
    }
    
    private func setupActions() {
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
    }
    
    @objc
    private func didTapLogoutButton() {
        presenter.didTapLogout()
    }
    
    func render(viewModel: ProfileViewModel) {
        nameLabel.text = viewModel.fullName
        loginNameLabel.text = viewModel.username
        descriptionLabel.text = viewModel.bio
        
        let placeholderImage = UIImage(systemName: "person.crop.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(
                UIImage.SymbolConfiguration(pointSize: 70, weight: .regular)
            )
        
        imageLoader.setImage(
            on: avatarImageView,
            from: viewModel.avatarURL,
            placeholder: placeholderImage
        )
    }
    
    func showLogoutConfirmation() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        
        let confirm = UIAlertAction(title: "Да", style: .destructive) { [weak self] _ in
            self?.presenter.didConfirmLogout()
        }
        
        let cancel = UIAlertAction(title: "Нет", style: .default)
        
        alert.addAction(confirm)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
}
