//
//  iDormTabBarViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/12/21.
//

import UIKit

import RxMoya
import RxSwift
import ReactorKit

final class iDormTabBarViewController: UITabBarController {
  
  enum ViewControllerType: CaseIterable {
    case home
    case matching
    case community
    case calendar
    case profile
    
    var viewController: BaseViewController {
      switch self {
      case .home: 
        let viewController = HomeViewController()
        viewController.reactor = HomeViewReactor()
        return viewController
      case .matching:
        let viewController = MatchingMateViewController()
        viewController.reactor = MatchingMateViewReactor()
        return viewController
      case .community:
        let viewController = CommunityPostListViewController()
//        viewController.reactor = CommunityPostListViewReactor()
        return viewController
      case .calendar:
        let viewController = CalendarViewController()
        viewController.reactor = CalendarViewReactor()
        return viewController
      case .profile:
        let viewController = ProfileViewController()
        viewController.reactor = ProfileViewReactor()
        return viewController
      }
    }

    var tabBarItem: UITabBarItem {
      switch self {
      case .home:
        return .init(
          title: "홈",
          image: .iDormIcon(.home),
          selectedImage: .iDormIcon(.home)?.withTintColor(.iDormColor(.iDormBlue))
        )
      case .matching:
        return .init(
          title: "룸메 매칭",
          image: .iDormIcon(.matching),
          selectedImage: .iDormIcon(.matching)?.withTintColor(.iDormColor(.iDormBlue))
        )
      case .community:
        return .init(
          title: "커뮤니티",
          image: .iDormIcon(.community),
          selectedImage: .iDormIcon(.community)?.withTintColor(.iDormColor(.iDormBlue))
        )
      case .calendar:
        return .init(
          title: "캘린더",
          image: .iDormIcon(.calendar),
          selectedImage: .iDormIcon(.calendar)?.withTintColor(.iDormColor(.iDormBlue))
        )
      case .profile:
        return .init(
          title: "마이페이지",
          image: .iDormIcon(.human)?.withTintColor(.iDormColor(.iDormGray300)),
          selectedImage: .iDormIcon(.human)?.withTintColor(.iDormColor(.iDormBlue))
        )
      }
    }
  }
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()

    self.setupViewControllers()
    self.setupStyles()
    self.pushToDetailPost()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.navigationController?.setNavigationBarHidden(true, animated: true)
  }
  
  // MARK: - Setup
  
  private func setupStyles() {
    self.tabBar.unselectedItemTintColor = .iDormColor(.iDormGray300)
    self.tabBar.tintColor = .iDormColor(.iDormBlue)
    self.tabBar.layer.borderColor = UIColor.iDormColor(.iDormGray200).cgColor
    self.tabBar.layer.masksToBounds = true
    self.tabBar.barTintColor = .clear
    self.tabBar.backgroundColor = .clear
    self.tabBar.layer.cornerRadius = 24.0
    self.tabBar.layer.borderWidth = 1
    self.tabBar.layer.maskedCorners = CACornerMask(
      arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner
    )
  }
  
  private func setupViewControllers() {
    self.viewControllers = ViewControllerType.allCases.map {
      let viewController = $0.viewController
      viewController.tabBarItem = $0.tabBarItem
      return UINavigationController(rootViewController: viewController)
    }
  }
  
  // MARK: - Helpers
  
  private func pushToDetailPost() {
//    TransitionManager.shared.postPushAlarmDidTap = { [weak self] postId in
//      guard let self else { return }
//      let apiManager = NetworkService<CommunityAPI>()
//      apiManager.requestAPI(to: .lookupDetailPost(postId: postId))
//        .map(ResponseDTO<CommunitySinglePostResponseDTO>.self)
//        .bind { post in
//          self.selectedIndex = 2
//          let navVC = self.children[2] as? UINavigationController
//          let detailPostVC = CommunityPostViewController()
//          detailPostVC.hidesBottomBarWhenPushed = true
//          let reactor = CommunityPostViewReactor(post.data.toPost())
//          detailPostVC.reactor = reactor
//          navVC?.pushViewController(detailPostVC, animated: true)
//        }
//        .disposed(by: self.disposeBag)
//    }
  }
}
