//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 16.03.2026.
//

import UIKit
 
final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }

    private func setupTabs() {

        let imagesListViewController = ImagesListAssembly.build()
        imagesListViewController.tabBarItem = UITabBarItem(
            title: "", // если подпись не нужна, оставьте пустую строку
            image: UIImage(resource: .tabEditorialActive),
            selectedImage: nil
        )
        
        let profileViewController = ProfileAssembly.build()
        
        profileViewController.tabBarItem = UITabBarItem(
            title: "", // если подпись не нужна, оставьте пустую строку
            image: UIImage(resource: .tabProfileActive),
            selectedImage: nil
        )

        self.viewControllers = [imagesListViewController, profileViewController]
    }

}
