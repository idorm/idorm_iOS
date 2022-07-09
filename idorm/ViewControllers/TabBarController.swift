//
//  TabBarController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/08.
//

import UIKit

class TabBarController: UITabBarController {
    // MARK: - Properties
    let homeVC = HomeViewController()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Helpers
    private func configureUI() {
        tabBar.unselectedItemTintColor = .gray
        tabBar.tintColor = .blue
        tabBar.barTintColor = .white
        tabBar.backgroundColor = .white
        
        homeVC.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house"))
        
        viewControllers = [ homeVC ]
    }
}
