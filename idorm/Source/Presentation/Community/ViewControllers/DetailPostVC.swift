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
import ImageSlideshow
import KakaoSDKCommon
import KakaoSDKShare
import KakaoSDKTemplate

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
      .map { DetailPostViewReactor.Action.commentDidChange($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 전송 버튼 클릭
    self.commentView.sendButton.rx.tap
      .map { DetailPostViewReactor.Action.sendButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 빈 화면 클릭
    self.tableView.rx.tapGesture { gesture, delegate in
      gesture.cancelsTouchesInView = false
      delegate.simultaneousRecognitionPolicy = .never
    }.when(.recognized)
      .withUnretained(self)
      .do { $0.0.commentView.textView.resignFirstResponder() }
      .map { _ in DetailPostViewReactor.Action.backgroundDidTap }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 익명 버튼 클릭
    self.commentView.anonymousButton.rx.tap
      .withUnretained(self)
      .map { !$0.0.commentView.anonymousButton.isSelected }
      .map { DetailPostViewReactor.Action.anonymousButtonDidTap($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 게시글 옵션 버튼 클릭 -> 바텀 시트 출력
    self.optionButton.rx.tap
      .bind(with: self) { owner, _ in
        guard
          let memberId = UserStorage.shared.member?.memberId
        else { return }
        
        let postMemberId = reactor.currentState.currentPost?.memberId ?? -1
        
        let bottomSheet: BottomSheetViewController
        bottomSheet = memberId == postMemberId ? .init(.myPost) : .init(.post)
        owner.presentPanModal(bottomSheet)
        
        // 바텀시트 버튼 클릭
        bottomSheet.buttonDidTap
          .bind {
            switch $0 {
            case .deletePost:
              reactor.action.onNext(.deletePostButtonDidTap)
            case .editPost:
              reactor.action.onNext(.editPostButtonDidTap)
            case .report:
              owner.presentCompletedReport()
            case .share:
              owner.sendFeedMessage()
            default:
              break
            }
          }
          .disposed(by: owner.disposeBag)
      }
      .disposed(by: self.disposeBag)
    
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
      .bind { owner, title in
        let alert = UIAlertController(
          title: title.1,
          message: nil,
          preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .cancel) { _ in
          if title.1 == "게시글이 삭제되었습니다." {
            owner.popCompletion?()
            owner.navigationController?.popViewController(animated: true)
          }
        })
        owner.present(alert, animated: true)
      }
      .disposed(by: self.disposeBag)
    
    // 키보드 종료
    reactor.state
      .map { $0.endEditing }
      .filter { $0 }
      .bind(with: self) { $0.view.endEditing($1) }
      .disposed(by: self.disposeBag)
    
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
    
    // PostingVC 이동
    reactor.state
      .map { $0.showsPostingVC }
      .filter { $0 }
      .bind(with: self) { owner, _ in
        guard let post = reactor.currentState.currentPost else { return }
        let postingVC = PostingViewController()
        let postingReactor = PostingViewReactor(.edit(post), dorm: post.dormCategory)
        postingVC.reactor = postingReactor
        owner.navigationController?.pushViewController(postingVC, animated: true)
        
        postingVC.completion = {
          owner.reactor?.action.onNext(.pullToRefresh)
        }
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
      self?.reactor?.action.onNext(.sympathyButtonDidTap(!nextState))
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
  
  private func presentCompletedReport() {
    let alert = UIAlertController(
      title: "신고가 정상 처리되었습니다.",
      message: nil,
      preferredStyle: .alert
    )
    alert.addAction(.init(title: "확인", style: .cancel))
    present(alert, animated: true)
  }
  
  private func sendFeedMessage() {
    guard let post = self.reactor?.currentState.currentPost else { return }
    
    let templateId = Int64(93479)
    
    let profileURL = post.profileUrl == nil ?
    URL(string: "https://idorm-static.s3.ap-northeast-2.amazonaws.com/profileImage.png")! :
    URL(string: post.profileUrl!)!
    
    let thumbnailURL = post.imagesCount == 0 ?
    URL(string: "https://idorm-static.s3.ap-northeast-2.amazonaws.com/nadomi.png")! :
    URL(string: post.postPhotos.first!.photoUrl)!
    
    let templateArgs = [
      "title": post.title,
      "nickname": post.nickname ?? "익명",
      "contentId": "\(post.postId)",
      "summarizedContent": post.content,
      "thumbnail": thumbnailURL.absoluteString,
      "likeCount": "\(post.likesCount)",
      "userProfile": profileURL.absoluteString,
      "commentCount": "\(post.commentsCount)"
    ]
    
    if ShareApi.isKakaoTalkSharingAvailable() {
      // 카카오톡 설치
      ShareApi.shared.shareCustom(
        templateId: templateId,
        templateArgs: templateArgs
      ) { sharingResult, error in
        if let error = error {
          print(error)
        } else {
          print("shareCustom() success")
          if let sharingResult = sharingResult {
            UIApplication.shared.open(sharingResult.url)
          }
        }
      }
    } else {
      // 카카오톡 미설치: 웹 공유 사용 권장
      // Custom WebView 또는 디폴트 브라우져 사용 가능
    }
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
      cell.configure(orderedComment)
      
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
            self?.reactor?.action.onNext(.replyButtonDidTap(
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
        guard let self = self else { return }
        let bottomSheet: BottomSheetViewController
        let memberId = UserStorage.shared.member?.memberId ?? 0
        bottomSheet = orderedComment.memberId == memberId ? .init(.myComment) : .init(.comment)
        self.presentPanModal(bottomSheet)
        
        // 바텀시트 버튼 클릭
        bottomSheet.buttonDidTap
          .bind {
            switch $0 {
            case .deleteComment:
              self.reactor?.action.onNext(.deleteCommentButtonDidTap(commentId: commentId))
            case .report:
              self.presentCompletedReport()
            default:
              break
            }
          }
          .disposed(by: self.disposeBag)
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
