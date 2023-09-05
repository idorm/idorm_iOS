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
import Kingfisher
import KakaoSDKCommon
import KakaoSDKShare
import KakaoSDKTemplate

/// 사용자가 특정 게시글에 들어왔을 때 보여지는 `UIViewController`
final class CommunityPostViewController: BaseViewController, View {
  
  typealias DataSource = UICollectionViewDiffableDataSource<CommunityPostSection, CommunityPostSectionItem>
  typealias Reactor = CommunityPostViewReactor
  
  // MARK: - Properties
  
  private var dataSource: DataSource?
  
  // MARK: - UI Components
  
  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: self.createLayout()
    )
    collectionView.refreshControl = self.refreshControl
    // Register
    collectionView.register(
      CommunityPostContentCell.self,
      forCellWithReuseIdentifier: CommunityPostContentCell.identifier
    )
    collectionView.register(
      CommunityPostPhotoCell.self,
      forCellWithReuseIdentifier: CommunityPostPhotoCell.identifier
    )
    collectionView.register(
      CommunityPostMultiBoxCell.self,
      forCellWithReuseIdentifier: CommunityPostMultiBoxCell.identifier
    )
    collectionView.register(
      CommunityCommentCell.self,
      forCellWithReuseIdentifier: CommunityCommentCell.identifier
    )
    collectionView.register(
      CommunityPostEmptyCell.self,
      forCellWithReuseIdentifier: CommunityPostEmptyCell.identifier
    )
    return collectionView
  }()
  
  /// `옵션` 버튼
  private let optionButton: UIButton = {
    let btn = UIButton()
    btn.setImage(.iDormIcon(.option), for: .normal)
    return btn
  }()
  
  /// `새로고침` UI
  private let refreshControl: UIRefreshControl = {
    let rc = UIRefreshControl()
    return rc
  }()
  
  private let commentView = CommentView()
  private let bottomView = UIView()
  private var header: CommunityPostContentCell!
  
  // MARK: - Propeties
  
  var popCompletion: (() -> Void)?
  
  // MARK: - Life Cycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: true)
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    self.view.backgroundColor = .white
    self.bottomView.backgroundColor = .white
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: optionButton)
  }
  
  override func setupLayouts() {
    [
      self.collectionView,
      self.commentView,
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
    
    self.collectionView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
      make.bottom.equalTo(self.commentView.snp.top)
    }
    
    self.bottomView.snp.makeConstraints { make in
      make.bottom.leading.trailing.equalToSuperview()
      make.top.equalTo(self.commentView.snp.bottom)
    }
  }
  
  // MARK: - Bind
  
  func bind(reactor: CommunityPostViewReactor) {
    
    let dataSource: DataSource = {
      let dataSource = DataSource(
        collectionView: self.collectionView,
        cellProvider: { collectionView, indexPath, item in
          switch item {
          case .content(let post):
            guard let cell = collectionView.dequeueReusableCell(
              withReuseIdentifier: CommunityPostContentCell.identifier,
              for: indexPath
            ) as? CommunityPostContentCell else {
              return UICollectionViewCell()
            }
            cell.configure(with: post)
            return cell
            
          case .photo(let url):
            guard let cell = collectionView.dequeueReusableCell(
              withReuseIdentifier: CommunityPostPhotoCell.identifier,
              for: indexPath
            ) as? CommunityPostPhotoCell else {
              return UICollectionViewCell()
            }
            cell.configure(with: url)
            return cell
            
          case .multiBox(let post):
            guard let cell = collectionView.dequeueReusableCell(
              withReuseIdentifier: CommunityPostMultiBoxCell.identifier,
              for: indexPath
            ) as? CommunityPostMultiBoxCell else {
              return UICollectionViewCell()
            }
            cell.delegate = self
            cell.configure(with: post)
            return cell
            
          case .comment(let comment):
            guard let cell = collectionView.dequeueReusableCell(
              withReuseIdentifier: CommunityCommentCell.identifier,
              for: indexPath
            ) as? CommunityCommentCell else {
              return UICollectionViewCell()
            }
            cell.delegate = self
            cell.configure(with: comment)
            return cell
            
          case .emptyComment:
            guard let cell = collectionView.dequeueReusableCell(
              withReuseIdentifier: CommunityPostEmptyCell.identifier,
              for: indexPath
            ) as? CommunityPostEmptyCell else {
              return UICollectionViewCell()
            }
            return cell
          }
        }
      )
      return dataSource
    }()
    self.dataSource = dataSource
    
    // Action
    
    // 화면 최초 접속
    self.rx.viewDidLoad
      .map { CommunityPostViewReactor.Action.viewDidLoad }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 댓글 입력 반응
    self.commentView.textView.rx.text
      .orEmpty
      .map { CommunityPostViewReactor.Action.commentDidChange($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 전송 버튼 클릭
    self.commentView.sendButton.rx.tap
      .map { CommunityPostViewReactor.Action.sendButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 아이템 클릭
    self.collectionView.rx.itemSelected
      .filter { dataSource.sectionIdentifier(for: $0.section) == .photos }
      .map { Reactor.Action.photoCellDidTap(index: $0.item) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // 빈 화면 클릭
    self.collectionView.rx.tapGesture { gesture, delegate in
      gesture.cancelsTouchesInView = false
      delegate.simultaneousRecognitionPolicy = .never
    }.when(.recognized)
      .withUnretained(self)
      .do { $0.0.commentView.textView.resignFirstResponder() }
      .map { _ in CommunityPostViewReactor.Action.backgroundDidTap }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 익명 버튼 클릭
    self.commentView.anonymousButton.rx.tap
      .withUnretained(self)
      .map { !$0.0.commentView.anonymousButton.isSelected }
      .map { CommunityPostViewReactor.Action.anonymousButtonDidTap($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
      
    // 게시글 옵션 버튼 클릭 -> 바텀 시트 출력
    self.optionButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.didTapPostOptionButton(owner.reactor?.currentState.post.memberIdentifier ?? -1)
      }
      .disposed(by: self.disposeBag)
    
    // 당겨서 새로고침
    self.refreshControl.rx.controlEvent(.valueChanged)
      .map { CommunityPostViewReactor.Action.pullToRefresh }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // State
    reactor.state.map { (sections: $0.sections, items: $0.items) }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, sectionItem in
        var snapshot = NSDiffableDataSourceSnapshot<CommunityPostSection, CommunityPostSectionItem>()
        snapshot.appendSections(sectionItem.sections)
        sectionItem.items.enumerated().forEach { index, items in
          snapshot.appendItems(items, toSection: sectionItem.sections[index])
        }
        DispatchQueue.main.async {
          dataSource.apply(snapshot)
        }
      }
      .disposed(by: self.disposeBag)
    
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
    
    reactor.state
      .map { $0.currentCellBackgroundColor }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, condition in
        let indexPath = condition.1
        let backgroundColor: UIColor = condition.0 ? .iDormColor(.iDormGray100) : .white
        owner.collectionView.cellForItem(at: indexPath)?.contentView.backgroundColor = backgroundColor
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
    
    reactor.state.map { $0.endEditing }
      .filter { $0 }
      .observe(on: MainScheduler.asyncInstance )
      .bind(with: self) { owner, state in
        owner.view.endEditing(true)
        owner.commentView.textView.attributedText = NSAttributedString("")
      }
      .disposed(by: self.disposeBag)
    
    reactor.state
      .map { $0.endRefresh }
      .filter { $0 }
      .delay(.seconds(1), scheduler: MainScheduler.asyncInstance)
      .bind(with: self) { owner, _ in
        owner.collectionView.refreshControl?.endRefreshing()
      }
      .disposed(by: disposeBag)
    
    // Presentation
    
    reactor.pulse(\.$isPopping)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        owner.navigationController?.popViewController(animated: true)
        owner.popCompletion?()
      }
      .disposed(by: disposeBag)
    
    reactor.pulse(\.$navigateToCommunityPosting)
      .compactMap { $0 }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, post in
        let postingVC = CommunityPostingViewController()
        let postingReactor = CommunityPostingViewReactor(.edit(post), dorm: .no1)
        postingVC.reactor = postingReactor
        owner.navigationController?.pushViewController(postingVC, animated: true)
        
        postingVC.completion = {
          owner.reactor?.action.onNext(.pullToRefresh)
        }
      }
      .disposed(by: disposeBag)
    
    reactor.pulse(\.$presentImageSlide)
      .compactMap { $0 }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, imageData in
        owner.presentToImageSlideShow(imageData.index, photosURL: imageData.photosURL)
      }
      .disposed(by: self.disposeBag)
  }
}

