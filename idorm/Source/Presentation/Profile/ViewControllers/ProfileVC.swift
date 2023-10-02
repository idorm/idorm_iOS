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
  
  private let topCoverView: UIView = {
    let view = UIView()
    view.backgroundColor = .iDormColor(.iDormBlue)
    return view
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
          cell.gearButtonHandler = { self.reactor?.action.onNext(.gearButtonDidTap) }
          cell.configure(imageURL: imageURL, nickname: nickname)
          return cell
        case .publicSetting:
          let cell = collectionView.dequeueReusableCell(for: indexPath) as ProfilePublicCell
          cell.buttonHandler = { self.reactor?.action.onNext(.publicButtonDidTap) }
          return cell
        default:
          let cell = collectionView.dequeueReusableCell(for: indexPath) as ProfileButtonCell
          cell.buttonHandler = { self.reactor?.action.onNext(.managementButtonDidTap(item)) }
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
    self.tabBarController?.tabBar.updateBackgroundColor(.iDormColor(.iDormGray100))
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    self.tabBarController?.tabBar.updateBackgroundColor(.white)
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    self.view.backgroundColor = .iDormColor(.iDormGray100)
  }
  
  override func setupLayouts() {
    super.setupLayouts()

    self.view.addSubview(self.collectionView)
    self.view.addSubview(self.topCoverView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.topCoverView.snp.makeConstraints { make in
      make.top.directionalHorizontalEdges.equalToSuperview()
      make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.top)
    }
    
    self.collectionView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
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
    
    reactor.pulse(\.$navigateToManagementMyInfoVC).skip(1)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        let viewController = ManagementMyInfoViewController()
        let reactor = ManagementMyInfoViewReactor()
        viewController.reactor = reactor
        viewController.hidesBottomBarWhenPushed = true
        owner.navigationController?.pushViewController(viewController, animated: true)
       }
      .disposed(by: self.disposeBag)
    
    reactor.pulse(\.$navigateToManagementVC).skip(1)
      .compactMap { $0 }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, item in
        let viewController = ManagementViewController()
        let reactor: ManagementViewReactor
        switch item {
        case .dislikedRoommate: reactor = .init(.dislikedRoommates)
        case .likedRoommate: reactor = .init(.likedRoommates)
        case .myPost: reactor = .init(.myPosts)
        case .myComment: reactor = .init(.myComments)
        case .recommendedPost: reactor = .init(.recommendedPosts)
        default: fatalError()
        }
        viewController.reactor = reactor
        viewController.hidesBottomBarWhenPushed = true
        owner.navigationController?.pushViewController(viewController, animated: true)
      }
      .disposed(by: self.disposeBag)
  }
}

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
