//
//  TabBarController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/08.
//

import UIKit

class TabBarController: UITabBarController {
  // MARK: - Properties
  let homeVC = UINavigationController(rootViewController: HomeViewController())
  let matchingVC = UINavigationController(rootViewController: MatchingViewController())
  let communityVC = UINavigationController(rootViewController: CommunityViewController())
  let calandarVC = UINavigationController(rootViewController: CalandarViewController())
  let mypageVC = UINavigationController(rootViewController: MypageViewController())
  
  
  // MARK: - LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
  }
  
  // MARK: - Helpers
  private func configureUI() {
    tabBar.unselectedItemTintColor = .gray
    tabBar.tintColor = .mainColor
    tabBar.barTintColor = .white
    tabBar.backgroundColor = .white
    tabBar.layer.borderColor = UIColor.bluegrey.cgColor
    tabBar.layer.borderWidth = 1
    tabBar.layer.cornerRadius = 24.0
    tabBar.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
    
    homeVC.tabBarItem = returnTabBarItem(text: "홈", imageName: "TabHome")
    communityVC.tabBarItem = returnTabBarItem(text: "커뮤니티", imageName: "TabCommunity")
    calandarVC.tabBarItem = returnTabBarItem(text: "캘린더", imageName: "TabCalandar")
    mypageVC.tabBarItem = returnTabBarItem(text: "마이페이지", imageName: "TabMypage")
    matchingVC.tabBarItem = returnTabBarItem(text: "룸메 매칭", imageName: "TabRoommate")
    
    homeVC.navigationBar.tintColor = .black
    communityVC.navigationBar.tintColor = .black
    calandarVC.navigationBar.tintColor = .black
    mypageVC.navigationBar.tintColor = .black
    matchingVC.navigationBar.tintColor = .black
    
    viewControllers = [ homeVC, matchingVC, communityVC, calandarVC, mypageVC ]
  }
  
  private func returnTabBarItem(text: String, imageName: String) -> UITabBarItem {
    return UITabBarItem(title: text, image: UIImage(named: imageName), selectedImage: UIImage(named: imageName))
  }
}
