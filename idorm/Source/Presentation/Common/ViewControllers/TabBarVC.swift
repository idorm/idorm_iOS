//
//  TabBarViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/12/21.
//

import UIKit

import RxMoya
import RxSwift

final class TabBarViewController: UITabBarController {
  
  // MARK: - Properties
  
  let disposeBag = DisposeBag()
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupStyles()
    setupViewControllers()
  }
  
  // MARK: - Setup
  
  private func setupViewControllers() {
    let homeVC = HomeViewController()
    let matchingVC = MatchingViewController()
    let myPageVC = MyPageViewController()
    let postListVC = PostListViewController()
    
    homeVC.reactor = HomeViewReactor()
    matchingVC.reactor = MatchingViewReactor()
    myPageVC.reactor = MyPageViewReactor()
    postListVC.reactor = PostListViewReactor()
    
    let naviHomeVC = UINavigationController(rootViewController: homeVC)
    let naviMatchingVC = UINavigationController(rootViewController: matchingVC)
    let naviMyPageVC = UINavigationController(rootViewController: myPageVC)
    let naviPostListVC = UINavigationController(rootViewController: postListVC)
    
    naviHomeVC.tabBarItem = tabBarItem("홈", image: UIImage(named: "house"))
    naviMatchingVC.tabBarItem = tabBarItem("룸메 매칭", image: UIImage(named: "circle_heart_lightgray"))
    naviMyPageVC.tabBarItem = tabBarItem("마이페이지", image: UIImage(named: "human_lightgray"))
    naviPostListVC.tabBarItem = tabBarItem("커뮤니티", image: UIImage(named: "speechBubble_gray"))
    
    viewControllers = [naviHomeVC, naviMatchingVC, naviPostListVC, naviMyPageVC]
  }
  
  private func setupStyles() {
    tabBar.unselectedItemTintColor = .gray
    tabBar.tintColor = .idorm_blue
    tabBar.barTintColor = .white
    tabBar.backgroundColor = .white
    tabBar.layer.cornerRadius = 24.0
    tabBar.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
    tabBar.layer.borderColor = UIColor.idorm_gray_200.cgColor
    tabBar.layer.borderWidth = 1
  }
}

extension TabBarViewController {
  private func tabBarItem(_ text: String, image: UIImage?) -> UITabBarItem {
    return UITabBarItem(
      title: text,
      image: image,
      selectedImage: image?.withRenderingMode(.alwaysTemplate).withTintColor(.idorm_blue)
    )
  }
}
