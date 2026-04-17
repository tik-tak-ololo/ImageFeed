//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 15.04.2026.
//

import Foundation

final class ProfilePresenter: ProfilePresenterProtocol {
    
    weak var view: ProfileViewControllerProtocol?
    
    private let profileDataProvider: ProfileDataProvider
    private let profileAvatarURLProvider: ProfileAvatarURLProvider
    private let profileLogoutService: ProfileLogoutServiceProtocol
    private let profileRouter: ProfileRouterProtocol
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    init(profileDataProvider: ProfileDataProvider,
         profileAvatarURLProvider: ProfileAvatarURLProvider,
         profileLogoutService: ProfileLogoutServiceProtocol,
         profileRouter: ProfileRouterProtocol
    ) {
        self.profileDataProvider = profileDataProvider
        self.profileAvatarURLProvider = profileAvatarURLProvider
        self.profileLogoutService = profileLogoutService
        self.profileRouter = profileRouter
    }
    
    func viewDidLoad() {
        renderProfile()
        observeAvatarChanges()
    }
    
    func didTapLogout() {
        view?.showLogoutConfirmation()
    }
    
    func didConfirmLogout() {
        profileLogoutService.logout()
        profileRouter.switchToSplashScreen()
    }
    
    private func renderProfile() {
        let profile = profileDataProvider.profile
        
        let fullName: String = {
            guard let name = profile?.name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return "Имя не указано"
            }
            return name
        }()
        
        let username: String = {
            guard let login = profile?.loginName, !login.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return "@неизвестный_пользователь"
            }
            return login
        }()
        
        let bio: String = {
            guard let bio = profile?.bio, !bio.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return "Профиль не заполнен"
            }
            return bio
        }()
        
        let avatarURL = profileAvatarURLProvider.avatarURL.flatMap(URL.init(string:))
        
        let viewModel = ProfileViewModel(
            fullName: fullName,
            username: username,
            bio: bio,
            avatarURL: avatarURL
        )
        
        view?.render(viewModel: viewModel)
    }
    
    private func observeAvatarChanges() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.renderProfile()
        }
    }
    
    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
