//
//  HomeViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/12/20.
//

import UIKit

import SnapKit
import Then
import Moya
import RxSwift
import RxCocoa
import ReactorKit

final class HomeViewController: BaseViewController, View {
  
  typealias DataSource = UICollectionViewDiffableDataSource<HomeSection, HomeSectionItem>
  typealias Reactor = HomeViewReactor
  
  // MARK: - UI Components
  
  private lazy var collectionView: UICollectionView = {
    let layout = self.getLayout()
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: layout
    )
    // Cell
    collectionView.register(
      HomeMainCell.self,
      forCellWithReuseIdentifier: HomeMainCell.identifier
    )
    collectionView.register(
      DormCalendarCell.self,
      forCellWithReuseIdentifier: DormCalendarCell.identifier
    )
    collectionView.register(
      DormCalendarEmptyCell.self,
      forCellWithReuseIdentifier: DormCalendarEmptyCell.identifier
    )
    collectionView.register(
      PopularPostCell.self,
      forCellWithReuseIdentifier: PopularPostCell.identifier
    )
    // Header
    collectionView.register(
      HomeDormCalendarHeader.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: HomeDormCalendarHeader.identifier
    )
    // Decoration
    layout.register(
      CommunityTopPostsBackgroundView.self,
      forDecorationViewOfKind: CommunityTopPostsBackgroundView.identifier
    )
    return collectionView
  }()
  
  // MARK: - Properties
  
  private lazy var dataSource: DataSource = {
    let dataSource = DataSource(
      collectionView: self.collectionView,
      cellProvider: { collectionView, indexPath, item in
        switch item {
        case .main:
          guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HomeMainCell.identifier,
            for: indexPath
          ) as? HomeMainCell else {
            return UICollectionViewCell()
          }
          cell.delegate = self 
          return cell
          
        case .topPost(let topPost):
          guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PopularPostCell.identifier,
            for: indexPath
          ) as? PopularPostCell else {
            return UICollectionViewCell()
          }
          cell.configure(with: topPost)
          return cell
          
        case .dormCalendar(let dormCalendar):
          guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DormCalendarCell.identifier,
            for: indexPath
          ) as? DormCalendarCell else {
            return UICollectionViewCell()
          }
          cell.configure(with: dormCalendar)
          return cell
          
        case .emptyDormCalendar:
          guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DormCalendarEmptyCell.identifier,
            for: indexPath
          ) as? DormCalendarEmptyCell else {
            return UICollectionViewCell()
          }
          return cell
        }
      }
    )
    dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
      if kind == UICollectionView.elementKindSectionHeader {
        guard let header = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          withReuseIdentifier: HomeDormCalendarHeader.identifier,
          for: indexPath
        ) as? HomeDormCalendarHeader else {
          return UICollectionReusableView()
        }
        return header
      } else {
        return UICollectionReusableView()
      }
    }
    return dataSource
  }()
  
  // MARK: - LifeCycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(true, animated: true)
  }
  
  // MARK: - Bind
  
  func bind(reactor: HomeViewReactor) {
    
    // Action
    self.rx.viewWillAppear
      .map { _ in Reactor.Action.viewWillAppear }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.collectionView.rx.itemSelected
      .compactMap { self.dataSource.itemIdentifier(for: $0) }
      .map { Reactor.Action.itemSelected($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.map { (sections: $0.sections, items: $0.items) }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, sectionData in
        var snapshot = NSDiffableDataSourceSnapshot<HomeSection, HomeSectionItem>()
        snapshot.appendSections(sectionData.sections)
        sectionData.items.enumerated().forEach { index, items in
          snapshot.appendItems(items, toSection: sectionData.sections[index])
        }
        DispatchQueue.main.async {
          self.dataSource.apply(snapshot)
        }
      }
      .disposed(by: self.disposeBag)
    
    reactor.pulse(\.$navigateToCommunityPostVC)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, post in
        let viewController = CommunityPostViewController()
        let reactor = CommunityPostViewReactor(post)
        viewController.reactor = reactor
        viewController.hidesBottomBarWhenPushed = true
        owner.navigationController?.pushViewController(viewController, animated: true)
      }
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    self.view.backgroundColor = .white
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
}

// MARK: - Privates

private extension HomeViewController {
  func getLayout() -> UICollectionViewCompositionalLayout {
    return UICollectionViewCompositionalLayout { section, _ in
      guard let section = self.dataSource.sectionIdentifier(for: section) else {
        fatalError("🔴 HomeSection을 발견하지 못했습니다!")
      }
      return section.section
    }
  }
}

// MARK: - HomeMainCellDelegate

extension HomeViewController: HomeMainCellDelegate {
  func didTapStartMatchingButton() {
    self.tabBarController?.selectedIndex = 1
  }
}
