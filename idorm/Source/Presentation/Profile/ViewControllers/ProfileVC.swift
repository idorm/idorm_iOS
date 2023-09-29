//
//  MyPageViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/12/21.
//

import UIKit

import SnapKit
import Then
import RxSwift
import RxCocoa
import RxGesture
import ReactorKit
import Reusable
import Kingfisher

final class ProfileViewController: BaseViewController, View {
  
  typealias Reactor = ProfileViewReactor
  typealias DataSource = UICollectionViewDiffableDataSource<ProfileSection, ProfileSectionItem>
  
  // MARK: - UI Components
  
  private lazy var collectionView: UICollectionView = {
    let layout = self.getLayout()
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: layout
    )
    collectionView.bounces = false
    collectionView.backgroundColor = .iDormColor(.iDormGray100)
    // Cell
    collectionView.register(
      ProfileMainCell.self,
      forCellWithReuseIdentifier: ProfileMainCell.reuseIdentifier
    )
    collectionView.register(
      ProfileButtonCell.self,
      forCellWithReuseIdentifier: ProfileButtonCell.reuseIdentifier
    )
    collectionView.register(
      ProfilePublicCell.self,
      forCellWithReuseIdentifier: ProfilePublicCell.reuseIdentifier
    )
    // SupplementaryView
    collectionView.register(
      ProfileHeaderView.self,
      forSupplementaryViewOfKind: ProfileHeaderView.reuseIdentifier,
      withReuseIdentifier: ProfileHeaderView.reuseIdentifier
    )
    layout.register(
      ProfileDecorationView.self,
      forDecorationViewOfKind: ProfileDecorationView.reuseIdentifier
    )
    return collectionView
  }()
  
  override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
  
  // MARK: - Properties
  
  private lazy var dataSource: DataSource = {
    let dataSource = DataSource(
      collectionView: self.collectionView,
      cellProvider: { collectionView, indexPath, item in
        switch item {
        case let .profile(imageURL, nickname):
          let cell = collectionView.dequeueReusableCell(for: indexPath) as ProfileMainCell
          cell.configure(imageURL: imageURL, nickname: nickname)
          return cell
        case .publicSetting:
          let cell = collectionView.dequeueReusableCell(for: indexPath) as ProfilePublicCell
          return cell
        default:
          let cell = collectionView.dequeueReusableCell(for: indexPath) as ProfileButtonCell
          cell.configure(with: item)
          return cell
        }
      }
    )
    dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
      guard let section = dataSource.sectionIdentifier(for: indexPath.section) else {
        fatalError("❌ ProfileSection을 찾지 못했습니다.")
      }
      switch kind {
      case ProfileHeaderView.reuseIdentifier:
        let headerView = collectionView.dequeueReusableSupplementaryView(
          ofKind: ProfileHeaderView.reuseIdentifier,
          for: indexPath
        ) as ProfileHeaderView
        headerView.configure(with: section)
        return headerView
      default:
        return UICollectionReusableView()
      }
    }
    return dataSource
  }()
  
  // MARK: - LifeCycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.navigationController?.setNavigationBarHidden(true, animated: true)
//    tabBarController?.tabBar.isHidden = false
//    
//    let tabBarAppearance = NavigationAppearanceUtils.tabbarAppearance(from: .idorm_gray_100)
//    tabBarController?.tabBar.standardAppearance = tabBarAppearance
//    tabBarController?.tabBar.scrollEdgeAppearance = tabBarAppearance
//    
//    self.tabBarController?.delegate = self
//    isViewAppeared = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
//    let tabBarAppearance = NavigationAppearanceUtils.tabbarAppearance(from: .white)
//    tabBarController?.tabBar.standardAppearance = tabBarAppearance
//    tabBarController?.tabBar.scrollEdgeAppearance = tabBarAppearance
//    
//    isViewAppeared = false
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    self.view.backgroundColor = .iDormColor(.iDormBlue)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    self.view.addSubview(self.collectionView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
  
    self.collectionView.snp.makeConstraints { make in
      make.edges.equalTo(self.view.safeAreaLayoutGuide)
    }
  }
  
  // MARK: - Bind
  
  func bind(reactor: ProfileViewReactor) {
    
    // Action
    
    
    
    // State
    
    reactor.state.map { (sections: $0.sections, items: $0.items) }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, sectionData in
        var snapshot = NSDiffableDataSourceSnapshot<ProfileSection, ProfileSectionItem>()
        snapshot.appendSections(sectionData.sections)
        sectionData.items.enumerated().forEach { index, items in
          snapshot.appendItems(items, toSection: sectionData.sections[index])
        }
        DispatchQueue.main.async {
          owner.dataSource.apply(snapshot)
        }
      }
      .disposed(by: self.disposeBag)
  }
}

//extension MyPageViewController: UITabBarControllerDelegate {
//  func tabBarController(
//    _ tabBarController: UITabBarController,
//    didSelect viewController: UIViewController
//  ) {
//    guard self.isViewAppeared else { return }
//    // 선택된 뷰컨트롤러가 UINavigationController인 경우, topViewController를 가져옵니다.
//    if let navController = viewController as? UINavigationController {
//      if let scrollView = (navController.topViewController as? MyPageViewController)?.scrollView{
//        scrollView.setContentOffset(.zero, animated: true)
//      }
//    }
//  }
//}

// MARK: - Privates

private extension ProfileViewController {
  func getLayout() -> UICollectionViewCompositionalLayout {
    return UICollectionViewCompositionalLayout { [weak self] index, _ in
      guard let section = self?.dataSource.sectionIdentifier(for: index) else {
        fatalError("❌ ProfileSection을 찾을 수 없습니다!")
      }
      return section.section
    }
  }
}
