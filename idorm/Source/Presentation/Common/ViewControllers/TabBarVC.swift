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
    self.pushToDetailPost()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.navigationController?.setNavigationBarHidden(true, animated: true)
  }
  
  // MARK: - Setup
  
  private func setupViewControllers() {
    let homeVC = HomeViewController()
    let matchingVC = MatchingViewController()
    let myPageVC = MyPageViewController()
    let postListVC = CommunityListViewController()
    let calendarVC = CalendarViewController()
    
    homeVC.reactor = HomeViewReactor()
    matchingVC.reactor = MatchingViewReactor()
    myPageVC.reactor = MyPageViewReactor()
    postListVC.reactor = CommunityListViewReactor()
    calendarVC.reactor = CalendarViewReactor()
    
    let naviHomeVC = UINavigationController(rootViewController: homeVC)
    let naviMatchingVC = UINavigationController(rootViewController: matchingVC)
    let naviMyPageVC = UINavigationController(rootViewController: myPageVC)
    let naviPostListVC = UINavigationController(rootViewController: postListVC)
    let naviCalendarVC = UINavigationController(rootViewController: calendarVC)
    
    naviHomeVC.tabBarItem = tabBarItem("홈", image: UIImage(named: "house"))
    naviMatchingVC.tabBarItem = tabBarItem("룸메 매칭", image: UIImage(named: "circle_heart_lightgray"))
    naviMyPageVC.tabBarItem = tabBarItem("마이페이지", image: UIImage(named: "human_lightgray"))
    naviPostListVC.tabBarItem = tabBarItem("커뮤니티", image: UIImage(named: "speechBubble_gray"))
    naviCalendarVC.tabBarItem = tabBarItem("캘린더", image: .iDormIcon(.calendar))
    
    viewControllers = [naviHomeVC, naviMatchingVC, naviPostListVC, naviCalendarVC, naviMyPageVC]
  }
  
  private func setupStyles() {
    tabBar.unselectedItemTintColor = .gray
    tabBar.tintColor = .idorm_blue
    tabBar.barTintColor = .clear
    tabBar.backgroundColor = .clear
    tabBar.layer.cornerRadius = 24.0
    tabBar.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
    tabBar.layer.borderColor = UIColor.idorm_gray_200.cgColor
    tabBar.layer.borderWidth = 1
  }
  
  // MARK: - Helpers
  
  private func pushToDetailPost() {
    TransitionManager.shared.postPushAlarmDidTap = { [weak self] postId in
      guard let self else { return }
      let apiManager = NetworkService<CommunityAPI>()
      apiManager.requestAPI(to: .lookupDetailPost(postId: postId))
        .map(ResponseDTO<CommunitySinglePostResponseDTO>.self)
        .bind { post in
          self.selectedIndex = 2
          let navVC = self.children[2] as? UINavigationController
          let detailPostVC = CommunityPostViewController()
          detailPostVC.hidesBottomBarWhenPushed = true
          let reactor = CommunityPostViewReactor(post.data.toPost())
          detailPostVC.reactor = reactor
          navVC?.pushViewController(detailPostVC, animated: true)
        }
        .disposed(by: self.disposeBag)
    }
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