// MARK: - Privates

private extension CommunityPostViewController {
  func createLayout() -> UICollectionViewCompositionalLayout {
    return UICollectionViewCompositionalLayout { section, _ in
      guard
        let communityPostSection = self.dataSource?.sectionIdentifier(for: section)
      else { fatalError("❌ CommunityPostSection을 찾지 못했습니다!") }
      let section = communityPostSection.section
      return section
    }
  }
  
  /// 게시글이 옵션 버튼을 클릭했을 때 호출되는 메서드입니다.
  ///
  /// - Parameters:
  ///   - postMemberID: 게시글 작성자의 `memberID`
  func didTapPostOptionButton(_ postMemberID: Int) {
    guard let memberId = UserStorage.shared.member?.memberId else { return }
    let items: [BottomSheetItem] = memberId == postMemberID ?
    [.sharePost, .deletePost, .editPost, .reportUser] :
    [.sharePost, .blockUser, .reportUser]
    let bottomSheet = BottomSheetViewController(items: items)
    bottomSheet.delegate = self
    self.presentPanModal(bottomSheet)
  }
  
  private func sendFeedMessage() {
    guard let post = self.reactor?.currentState.post else { return }
    
    let templateId = Int64(93479)
    
    let profileURL = post.profileURL == nil ?
    URL(string: "https://idorm-static.s3.ap-northeast-2.amazonaws.com/profileImage.png")! :
    URL(string: post.profileURL!)!
    
    let thumbnailURL = post.imagesCount == 0 ?
    URL(string: "https://idorm-static.s3.ap-northeast-2.amazonaws.com/nadomi.png")! :
    URL(string: post.photos.first!.photoURL)!
    
    let templateArgs = [
      "title": post.title,
      "nickname": post.nickname ?? "익명",
      "contentId": "\(post.identifier)",
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
  
  /// 사진을 클릭했을 때 `ImageSlideShow`가 보여집니다.
  ///
  /// - Parameters:
  ///   - index: 몇 번째 사진부터 보여질지에 대한 인덱스 값
  ///   - photosURL: 사진 리스트 각각의 `URL`주소
  func presentToImageSlideShow(_ index: Int, photosURL: [String]) {
    let imageSlide = FullScreenSlideshowViewController()
    imageSlide.inputs = photosURL.map { KingfisherSource(urlString: $0)! }
    imageSlide.initialPage = index
    imageSlide.zoomEnabled = true
    imageSlide.slideshow.contentScaleMode = .scaleAspectFit
    self.present(imageSlide, animated: true)
  }
}

// MARK: - CommunityPostMultiBoxCellDelegate

extension CommunityPostViewController: CommunityPostMultiBoxCellDelegate {
  /// 공감하기 버튼 클릭
  func didTapSympathyButton(_ nextIsLiked: Bool) {
    let title: String = nextIsLiked ? "게시글을 공감하시겠습니까?" : "공감을 취소하시겠습니까?"
    let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "취소", style: .cancel))
    alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
      self?.reactor?.action.onNext(.sympathyButtonDidTap(nextIsLiked))
    })
    self.present(alert, animated: true)
  }
}

