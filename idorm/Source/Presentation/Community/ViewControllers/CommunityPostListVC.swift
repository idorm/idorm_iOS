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
    button.title = ""
    button.image = .iDormIcon(.down)
    button.imagePadding = 16.0
    button.imagePlacement = .trailing
    button.font = .iDormFont(.bold, size: 20.0)
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
    
    self.navigationController?.setNavigationBarHidden(false, animated: true)
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.dormitoryButton)
  }
  
  override func setupLayouts() {
    [
      self.collectionView,
      self.writingButton
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
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
    // Action
    
    self.collectionView.rx.itemSelected
      .map { self.dataSource.itemIdentifier(for: $0) }
      .compactMap { $0 }
      .map { Reactor.Action.itemSelected($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.collectionView.rx.willDisplayCell
      .filter { cell, indexPath in
        guard 
          reactor.currentState.posts.count >= 10,
          self.dataSource.sectionIdentifier(for: indexPath.section) == .post,
          indexPath.row == reactor.currentState.posts.count - 4
        else { return false }
        return true
      }
      .map { _, _ in Reactor.Action.bottomScrolled }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.writingButton.rx.tap
      .map { Reactor.Action.writingButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    
    reactor.state.map { (sections: $0.sections, items: $0.items) }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, sectionData in
        var snapshot = NSDiffableDataSourceSnapshot<CommunityPostListSection, CommunityPostListSectionItem>()
        snapshot.appendSections(sectionData.sections)
        sectionData.items.enumerated().forEach { index, items in
          snapshot.appendItems(items, toSection: sectionData.sections[index])
        }
        DispatchQueue.main.async {
          owner.dataSource.apply(snapshot)
        }
      }
      .disposed(by: self.disposeBag)
    
    reactor.pulse(\.$navigateToPostingVC).skip(1)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        
      }
      .disposed(by: self.disposeBag)
    
    reactor.pulse(\.$naivgateToPostVC).skip(1)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, post in
        let viewController = CommunityPostViewController()
        let reactor = CommunityPostViewReactor(post)
        viewController.reactor = reactor
        owner.navigationController?.pushViewController(viewController, animated: true)
      }
      .disposed(by: self.disposeBag)
  }
  
//    // 기숙사 버튼 클릭
//    dormBtn.rx.tap
//      .withUnretained(self)
//      .bind { owner, _ in
//        let dormBS = DormBottomSheet()
//        owner.presentPanModal(dormBS)
//        
//        // 기숙사 버튼 클릭
//        dormBS.didTapDormBtn
//          .map { CommunityPostListViewReactor.Action.didTapDormBtn($0) }
//          .bind(to: reactor.action)
//          .disposed(by: owner.disposeBag)
//      }
//      .disposed(by: disposeBag)
//    
//    // 당겨서 새로고침
//    postListCV.refreshControl?.rx.controlEvent(.valueChanged)
//      .throttle(.seconds(2), latest: false, scheduler: MainScheduler.asyncInstance)
//      .map { CommunityPostListViewReactor.Action.pullToRefresh }
//      .bind(to: reactor.action)
//      .disposed(by: disposeBag)
//    
//    // 글쓰기 버튼 클릭
//    postingBtn.rx.tap
//      .map { CommunityPostListViewReactor.Action.didTapPostingBtn }
//      .bind(to: reactor.action)
//      .disposed(by: disposeBag)
//    
//    // MARK: - State
//    
//    // ReloadData
//    reactor.state
//      .map { $0.reloadData }
//      .filter { $0 }
//      .withUnretained(self)
//      .bind {
//        $0.0.postListCV.reloadData()
//      }
//      .disposed(by: self.disposeBag)
//    
//    // 현재 선택된 기숙사
//    reactor.state
//      .map { $0.currentDorm.postListString }
//      .distinctUntilChanged()
//      .withUnretained(self)
//      .bind { owner, string in
//        var container = AttributeContainer()
//        container.font = .init(name: IdormFont_deprecated.bold.rawValue, size: 20)
//        owner.dormBtn.configuration?.attributedTitle = AttributedString(string, attributes: container)
//      }
//      .disposed(by: disposeBag)
//    
//    // 로딩 인디케이터
//    reactor.state
//      .map { $0.isLoading }
//      .bind(to: indicator.rx.isAnimating)
//      .disposed(by: disposeBag)
//    
//    // 새로고침 인디케이터 종료
//    reactor.state
//      .map { $0.endRefreshing }
//      .filter { $0 }
//      .delay(.seconds(1), scheduler: MainScheduler.asyncInstance)
//      .withUnretained(self)
//      .bind { $0.0.postListCV.refreshControl?.endRefreshing() }
//      .disposed(by: disposeBag)
//    
//    // PostingVC로 이동
//    reactor.state
//      .map { $0.showsPostingVC }
//      .filter { $0.0 }
//      .withUnretained(self)
//      .bind { owner, dorm in
//        let postingVC = CommunityPostingViewController()
//        let postingReactor = CommunityPostingViewReactor(.new, dorm: dorm.1)
//        postingVC.hidesBottomBarWhenPushed = true
//        postingVC.reactor = postingReactor
//        owner.navigationController?.pushViewController(postingVC, animated: true)
//        postingVC.completion = { [weak self] in
//          self?.reactor?.action.onNext(.fetchNewPosts)
//        }
//      }
//      .disposed(by: disposeBag)
//    
//    // PostDetailVC로 이동
//    reactor.state
//      .map { $0.showsPostDetailVC }
//      .filter { $0.0 }
//      .bind(with: self) { owner, postId in
//        let postDetailVC = CommunityPostViewController()
//        postDetailVC.reactor = CommunityPostViewReactor(postId.1)
//        postDetailVC.hidesBottomBarWhenPushed = true
//        owner.navigationController?.pushViewController(postDetailVC, animated: true)
//        postDetailVC.popCompletion = { reactor.action.onNext(.fetchNewPosts) }
//      }
//      .disposed(by: disposeBag)
}

//  func collectionView(
//    _ collectionView: UICollectionView,
//    willDisplay cell: UICollectionViewCell,
//    forItemAt indexPath: IndexPath
//  ) {
//    guard let reactor = reactor else { return }
//    guard reactor.currentState.currentPosts.count >= 10 else { return }
//
//    switch indexPath.section {
//    case Section.common.rawValue:
//      if indexPath.row == reactor.currentState.currentPosts.count - 5 &&
//          !reactor.currentState.isBlockedRequest &&
//          !reactor.currentState.isPagination {
//        reactor.action.onNext(.fetchMorePosts)
//      }
//      
//    default:
//      return
//    }
//  }
//}

//extension CommunityPostListViewController: UITabBarControllerDelegate {
//  // 해당 탭바 버튼을 클릭했을 때 호출
//  func tabBarController(
//    _ tabBarController: UITabBarController,
//    didSelect viewController: UIViewController
//  ) {
//    guard self.isViewAppeared else { return }
//    // 선택된 뷰컨트롤러가 UINavigationController인 경우, topViewController를 가져옵니다.
//    if let navController = viewController as? UINavigationController {
//      if let scrollView = (navController.topViewController as? CommunityPostListViewController)?.postListCV {
//        let topOffset = CGPoint(x: 0, y: -postListCV.safeAreaInsets.top)
//        scrollView.setContentOffset(topOffset, animated: true)
//      }
//    }
//  }
//}

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
