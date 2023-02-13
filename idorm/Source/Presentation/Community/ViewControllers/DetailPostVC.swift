//
//  PostDetail.swift
//  idorm
//
//  Created by 김응철 on 2023/01/23.
//

import UIKit

import SnapKit
import RSKGrowingTextView
import ReactorKit
import RxAppState
import RxOptional
import RxGesture
import PanModal

final class DetailPostViewController: BaseViewController, View {
  
  // MARK: - PROPERTIES
  
  private lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .grouped)
    tableView.backgroundColor = .white
    tableView.register(
      CommentCell.self,
      forCellReuseIdentifier: CommentCell.identifier
    )
    tableView.register(
      DetailPostEmptyCell.self,
      forCellReuseIdentifier: DetailPostEmptyCell.identifier
    )
    tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    tableView.allowsSelection = false
    tableView.separatorStyle = .none
    tableView.dataSource = self
    tableView.delegate = self
    
    return tableView
  }()
  
  private let indicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView()
    indicator.color = .darkGray
    
    return indicator
  }()
  
  private let optionButton: UIButton = {
    let btn = UIButton()
    btn.setImage(UIImage(named: "option_gray"), for: .normal)
    
    return btn
  }()
  
  private let commentView = CommentView()
  private let bottomView = UIView()
  private var header: PostDetailHeader!
  
  // MARK: - SETUP
  
  override func setupStyles() {
    view.backgroundColor = .white
    bottomView.backgroundColor = .white
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: optionButton)
  }
  
  override func setupLayouts() {
    [
      tableView,
      commentView,
      indicator,
      bottomView
    ].forEach {
      view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    commentView.snp.makeConstraints { make in
      make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
      make.leading.trailing.equalToSuperview()
    }
    
    tableView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
      make.bottom.equalTo(commentView.snp.top)
    }
    
    indicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    
    bottomView.snp.makeConstraints { make in
      make.bottom.leading.trailing.equalToSuperview()
      make.top.equalTo(commentView.snp.bottom)
    }
  }
  
  // MARK: - BIND
  
  func bind(reactor: DetailPostViewReactor) {
    
    // MARK: - ACTION
    
    // 화면 최초 접속
    rx.viewDidLoad
      .map { DetailPostViewReactor.Action.viewDidLoad }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 댓글 입력 반응
    commentView.textView.rx.text
      .orEmpty
      .map { DetailPostViewReactor.Action.didChangeComment($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 전송 버튼 클릭
    commentView.sendButton.rx.tap
      .map { DetailPostViewReactor.Action.didTapSendButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 빈 화면 클릭
    tableView.rx.tapGesture { _, delegate in
      delegate.simultaneousRecognitionPolicy = .never
    }
      .withUnretained(self)
      .do { $0.0.commentView.textView.resignFirstResponder() }
      .map { _ in DetailPostViewReactor.Action.didTapBackground }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 익명 버튼 클릭
    commentView.anonymousButton.rx.tap
      .withUnretained(self)
      .map { !$0.0.commentView.anonymousButton.isSelected }
      .map { DetailPostViewReactor.Action.didTapAnonymousButton($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // MARK: - STATE
    
    // 전송 버튼 상태 변경
    reactor.state
      .map { $0.currentComment }
      .distinctUntilChanged()
      .map {
        switch $0 {
        case "":
          return false
        default:
          return true
        }
      }
      .bind(to: commentView.sendButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    // 현재 입력된 댓글
    reactor.state
      .map { $0.currentComment }
      .bind(to: commentView.textView.rx.text)
      .disposed(by: disposeBag)
    
    // 리로딩
    reactor.state
      .map { $0.currentPost }
      .distinctUntilChanged()
      .filterNil()
      .bind(with: self) { owner, _ in
        owner.tableView.reloadData()
      }
      .disposed(by: disposeBag)
    
    // 로딩 인디케이터 제어
    reactor.state
      .map { $0.isLoading }
      .bind(to: indicator.rx.isAnimating)
      .disposed(by: disposeBag)
    
    // 현재 포커싱된 댓글 색깔
    reactor.state
      .map { $0.currentCellBackgroundColor }
      .withUnretained(self)
      .bind {
        let backgroundColor: UIColor
        if $1.0 {
          backgroundColor = .idorm_gray_100
        } else {
          backgroundColor = .white
        }
        $0.tableView.cellForRow(
          at: IndexPath(row: $1.1, section: 0)
        )?.contentView.backgroundColor = backgroundColor
      }
      .disposed(by: disposeBag)
    
    // 익명 버튼 상태 변경
    reactor.state
      .map { $0.isAnonymous }
      .distinctUntilChanged()
      .bind(to: commentView.anonymousButton.rx.isSelected)
      .disposed(by: disposeBag)
    
    // 알림창 띄우기
    reactor.state
      .map { $0.isPresentedAlert }
      .filter { $0.0 }
      .withUnretained(self)
      .bind {
        let alert = UIAlertController(title: $1.1, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .cancel))
        $0.present(alert, animated: true)
      }
      .disposed(by: disposeBag)
  }
  
  // MARK: - BIND HEADER
  
  func bindHeader() {
    guard let reactor = reactor else { return }
  }
  
  // MARK: - HELPERS
  
  private func presentSympathyAlert(_ nextState: Bool) {
    let title: String
    
    if nextState {
      title = "공감을 취소하시겠습니까?"
    } else {
      title = "게시글을 공감하시겠습니까?"
    }
    let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "취소", style: .cancel))
    alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
      self?.reactor?.action.onNext(.didTapSympathyButton(!nextState))
    })
    
    self.present(alert, animated: true)
  }
}