// MARK: - CommunityCommentCellDelegate

extension CommunityPostViewController: CommunityCommentCellDelegate {
  /// 답글하기 버튼 클릭
  func didTapReplyButton(_ commentID: Int, cell:  CommunityCommentCell) {
    let title: String = "대댓글을 작성하시겠습니까?"
    let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "작성", style: .default) { [weak self] _ in
      guard let indexPath = self?.collectionView.indexPath(for: cell) else { return }
      self?.commentView.textView.becomeFirstResponder()
      self?.reactor?.action.onNext(.replyButtonDidTap(index: indexPath, commendID: commentID))
    })
    alert.addAction(UIAlertAction(title: "취소", style: .cancel))
    self.present(alert, animated: true)
  }
  
  /// 옵션 버튼 클릭
  func didTapOptionButton(_ comment: Comment) {
    guard let memberID = UserStorage.shared.member?.memberId else { return }
    let items: [BottomSheetItem] = memberID == comment.memberId ?
    [.deleteComment(commentID: comment.commentId), .blockUser, .reportUser]:
    [.blockUser, .reportUser]
    let bottomSheet = BottomSheetViewController(items: items)
    bottomSheet.delegate = self
    self.presentPanModal(bottomSheet)
  }
}

// MARK: - BottomSheetViewControllerDelegate

extension CommunityPostViewController: BottomSheetViewControllerDelegate {
  func didTapButton(_ item: BottomSheetItem) {
    guard let reactor else { return }
    switch item {
    case .deleteComment(let commentID):
      reactor.action.onNext(.deleteCommentButtonDidTap(commentId: commentID))
    case .reportUser:
      let title: String = "신고가 정상 처리되었습니다."
      let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
      alert.addAction(.init(title: "확인", style: .cancel))
      present(alert, animated: true)
    case .deletePost:
      reactor.action.onNext(.deletePostButtonDidTap)
    case .editPost:
      reactor.action.onNext(.editPostButtonDidTap)
    case .sharePost:
      self.sendFeedMessage()
    default: break
    }
  }
}

