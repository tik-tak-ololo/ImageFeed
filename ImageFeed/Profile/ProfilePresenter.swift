//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 15.04.2026.
//

import Foundation

final class ProfilePresenter: ProfilePresenterProtocol {
    
    weak var view: ProfileViewControllerProtocol?
    
    private let profileService: ProfileService
    private let profileImageService: ProfileImageService
    private let logoutService: ProfileLogoutService
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    init(view: ProfileViewControllerProtocol,
         profileService: ProfileService = .shared,
         profileImageService: ProfileImageService = .shared,
         logoutService: ProfileLogoutService = .shared
    ) {
        self.view = view
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.logoutService = logoutService
    }
    
    func viewDidLoad() {
        updateProfile()
        observeAvatarChanges()
        updateAvatar()
    }
    
    func didTapLogoutButton() {
        view?.showLogoutConfirmation()
    }
    
    func didConfirmLogout() {
        logoutService.logout()
        view?.switchToSplashScreen()
    }
    
    private func updateProfile() {
        guard let profile = profileService.profile else { return }
        
        let name = profile.name.isEmpty ? "Имя не указано" : profile.name
        let login = profile.loginName.isEmpty ? "@неизвестный_пользователь" : profile.loginName
        let bio = (profile.bio?.isEmpty ?? true) ? "Профиль не заполнен" : (profile.bio ?? "")
        
        view?.displayProfile(name: name, login: login, bio: bio)
    }
    
    private func updateAvatar() {
        let url = profileImageService.avatarURL.flatMap(URL.init(string:))
        view?.displayAvatar(from: url)
    }
    
    private func observeAvatarChanges() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvatar()
        }
    }
    
    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