// MARK: - Setup TableView

extension DetailPostViewController: UITableViewDataSource, UITableViewDelegate {
  // 셀 생성
  func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    guard let reactor = reactor else { return UITableViewCell() }
    
    switch reactor.currentState.currentPost?.comments.count ?? 0 {
    case 0:
      guard let cell = tableView.dequeueReusableCell(
        withIdentifier: DetailPostEmptyCell.identifier,
        for: indexPath
      ) as? DetailPostEmptyCell else {
        return UITableViewCell()
      }
      
      return cell
    default:
      guard let cell = tableView.dequeueReusableCell(
        withIdentifier: CommentCell.identifier,
        for: indexPath
      ) as? CommentCell else {
        return UITableViewCell()
      }
      
      let orderedComment = reactor.currentState.currentComments[indexPath.row]
      cell.inject(orderedComment)
      
      cell.replyButtonCompletion = { [weak self] parentId in
        let alert = UIAlertController(
          title: "대댓글을 작성하시겠습니까?",
          message: nil,
          preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
          title: "작성",
          style: .default,
          handler: { [weak self] _ in
            self?.reactor?.action.onNext(.didTapReplyButton(indexPath: indexPath.row, parentId: parentId))
            self?.commentView.textView.becomeFirstResponder()
          }
        ))
        
        alert.addAction(UIAlertAction(
          title: "취소",
          style: .cancel
        ))
        
        self?.present(alert, animated: true)
      }
      
      return cell
    }
  }

  // 셀 갯수
  func tableView(
    _ tableView: UITableView,
    numberOfRowsInSection section: Int
  ) -> Int {
    guard let currentState = reactor?.currentState else { return 0 }
    
    switch currentState.currentComments.count {
    case 0:
      return 1
    default:
      return currentState.currentComments.count
    }
  }
  
  // 헤더
  func tableView(
    _ tableView: UITableView,
    viewForHeaderInSection section: Int
  ) -> UIView? {
    guard let reactor = reactor,
          let currentPost = reactor.currentState.currentPost else {
      return PostDetailHeader()
    }
    
    let header = PostDetailHeader()
    header.injectData(currentPost, isSympathy: reactor.currentState.isSympathy)

    if self.header == nil {
      self.header = header
      self.bindHeader()
    }
    
    header.sympathyButtonCompletion = { [weak self] in
      self?.presentSympathyAlert($0)
    }
    
    return header
  }
  
  // 셀 높이
  func tableView(
    _ tableView: UITableView,
    heightForRowAt indexPath: IndexPath
  ) -> CGFloat {
    guard let post = reactor?.currentState.currentPost else { return 0 }

    switch post.comments.count {
    case 0:
      return 143
    default:
      return UITableView.automaticDimension
    }
  }
  
  func tableView(
    _ tableView: UITableView,
    estimatedHeightForRowAt indexPath: IndexPath
  ) -> CGFloat {
    guard let post = reactor?.currentState.currentPost else { return 0 }
    
    switch post.comments.count {
    case 0:
      return 143
    default:
      return UITableView.automaticDimension
    }
  }
  
  // 헤더 높이
  func tableView(
    _ tableView: UITableView,
    heightForHeaderInSection section: Int
  ) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  func tableView(
    _ tableView: UITableView,
    estimatedHeightForFooterInSection section: Int
  ) -> CGFloat {
    return UITableView.automaticDimension
  }
}
