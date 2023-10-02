//
//  PostListVC.swift
//  idorm
//
//  Created by 김응철 on 2023/01/11.
//

import UIKit

import SnapKit
import ReactorKit
import RxSwift
import RxCocoa
import PanModal

final class CommunityPostListViewController: BaseViewController, View {
  
  typealias DataSource = UICollectionViewDiffableDataSource<CommunityPostListSection, CommunityPostListSectionItem>
  typealias Reactor = CommunityPostListViewReactor
  
  // MARK: - UI Components
  
  private lazy var collectionView: UICollectionView = {
    let layout = self.getLayout()
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: layout
    )
    collectionView.backgroundColor = .iDormColor(.iDormGray100)
    collectionView.register(
      CommunityPostListCell.self,
      forCellWithReuseIdentifier: CommunityPostListCell.identifier
    )
    collectionView.register(
      CommunityTopPostListCell.self,
      forCellWithReuseIdentifier: CommunityTopPostListCell.identifier
    )
    layout.register(
      CommunityTopPostsBackgroundView.self,
      forDecorationViewOfKind: CommunityTopPostsBackgroundView.identifier
    )
    return collectionView
  }()
  
  private let dormitoryButton: iDormButton = {
    let button = iDormButton()
    button.image = .iDormIcon(.down)
    button.imagePadding = 16.0
    button.imagePlacement = .trailing
    button.font = .iDormFont(.bold, size: 20.0)
    button.contentInset = .zero
    button.baseBackgroundColor = .white
    button.baseForegroundColor = .black
    return button
  }()
  
  private let writingButton: iDormButton = {
    let button = iDormButton("글쓰기", image: .iDormIcon(.pencil))
    button.baseBackgroundColor = .iDormColor(.iDormBlue)
    button.baseForegroundColor = .white
    button.font = .iDormFont(.bold, size: 16.0)
    button.cornerRadius = 47.0
    button.contentInset =
    NSDirectionalEdgeInsets(top: 10.0, leading: 18.0, bottom: 10.0, trailing: 18.0)
    button.shadowOpacity = 0.21
    button.shadowRadius = 3.0
    button.shadowOffset = CGSize(width: .zero, height: 4.0)
    return button
  }()
  
  // MARK: - Properties
  
  private lazy var dataSource: DataSource = {
    let dataSource = DataSource(
      collectionView: self.collectionView,
      cellProvider: { collectionView, indexPath, item in
        switch item {
        case .topPost(let post):
          guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CommunityTopPostListCell.identifier,
            for: indexPath
          ) as? CommunityTopPostListCell else {
            return UICollectionViewCell()
          }
          cell.configure(with: post)
          return cell
        case .post(let post):
          guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CommunityPostListCell.identifier,
            for: indexPath
          ) as? CommunityPostListCell else {
            return UICollectionViewCell()
          }
          cell.configure(with: post)
          return cell
        }
      })
    return dataSource
  }()
  
  // MARK: - LifeCycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.navigationController?.setNavigationBarHidden(false, animated: false)
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.dormitoryButton)
    self.view.backgroundColor = .iDormColor(.iDormGray100)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [
      self.collectionView,
      self.writingButton
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.collectionView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    self.writingButton.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(16.0)
    }
  }
  
  // MARK: - Bind
  
  func bind(reactor: CommunityPostListViewReactor) {
//    // Action
//    
//    self.collectionView.rx.itemSelected
//      .map { self.dataSource.itemIdentifier(for: $0) }
//      .compactMap { $0 }
//      .map { Reactor.Action.itemSelected($0) }
//      .bind(to: reactor.action)
//      .disposed(by: self.disposeBag)
//    
//    self.collectionView.rx.willDisplayCell
//      .filter { cell, indexPath in
//        guard
//          reactor.currentState.posts.count >= 10,
//          self.dataSource.sectionIdentifier(for: indexPath.section) == .post,
//          indexPath.row == reactor.currentState.posts.count - 4
//        else { return false }
//        return true
//      }
//      .map { _, _ in Reactor.Action.bottomScrolled }
//      .bind(to: reactor.action)
//      .disposed(by: self.disposeBag)
//    
//    self.writingButton.rx.tap
//      .map { Reactor.Action.writingButtonDidTap }
//      .bind(to: reactor.action)
//      .disposed(by: self.disposeBag)
//    
//    self.dormitoryButton.rx.tap
//      .map { Reactor.Action.dormitoryButtonDidTap }
//      .bind(to: reactor.action)
//      .disposed(by: self.disposeBag)
//    
//    // State
//    
//    reactor.state.map { (sections: $0.sections, items: $0.items) }
//      .asDriver(onErrorRecover: { _ in return .empty() })
//      .drive(with: self) { owner, sectionData in
//        var snapshot = NSDiffableDataSourceSnapshot<CommunityPostListSection, CommunityPostListSectionItem>()
//        snapshot.appendSections(sectionData.sections)
//        sectionData.items.enumerated().forEach { index, items in
//          snapshot.appendItems(items, toSection: sectionData.sections[index])
//        }
//        DispatchQueue.main.async {
//          owner.dataSource.apply(snapshot)
//        }
//      }
//      .disposed(by: self.disposeBag)
//    
//    reactor.state.map { $0.currentDormitory }
//      .distinctUntilChanged()
//      .asDriver(onErrorRecover: { _ in return .empty() })
//      .drive(with: self) { owner, dormitory in
//        owner.dormitoryButton.title = dormitory.postListString
//      }
//      .disposed(by: self.disposeBag)
//    
//    reactor.pulse(\.$navigateToPostingVC).skip(1)
//      .asDriver(onErrorRecover: { _ in return .empty() })
//      .drive(with: self) { owner, _ in
//        
//      }
//      .disposed(by: self.disposeBag)
//    
//    reactor.pulse(\.$naivgateToPostVC).skip(1)
//      .asDriver(onErrorRecover: { _ in return .empty() })
//      .drive(with: self) { owner, post in
//        let viewController = CommunityPostViewController()
//        let reactor = CommunityPostViewReactor(post)
//        viewController.reactor = reactor
//        owner.navigationController?.pushViewController(viewController, animated: true)
//      }
//      .disposed(by: self.disposeBag)
  }
}

// MARK: - Privates

private extension CommunityPostListViewController {
  func getLayout() -> UICollectionViewCompositionalLayout {
    return UICollectionViewCompositionalLayout { [weak self] index, _ in
      guard let section = self?.dataSource.sectionIdentifier(for: index) else {
        fatalError("❌ CommunityPostListSection을 찾을 수 없습니다!")
      }
      return section.section
    }
  }
}
