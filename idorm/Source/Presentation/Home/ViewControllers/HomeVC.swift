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
  
  // MARK: - Properties
  
  private let bellButton = UIButton().then {
    var config = UIButton.Configuration.plain()
    config.image = UIImage(named: "bell")
    $0.configuration = config
    $0.isHidden = true
  }
  
  private let mainLabel = UILabel().then {
    $0.text = """
              1학기 룸메이트 매칭
              아이돔과 함께해요.
              """
    $0.textColor = .idorm_gray_400
    $0.numberOfLines = 2
    $0.font = .init(name: IdormFont_deprecated.medium.rawValue, size: 20)
    
    let attributedString = NSMutableAttributedString(string: $0.text!)
    attributedString.addAttributes([.foregroundColor: UIColor.idorm_blue,
                                    .font: UIFont.init(name: IdormFont_deprecated.bold.rawValue, size: 20)!]
                                   ,range: ($0.text! as NSString).range(of: "1학기"))
    $0.attributedText = attributedString
  }
  
  private let startMatchingButton = UIButton().then {
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = .idorm_blue
    config.image = UIImage(named: "sqaure_rightarrow")
    config.imagePlacement = .trailing
    config.imagePadding = 12
    
    var titleContainer = AttributeContainer()
    titleContainer.font = .init(name: IdormFont_deprecated.medium.rawValue, size: 16)
    titleContainer.foregroundColor = UIColor.white
    config.attributedTitle = AttributedString("룸메이트 매칭 시작하기", attributes: titleContainer)
    
    $0.configuration = config
  }
  
  private lazy var popularPostsCollection = UICollectionView(
    frame: .zero,
    collectionViewLayout: self.getLayout()
  ).then {
    $0.register(
      PopularPostCell.self,
      forCellWithReuseIdentifier: PopularPostCell.identifier
    )
    $0.backgroundColor = .idorm_gray_100
    $0.dataSource = self
    $0.delegate = self
  }
  
  private let loadingView = UIActivityIndicatorView().then {
    $0.backgroundColor = .lightGray
  }
  
  private let lionImageView = UIImageView(image: #imageLiteral(resourceName: "lion_with_circle"))
  private var scrollView: UIScrollView!
  private var contentView: UIView!
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    setupScrollView()
    super.viewDidLoad()
    reactor?.action.onNext(.viewDidLoad)
  }
  
  // MARK: - Helpers
  
  private func getLayout() -> UICollectionViewCompositionalLayout {
    UICollectionViewCompositionalLayout { _, _ in
      return PostUtils.popularPostSection()
    }
  }
  
  // MARK: - Bind
  
  func bind(reactor: HomeViewReactor) {
    
    // MARK: - Action
    
    // 매칭 시작하기
    startMatchingButton.rx.tap
      .withUnretained(self)
      .bind { $0.0.tabBarController?.selectedIndex = 1 }
      .disposed(by: disposeBag)
    
    // MARK: - State
    
    reactor.state
      .map { $0.popularPosts }
      .distinctUntilChanged()
      .bind(with: self) { owner, _ in owner.popularPostsCollection.reloadData() }
      .disposed(by: disposeBag)
    
    // 로딩 인디케이터
    reactor.state
      .map { $0.isLoading }
      .distinctUntilChanged()
      .bind(to: loadingView.rx.isAnimating)
      .disposed(by: disposeBag)
    
    // PostDetailVC 화면전환
    reactor.state
      .map { $0.pushToPostDetailVC }
      .filter { $0.0 }
      .bind(with: self) { owner, postId in
        let vc = DetailPostViewController()
        vc.reactor = DetailPostViewReactor(postId.1)
        vc.hidesBottomBarWhenPushed = true
        owner.navigationController?.pushViewController(vc, animated: true)
      }
      .disposed(by: disposeBag)
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .white
    navigationController?.isNavigationBarHidden = false
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: bellButton)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    view.addSubview(scrollView)
    scrollView.addSubview(contentView)
    
    [
      mainLabel,
      lionImageView,
      startMatchingButton,
      popularPostsCollection
    ].forEach { contentView.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    scrollView.snp.makeConstraints { make in
      make.edges.equalTo(view.safeAreaLayoutGuide)
    }
    
    contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalTo(view.frame.width)
    }
    
    mainLabel.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide)
      make.leading.equalToSuperview().inset(24)
    }
    
    lionImageView.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(24)
      make.top.equalTo(mainLabel.snp.bottom).offset(-12)
    }
    
    startMatchingButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.bottom.equalTo(lionImageView.snp.bottom).offset(-13.5)
      make.height.equalTo(52)
    }
    
    popularPostsCollection.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(startMatchingButton.snp.bottom).offset(50)
      make.height.equalTo(156)
      make.bottom.equalToSuperview()
    }
  }
  
  private func setupScrollView() {
    let scrollView = UIScrollView()
    self.scrollView = scrollView
    
    let contentView = UIView()
    contentView.backgroundColor = .white
    self.contentView = contentView
  }
}

// MARK: - CollectionView Setup

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    let posts = reactor?.currentState.popularPosts ?? []
    return posts.count
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: PopularPostCell.identifier,
      for: indexPath
    ) as? PopularPostCell
    else {
      return UICollectionViewCell()
    }
    
    let posts = reactor?.currentState.popularPosts ?? []
    cell.configure(posts[indexPath.row])
    
    return cell
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    didSelectItemAt indexPath: IndexPath
  ) {
    guard let reactor = reactor else { return }
    let posts = reactor.currentState.popularPosts
    let post = posts[indexPath.row]
    
    Observable.just(post.postId)
      .map { HomeViewReactor.Action.postDidTap(postId: $0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
}
