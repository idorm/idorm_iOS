//
//  MyCommunityVC.swift
//  idorm
//
//  Created by 김응철 on 2023/04/27.
//

import UIKit

import SnapKit
import ReactorKit
import RxSwift
import RxCocoa

final class MyCommunityViewController: BaseViewController, View {
  
  enum ViewControllerType {
    case post
    case comment
    case recommend
  }
  
  // MARK: - UI Components
  
  private lazy var tableView: UITableView = {
    let tb = UITableView(frame: .zero, style: .grouped)
    tb.register(
      MyPageSortHeaderView.self,
      forHeaderFooterViewReuseIdentifier: MyPageSortHeaderView.identifier
    )
    tb.register(
      MyCommentCell.self,
      forCellReuseIdentifier: MyCommentCell.identifier
    )
    tb.register(
      MyPostCell.self,
      forCellReuseIdentifier: MyPostCell.identifier
    )
    tb.backgroundColor = .idorm_gray_100
    tb.bounces = false
    tb.delegate = self
    tb.dataSource = self
    tb.separatorColor = .idorm_gray_100
    tb.separatorStyle = .none
    tb.separatorInset = .init(top: 4, left: 4, bottom: 4, right: 4)
    return tb
  }()
  
  private let indicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView()
    indicator.color = .gray
    return indicator
  }()
  
  // MARK: - Properties
  
  private let viewControllerType: ViewControllerType
  private var header: MyPageSortHeaderView?
  
  // MARK: - Initializer
  
  init(viewControllerType: ViewControllerType) {
    self.viewControllerType = viewControllerType
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    navigationController?.setNavigationBarHidden(false, animated: true)
    switch viewControllerType {
    case .comment:
      navigationItem.title = "내가 쓴 댓글"
    case .post:
      navigationItem.title = "내가 쓴 글"
    case .recommend:
      navigationItem.title = "공감한 글"
    }
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [
      tableView,
      indicator
    ].forEach {
      view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    indicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  
  // MARK: - Bind
  
  func bindHeader() {
    guard let header = header else { return }
    guard let reactor = reactor else { return }
    
    header.isLatest
      .distinctUntilChanged()
      .map { MyCommunityViewReactor.Action.sortButtonDidTap($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
  
  func bind(reactor: MyCommunityViewReactor) {
    
    // Action
    
    Observable.combineLatest(
      rx.viewDidLoad,
      rx.viewWillAppear
    )
    .map { _ in MyCommunityViewReactor.Action.viewNeedsUpdate }
    .bind(to: reactor.action)
    .disposed(by: disposeBag)
    
    // State
    
    reactor.state.map { $0.reloadData }
      .filter { $0 }
      .withUnretained(self)
      .bind { $0.0.tableView.reloadData() }
      .disposed(by: disposeBag)
    
    reactor.state.map { $0.isLoading }
      .bind(to: indicator.rx.isAnimating)
      .disposed(by: disposeBag)
  }
  
  // MARK: - Helpers
  
  private func showAlert(_ title: String) {
    let alert = UIAlertController(
      title: title,
      message: "",
      preferredStyle: .alert
    )
    let cancelAction = UIAlertAction(title: "확인", style: .cancel)
    alert.addAction(cancelAction)
    present(alert, animated: true)
  }
}

// MARK: - Setup TableView

extension MyCommunityViewController: UITableViewDataSource, UITableViewDelegate {
  
  // Initialize Cell
  
  func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    guard let currentState = reactor?.currentState else {
      return UITableViewCell()
    }
    
    switch viewControllerType {
    case .post, .recommend:
      guard let cell = tableView.dequeueReusableCell(
        withIdentifier: MyPostCell.identifier,
        for: indexPath
      ) as? MyPostCell else {
        return UITableViewCell()
      }
      let post = currentState.posts[indexPath.row]
      cell.injectData(post)
      return cell
      
    case .comment:
      guard let cell = tableView.dequeueReusableCell(
        withIdentifier: MyCommentCell.identifier,
        for: indexPath
      ) as? MyCommentCell else {
        return UITableViewCell()
      }
      let comment = currentState.comments[indexPath.row]
      cell.configure(comment)
      
      cell.buttonCompletion = { [weak self] postID in
        guard let self,
              let postID = postID
        else {
          self?.showAlert("삭제된 게시글입니다.")
          return
        }
        let apiManager = NetworkService<CommunityAPI>()
        apiManager.requestAPI(to: .lookupDetailPost(postId: postID))
          .map(ResponseDTO<CommunitySinglePostResponseDTO>.self)
          .asDriver(onErrorRecover: { _ in return .empty() })
          .drive(with: self) { owner, post in
            let viewController = CommunityPostViewController()
            let reactor = CommunityPostViewReactor(post.data.toPost())
            viewController.reactor = reactor
            owner.navigationController?.pushViewController(viewController, animated: true)
          }
          .disposed(by: self.disposeBag)
      }
      return cell
    }
  }
  
  // Initialize Header
  
  func tableView(
    _ tableView: UITableView,
    viewForHeaderInSection section: Int
  ) -> UIView? {
    guard let header = tableView.dequeueReusableHeaderFooterView(
      withIdentifier: MyPageSortHeaderView.identifier
    ) as? MyPageSortHeaderView else {
      return UIView()
    }
    
    if self.header == nil {
      self.header = header
      bindHeader()
    }
    
    return header
  }
  
  // numberOfRows
  
  func tableView(
    _ tableView: UITableView,
    numberOfRowsInSection section: Int
  ) -> Int {
    switch viewControllerType {
    case .post, .recommend:
      return reactor?.currentState.posts.count ?? 0
    case .comment:
      return reactor?.currentState.comments.count ?? 0
    }
  }
  
  // Header Height
  
  func tableView(
    _ tableView: UITableView,
    heightForHeaderInSection section: Int
  ) -> CGFloat {
    return 50
  }
  
  // Cell Height
  
  func tableView(
    _ tableView: UITableView,
    heightForRowAt indexPath: IndexPath
  ) -> CGFloat {
    switch viewControllerType {
    case .recommend, .post:
      return 145.0
    case .comment:
      return UITableView.automaticDimension
    }
  }
  
  func tableView(
    _ tableView: UITableView,
    estimatedHeightForRowAt indexPath: IndexPath
  ) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  // Cell Touch
  
  func tableView(
    _ tableView: UITableView,
    didSelectRowAt indexPath: IndexPath
  ) {
    guard let reactor = reactor else { return }
    
    switch viewControllerType {
    case .recommend, .post:
      let apiManager = NetworkService<CommunityAPI>()
      apiManager.requestAPI(to: .lookupDetailPost(
        postId: reactor.currentState.posts[indexPath.row].postId
      ))
      .map(ResponseDTO<CommunitySinglePostResponseDTO>.self)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, data in
        let viewController = CommunityPostViewController()
        let reactor = CommunityPostViewReactor(data.data.toPost())
        viewController.reactor = reactor
        viewController.hidesBottomBarWhenPushed = true
        owner.navigationController?.pushViewController(viewController, animated: true)
      }
      .disposed(by: self.disposeBag)
    case .comment:
      break
    }
  }
}
