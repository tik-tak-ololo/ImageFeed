//
//  ProfilePresenterSpy.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 17.04.2026.
//

@testable import ImageFeed

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    
    var viewDidLoadCalled: Bool = false
    
    func viewDidLoad(){
        viewDidLoadCalled = true
    }
    
    func didTapLogout(){
        
    }
    
    func didConfirmLogout(){
        
    }
}
