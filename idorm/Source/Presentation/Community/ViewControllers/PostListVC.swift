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

final class PostListViewController: BaseViewController, View {
  
  enum Section: Int, CaseIterable {
    case popular
    case common
  }
  
  // MARK: - Properties
  
  private let floatyBtn: UIButton = {
    let btn = UIButton()
    btn.setImage(UIImage(named: "ellipse_posting"), for: .normal)
    btn.setImage(UIImage(named: "ellipse_posting_activated"), for: .highlighted)
    
    return btn
  }()
  
  private let dormBtn: UIButton = {
    var container = AttributeContainer()
    container.font = .init(name: MyFonts.bold.rawValue, size: 20)

    var config = UIButton.Configuration.plain()
    config.imagePadding = 16
    config.imagePlacement = .trailing
    config.image = #imageLiteral(resourceName: "downarrow")
    config.attributedTitle = AttributedString("인천대 3기숙사", attributes: container)
    config.baseForegroundColor = .black
    
    let btn = UIButton(configuration: config)
    
    return btn
  }()
  
  private let bellBtn: UIButton = {
    let btn = UIButton()
    btn.setImage(UIImage(named: "bell"), for: .normal)
    
    return btn
  }()
  
  private let indicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView()
    indicator.color = .darkGray
    
    return indicator
  }()
  
  private lazy var postListCV: UICollectionView = {
    let cv = UICollectionView(frame: .zero, collectionViewLayout: getLayout())
    cv.backgroundColor = .idorm_gray_100
    cv.register(
      PostCell.self,
      forCellWithReuseIdentifier: PostCell.identifier
    )
    cv.register(
      PopularPostCell.self,
      forCellWithReuseIdentifier: PopularPostCell.identifier
    )
    cv.dataSource = self
    cv.delegate = self
    
    return cv
  }()
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // 화면 최초 접근
    reactor?.action.onNext(.viewDidLoad)
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    view.backgroundColor = .white
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dormBtn)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: bellBtn)
  }
  
  override func setupLayouts() {
    [
      postListCV,
      floatyBtn,
      indicator
    ].forEach {
      view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    floatyBtn.snp.makeConstraints { make in
      make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
      make.centerX.equalToSuperview()
    }
    
    postListCV.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    indicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  
  // MARK: - Bind
  
  func bind(reactor: PostListViewReactor) {
    
    // MARK: - Action
    
    // 기숙사 버튼 클릭
    dormBtn.rx.tap
      .withUnretained(self)
      .bind { owner, _ in
        let dormBS = DormBottomSheet()
        owner.presentPanModal(dormBS)

        // 기숙사 버튼 클릭
        dormBS.didTapDormBtn
          .map { PostListViewReactor.Action.didTapDormBtn($0) }
          .bind(to: reactor.action)
          .disposed(by: owner.disposeBag)
      }
      .disposed(by: disposeBag)
    
    // MARK: - State
    
    // 게시글 변화
    reactor.state
      .map { $0.currentPosts }
      .distinctUntilChanged()
      .withUnretained(self)
      .debug()
      .bind { $0.0.postListCV.reloadData() }
      .disposed(by: disposeBag)
    
    // 로딩 인디케이터
    reactor.state
      .map { $0.isLoading }
      .bind(to: indicator.rx.isAnimating)
      .disposed(by: disposeBag)
  }
  
  // MARK: - Helpers
  
  private func getLayout() -> UICollectionViewCompositionalLayout {
    UICollectionViewCompositionalLayout { section, _ in
      switch section {
      case Section.popular.rawValue:
        return PostUtils.popularPostSection()
      default:
        return PostUtils.postSection()
      }
    }
  }
}

// MARK: - CollectionView Setup

extension PostListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    guard let currentState = reactor?.currentState else { return 0 }
    
    switch section {
    case Section.popular.rawValue:
      return currentState.currentTopPosts.count
    default:
      return currentState.currentPosts.count
    }
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return Section.allCases.count
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    guard
      let postCell = collectionView.dequeueReusableCell(
        withReuseIdentifier: PostCell.identifier,
        for: indexPath
      ) as? PostCell,
      let popularPostCell = collectionView.dequeueReusableCell(
        withReuseIdentifier: PopularPostCell.identifier,
        for: indexPath
      ) as? PopularPostCell,
      let currentState = reactor?.currentState
    else {
      return UICollectionViewCell()
    }
    
    let topPosts = currentState.currentTopPosts
    let posts = currentState.currentPosts
        
    switch indexPath.section {
    case Section.popular.rawValue :
      popularPostCell.configure(topPosts[indexPath.row])
      return popularPostCell
    default:
      postCell.configure(posts[indexPath.row])
      return postCell
    }
  }
}
