//
//  ProfileLogoutServiceSpy.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 17.04.2026.
//

@testable import ImageFeed

final class ProfileLogoutServiceSpy: ProfileLogoutServiceProtocol {
    private(set) var logoutCallCount = 0
    
    func logout() {
        logoutCallCount += 1
    }
}
