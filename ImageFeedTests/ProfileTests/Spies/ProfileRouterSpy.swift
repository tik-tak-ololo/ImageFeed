//
//  ProfileRouterSpy.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 17.04.2026.
//

@testable import ImageFeed

final class ProfileRouterSpy: ProfileRouterProtocol {
    
    var didSwitchToSplashScreen = false
    
    func switchToSplashScreen() {
        didSwitchToSplashScreen = true
    }
}
