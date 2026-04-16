//
//  ProfilePresenterProtocol.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 15.04.2026.
//

protocol ProfilePresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapLogoutButton()
    func didConfirmLogout()
}
