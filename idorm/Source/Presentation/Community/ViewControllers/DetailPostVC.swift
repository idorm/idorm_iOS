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
  
  // MARK: - UI
  
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
    tableView.register(
      DetailPostHeaderView.self,
      forHeaderFooterViewReuseIdentifier: DetailPostHeaderView.identifier
    )
    tableView.refreshControl = self.refreshControl
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
  
  private let refreshControl: UIRefreshControl = {
    let rc = UIRefreshControl()
    
    return rc
  }()
  
  private let commentView = CommentView()
  private let bottomView = UIView()
  private var header: DetailPostHeaderView!
  
  // MARK: - PROPERTIES
  
  var popCompletion: (() -> Void)?
  
  // MARK: - SETUP
  
  override func setupStyles() {
    self.view.backgroundColor = .white
    self.bottomView.backgroundColor = .white
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: optionButton)
  }
  
  override func setupLayouts() {
    [
      self.tableView,
      self.commentView,
      self.indicator,
      self.bottomView
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.commentView.snp.makeConstraints { make in
      make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top)
      make.leading.trailing.equalToSuperview()
    }
    
    self.tableView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
      make.bottom.equalTo(self.commentView.snp.top)
    }
    
    self.indicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    
    self.bottomView.snp.makeConstraints { make in
      make.bottom.leading.trailing.equalToSuperview()
      make.top.equalTo(self.commentView.snp.bottom)
    }
  }
  
  // MARK: - BIND
  
  func bind(reactor: DetailPostViewReactor) {
    
    // MARK: - ACTION
    
    // 화면 최초 접속
    self.rx.viewDidLoad
      .map { DetailPostViewReactor.Action.viewDidLoad }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 댓글 입력 반응
    self.commentView.textView.rx.text
      .orEmpty
      .map { DetailPostViewReactor.Action.didChangeComment($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 전송 버튼 클릭
    self.commentView.sendButton.rx.tap
      .map { DetailPostViewReactor.Action.didTapSendButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 빈 화면 클릭
    self.tableView.rx.tapGesture { gesture, delegate in
      gesture.cancelsTouchesInView = false
      delegate.simultaneousRecognitionPolicy = .never
    }.when(.recognized)
      .withUnretained(self)
      .do { $0.0.commentView.textView.resignFirstResponder() }
      .map { _ in DetailPostViewReactor.Action.didTapBackground }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 익명 버튼 클릭
    self.commentView.anonymousButton.rx.tap
      .withUnretained(self)
      .map { !$0.0.commentView.anonymousButton.isSelected }
      .map { DetailPostViewReactor.Action.didTapAnonymousButton($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 게시글 옵션 버튼 클릭 -> 바텀 시트 출력
    self.optionButton.rx.tap
      .bind(with: self) { owner, _ in
        guard
          let memberId = MemberStorage.shared.member?.memberId,
          let postMemberId = reactor.currentState.currentPost?.memberId
        else { return }
        
        let bottomSheet: BottomSheetViewController
        
        if memberId == postMemberId {
          bottomSheet = BottomSheetViewController(.myPost)
        } else {
          bottomSheet = BottomSheetViewController(.post)
        }
        
        // 게시글 삭제 버튼 클릭
        bottomSheet.deleteButtonCompletion = {
          reactor.action.onNext(.didTapDeletePostButton)
        }
        
        owner.presentPanModal(bottomSheet)
      }
      .disposed(by: disposeBag)
    
    // 당겨서 새로고침
    self.refreshControl.rx.controlEvent(.valueChanged)
      .map { DetailPostViewReactor.Action.pullToRefresh }
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
      .map { $0.reloadData }
      .filter { $0 }
      .withUnretained(self)
      .bind { $0.0.tableView.reloadData() }
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
    
    // 키보드 종료
    reactor.state
      .map { $0.endEditing }
      .filter { $0 }
      .bind(with: self) { $0.view.endEditing($1) }
      .disposed(by: disposeBag)
    
    // 당겨서 새로고침 취소
    reactor.state
      .map { $0.endRefresh }
      .filter { $0 }
      .delay(.seconds(1), scheduler: MainScheduler.asyncInstance)
      .bind(with: self) { owner, _ in
        owner.tableView.refreshControl?.endRefreshing()
      }
      .disposed(by: disposeBag)
    
    // 뒤로가기
    reactor.state
      .map { $0.popVC }
      .filter { $0 }
      .bind(with: self) { owner, _ in
        owner.navigationController?.popViewController(animated: true)
        owner.popCompletion?()
      }
      .disposed(by: disposeBag)
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
  
  private func presentDetailPhotosVC(_ indexPath: Int) {
    guard let postPhotos = self.reactor?.currentState.currentPost?.postPhotos else { return }
    let photosURL = postPhotos.map { $0.photoUrl }
    let detailPhotosVC = DetailPhotosViewController(photosURL, currentIndex: indexPath)
    detailPhotosVC.modalPresentationStyle = .fullScreen
    self.present(detailPhotosVC, animated: true)
  }
}

// MARK: - SETUP TABLEVIEW

extension DetailPostViewController: UITableViewDataSource, UITableViewDelegate {
  // 셀 생성
  func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    guard let currentPost = self.reactor?.currentState.currentPost,
          let reactor = self.reactor
    else {
      return UITableViewCell()
    }
    
    switch currentPost.commentsCount {
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
      cell.injectComment(orderedComment)
      
      // 답글 쓰기 버튼
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
            self?.reactor?.action.onNext(.didTapReplyButton(
              indexPath: indexPath.row,
              parentId: parentId
            ))
            self?.commentView.textView.becomeFirstResponder()
          }
        ))
        
        alert.addAction(UIAlertAction(
          title: "취소",
          style: .cancel
        ))
        
        self?.present(alert, animated: true)
      }
      
      // 댓글 옵션 버튼 클릭
      cell.optionButtonCompletion = { [weak self] commentId in
        let bottomSheet: BottomSheetViewController
        
        if orderedComment.commentId == commentId {
          bottomSheet = BottomSheetViewController(.myComment)
        } else {
          bottomSheet = BottomSheetViewController(.comment)
        }
        
        self?.presentPanModal(bottomSheet)
        
        // 댓글 삭제 버튼
        bottomSheet.deleteButtonCompletion = {
          self?.reactor?.action.onNext(.didTapDeleteCommentButton(commentId: commentId))
        }
        
        // 신고하기 버튼
        bottomSheet.reportButtonCompletion = {
          
        }
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
    guard
      let reactor = reactor,
      let currentPost = reactor.currentState.currentPost,
      let header = tableView.dequeueReusableHeaderFooterView(
        withIdentifier: DetailPostHeaderView.identifier
      ) as? DetailPostHeaderView
    else {
      return UIView()
    }
    
    header.injectData(currentPost, isSympathy: reactor.currentState.isSympathy)
    
    // 공감 버튼 클릭
    header.sympathyButtonCompletion = { [weak self] in
      self?.presentSympathyAlert($0)
    }
    
    // 사진 클릭
    header.photoCompletion = { [weak self] in
      self?.presentDetailPhotosVC($0)
    }
    
    return header
  }
  
  // 셀 높이
  func tableView(
    _ tableView: UITableView,
    heightForRowAt indexPath: IndexPath
  ) -> CGFloat {
    guard let post = reactor?.currentState.currentPost else { return 0 }

    switch post.commentsCount {
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
