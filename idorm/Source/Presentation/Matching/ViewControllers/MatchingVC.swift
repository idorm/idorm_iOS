import UIKit

import DeviceKit
import PanModal
import SnapKit
import Then
import Shuffle_iOS
import RxSwift
import RxCocoa
import RxOptional
import ReactorKit

final class MatchingViewController: BaseViewController, View {
  
  typealias Reactor = MatchingViewReactor
  
  // MARK: - Properties
  
  private let filterButton = UIButton().then {
    var config = UIButton.Configuration.plain()
    config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    config.image = #imageLiteral(resourceName: "filter")
    $0.configuration = config
  }
  
  private let refreshButton = UIButton().then {
    var config = UIButton.Configuration.filled()
    var container = AttributeContainer()
    container.font = .init(name: MyFonts.bold.rawValue, size: 12)
    container.foregroundColor = .idorm_blue
    config.baseBackgroundColor = .white
    config.cornerStyle = .capsule
    config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10)
    config.attributedTitle = AttributedString("새로고침", attributes: container)
    $0.configuration = config
  }
  
  private let topRoundedBackgroundView = UIImageView().then {
    $0.image = #imageLiteral(resourceName: "topRoundedBackground(Matching)").withRenderingMode(.alwaysTemplate)
    $0.tintColor = .idorm_blue
  }
  
  private let loadingIndicator = UIActivityIndicatorView().then {
    $0.color = .gray
  }
  
  private let informationImageView = UIImageView()
  private let cancelButton = MatchingUtilities.matchingButton(imageName: "cancel")
  private let messageButton = MatchingUtilities.matchingButton(imageName: "message")
  private let heartButton = MatchingUtilities.matchingButton(imageName: "heart")
  private let backButton = MatchingUtilities.matchingButton(imageName: "back")
  private var buttonStack: UIStackView!
  
  private let cardStack = SwipeCardStack()
  private var reactor = MatchingViewReactor()
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    cardStack.dataSource = self
    cardStack.delegate = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isNavigationBarHidden = true
    tabBarController?.tabBar.isHidden = false
  }
  
  // MARK: - Setup
  
  override func setupLayouts() {
    super.setupLayouts()
    [topRoundedBackgroundView, buttonStack, filterButton, refreshButton, informationImageView, cardStack, loadingIndicator]
      .forEach { view.addSubview($0) }
  }
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .white
    
    let buttonStack = UIStackView(arrangedSubviews: [cancelButton, backButton, messageButton, heartButton])
    buttonStack.spacing = 4
    self.buttonStack = buttonStack
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    loadingIndicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    
    topRoundedBackgroundView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
    }
    
    filterButton.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide).inset(16)
      make.trailing.equalToSuperview().inset(24)
    }
    
    informationImageView.snp.makeConstraints { make in
      make.centerY.equalTo(cardStack).offset(50)
      make.centerX.equalToSuperview()
    }
    
    refreshButton.snp.makeConstraints { make in
      make.centerY.equalTo(filterButton)
      make.trailing.equalTo(filterButton.snp.leading).offset(-16)
    }
    
    let deviceManager = DeviceManager.shared
    
    if deviceManager.isResoultion568() {
      cardStack.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalToSuperview()
        make.height.equalTo(450)
      }
      
      buttonStack.snp.makeConstraints { make in
        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(4)
        make.centerX.equalToSuperview()
      }
    } else if deviceManager.isResolution667() {
      cardStack.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(filterButton.snp.bottom).offset(4)
        make.height.equalTo(450)
      }
      
      buttonStack.snp.makeConstraints { make in
        make.centerX.equalToSuperview()
        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(8)
      }
    } else if deviceManager.isResolution736() {
      cardStack.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(filterButton.snp.bottom).offset(40)
        make.height.equalTo(450)
      }
      
      buttonStack.snp.makeConstraints { make in
        make.centerX.equalToSuperview()
        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(32)
      }
    } else if deviceManager.isResolution812() {
      buttonStack.spacing = 8
      
      cardStack.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(filterButton.snp.bottom).offset(40)
        make.height.equalTo(450)
      }
      
      buttonStack.snp.makeConstraints { make in
        make.centerX.equalToSuperview()
        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(40)
      }
    } else if deviceManager.isResolution844() {
      buttonStack.spacing = 8
      
      cardStack.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(filterButton.snp.bottom).offset(40)
        make.height.equalTo(450)
      }
      
      buttonStack.snp.makeConstraints { make in
        make.centerX.equalToSuperview()
        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(62)
      }
    } else if deviceManager.isResolution852() {
      buttonStack.spacing = 8
      
      cardStack.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(filterButton.snp.bottom).offset(40)
        make.height.equalTo(450)
      }
      
      buttonStack.snp.makeConstraints { make in
        make.centerX.equalToSuperview()
        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(62)
      }
    } else if deviceManager.isResolution896(){
      buttonStack.spacing = 8
      
      cardStack.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(filterButton.snp.bottom).offset(40)
        make.height.equalTo(450)
      }
      
      buttonStack.snp.makeConstraints { make in
        make.centerX.equalToSuperview()
        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(80)
      }
    } else if deviceManager.isResolution926() {
      buttonStack.spacing = 8
      
      cardStack.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(32)
        make.top.equalTo(filterButton.snp.bottom).offset(40)
        make.height.equalTo(450)
      }
      
      buttonStack.snp.makeConstraints { make in
        make.centerX.equalToSuperview()
        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(100)
      }
    } else if deviceManager.isResolution932() {
      buttonStack.spacing = 8
      
      cardStack.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(32)
        make.top.equalTo(filterButton.snp.bottom).offset(40)
        make.height.equalTo(450)
      }
      
      buttonStack.snp.makeConstraints { make in
        make.centerX.equalToSuperview()
        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(100)
      }
    } else {
      cardStack.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(filterButton.snp.bottom).offset(40)
        make.height.equalTo(450)
      }
      
      buttonStack.snp.makeConstraints { make in
        make.centerX.equalToSuperview()
        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(50)
      }
    }
  }
  
  // MARK: - Bind
  
  func bind(reactor: MatchingViewReactor) {
    
    // MARK: - Action
    
    Observable.empty()
      .map { MatchingViewReactor.Action.viewDidLoad }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    rx.viewWillAppear
      .map { _ in MatchingViewReactor.Action.viewWillAppear }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    cancelButton.rx.tap
      .withUnretained(self)
      .bind { $0.0.cardStack.swipe(.left, animated: true) }
      .disposed(by: disposeBag)
    
    heartButton.rx.tap
      .withUnretained(self)
      .bind { $0.0.cardStack.swipe(.right, animated: true) }
      .disposed(by: disposeBag)
    
    backButton.rx.tap
      .withUnretained(self)
      .bind { owner, _ in owner.cardStack.undoLastSwipe(animated: true) }
      .disposed(by: disposeBag)
      
    messageButton.rx.tap
      .withUnretained(self)
      .map { $0.0.cardStack.topCardIndex }
      .filterNil()
      .map { MatchingViewReactor.Action.message($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // MARK: - State
    
    reactor.state
      .map { $0.matchingMembers }
      .withUnretained(self)
      .bind { $0.0.cardStack.reloadData() }
      .disposed(by: disposeBag)
    
    // 필터VC 이동
    reactor.state
      .map { $0.isOpenedFilterVC }
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        let viewController = MatchingFilterViewController()
        viewController.hidesBottomBarWhenPushed = true
        owner.navigationController?.pushViewController(viewController, animated: true)

        // 필터 변경
        viewController.reactor.state
          .map { $0.requestCard }
          .filter { $0 }
          .map { _ in MatchingViewReactor.Action.didChangeFilter }
          .bind(to: owner.reactor.action)
          .disposed(by: owner.disposeBag)
      }
      .disposed(by: disposeBag)
    
    // 온보딩VC 이동
    reactor.state
      .map { $0.isOpenedOnboardingVC }
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        let viewController = OnboardingViewController(.initial2)
        viewController.hidesBottomBarWhenPushed = true
        owner.navigationController?.pushViewController(viewController, animated: true)
      }
      .disposed(by: disposeBag)
    
    // 매칭공개여부 팝업
    reactor.state
      .map { $0.isOpenedNoPublicPopup }
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        let popup = NoPublicStatePopUp()
        popup.modalPresentationStyle = .overFullScreen
        owner.present(popup, animated: false)
        
        // 공개허용 클릭
        popup.confirmLabel.rx.tapGesture()
          .map { _ in MatchingViewReactor.Action.didTapPublicButton }
          .bind(to: owner.reactor.action)
          .disposed(by: owner.disposeBag)
        
        // 팝업 창 닫기
        owner.reactor.state
          .map { $0.isOpenedNoPublicPopup }
          .filter { $0 == false }
          .bind { _ in popup.dismiss(animated: false) }
          .disposed(by: owner.disposeBag)
      }
      .disposed(by: disposeBag)
    
    // 매칭정보없음 팝업
    reactor.state
      .map { $0.isOpenedNoMatchingInfoPopup }
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        let popup = NoMatchingInfoPopup()
        popup.modalPresentationStyle = .overFullScreen
        owner.present(popup, animated: false)

        // 프로필 이미지 만들기 버튼
        popup.makeButton.rx.tap
          .map { MatchingViewReactor.Action.didTapMakeProfileButton }
          .bind(to: owner.reactor.action)
          .disposed(by: owner.disposeBag)
        
        // 팝업 창 닫기
        owner.reactor.state
          .map { $0.isOpenedNoMatchingInfoPopup }
          .filter { $0 == false }
          .bind { _ in popup.dismiss(animated: false) }
          .disposed(by: owner.disposeBag)
      }
      .disposed(by: disposeBag)
    
    // 매칭정보없음_최초 팝업
    reactor.state
      .map { $0.isOpenedNoMatchingInfoPopup_Initial }
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        let popup = NoMatchingInfoPopup_Initial()
        popup.modalPresentationStyle = .overFullScreen
        owner.present(popup, animated: false)
        
        // 프로필 이미지 만들기 버튼
        popup.confirmButton.rx.tap
          .map { MatchingViewReactor.Action.didTapMakeProfileButton }
          .bind(to: owner.reactor.action)
          .disposed(by: owner.disposeBag)
        
        // 팝업 창 닫기
        owner.reactor.state
          .map { $0.isOpenedNoMatchingInfoPopup_Initial }
          .filter { $0 == false }
          .bind { _ in popup.dismiss(animated: false) }
          .disposed(by: owner.disposeBag)
      }
      .disposed(by: disposeBag)
    
    // 카카오 팝업
    reactor.state
      .map { $0.isOpenedKakaoPopup }
      .filter { $0.0 }
      .withUnretained(self)
      .bind { owner, link in
        let popup = KakaoPopup()
        popup.modalPresentationStyle = .overFullScreen
        owner.present(popup, animated: false)
        
        // 링크 바로가기 버튼
        popup.kakaoButton.rx.tap
          .map { MatchingViewReactor.Action.didTapKakaoLinkButton(link.1) }
          .bind(to: owner.reactor.action)
          .disposed(by: owner.disposeBag)
        
        // 팝업 창 닫기
        owner.reactor.state
          .map { $0.isOpenedKakaoPopup }
          .filter { $0.0 == false }
          .bind { _ in popup.dismiss(animated: false) }
          .disposed(by: owner.disposeBag)
        
        // 외부 브라우저 이동
        owner.reactor.state
          .map { $0.isOpenedWeb }
          .filter { $0 }
          .bind { _ in UIApplication.shared.open(URL(string: link.1)!) }
          .disposed(by: owner.disposeBag)
      }
      .disposed(by: disposeBag)
    
    // 링크 오류 팝업
    reactor.state
      .map { $0.isOpenedBasicPopup }
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        let popup = BasicPopup(contents: "유효한 주소가 아닙니다.")
        popup.modalPresentationStyle = .overFullScreen
        owner.present(popup, animated: false)
      }
      .disposed(by: disposeBag)
    
    // 텍스트이미지 변경
    reactor.state
      .map { $0.currentTextImage }
      .map { UIImage(named: $0.imageName) }
      .bind(to: informationImageView.rx.image)
      .disposed(by: disposeBag)
    
    // 로딩 중
    reactor.state
      .map { $0.isLoading }
      .withUnretained(self)
      .bind { owner, isLoading in
        if isLoading {
          owner.loadingIndicator.startAnimating()
          owner.view.isUserInteractionEnabled = false
        } else {
          owner.loadingIndicator.stopAnimating()
          owner.view.isUserInteractionEnabled = true
        }
      }
      .disposed(by: disposeBag)
    
    // 터치시 백그라운드 컬러 변경
    reactor.state
      .map { $0.backgroundColor }
      .withUnretained(self)
      .bind { owner, swipeType in
        switch swipeType {
        case .heart:
          UIView.animate(withDuration: 0.2, animations: {
            owner.topRoundedBackgroundView.tintColor = .idorm_green
          }) { isFinished in
            if isFinished {
              UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
                owner.topRoundedBackgroundView.tintColor = .idorm_blue
              }
            }
          }
        case .cancel:
          UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            owner.topRoundedBackgroundView.tintColor = .idorm_red
          }) { isFinished in
            if isFinished {
              UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
                owner.topRoundedBackgroundView.tintColor = .idorm_blue
              }
            }
          }
        default: break
        }
      }
      .disposed(by: disposeBag)
    
    // 스와이프시 백그라운드 컬러 변경
    reactor.state
      .map { $0.backgroundColor_withSwipe }
      .withUnretained(self)
      .bind { owner, swipeType in
        switch swipeType {
        case .heart:
          UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            owner.topRoundedBackgroundView.tintColor = .idorm_green
          })
        case .cancel:
          UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            owner.topRoundedBackgroundView.tintColor = .idorm_red
          })
        case .none:
          UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
            owner.topRoundedBackgroundView.tintColor = .idorm_blue
          }
        }
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - Card Swipe

extension MatchingViewController: SwipeCardStackDataSource, SwipeCardStackDelegate, UIGestureRecognizerDelegate {
  func card(from member: MatchingDTO.Retrieve) -> SwipeCard {
    let card = SwipeCard()
    card.swipeDirections = [.left, .right]
    card.content = MatchingCard(member)
    card.panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture))
    
    return card
  }
  
  func cardStack(_ cardStack: Shuffle_iOS.SwipeCardStack, cardForIndexAt index: Int) -> Shuffle_iOS.SwipeCard {
    return card(from: reactor.currentState.matchingMembers[index])
  }
  
  func numberOfCards(in cardStack: Shuffle_iOS.SwipeCardStack) -> Int {
    return reactor.currentState.matchingMembers.count
  }
  
  func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
    let id = reactor.currentState.matchingMembers[index].memberId
    switch direction {
    case .left:
      Observable.just(id)
        .map { MatchingViewReactor.Action.cancel($0) }
        .bind(to: reactor.action)
        .disposed(by: disposeBag)
    case .right:
      Observable.just(id)
        .map { MatchingViewReactor.Action.heart($0) }
        .bind(to: reactor.action)
        .disposed(by: disposeBag)
    default: break
    }
  }
  
  func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int) {
    
    // TODO: 신고하기 기능 구현
    
    // MatchingBottomAlertVC 보여주기
    let bottomAlertVC = MatchingBottomAlertViewController()
    bottomAlertVC.modalPresentationStyle = .pageSheet
    presentPanModal(bottomAlertVC)
  }
  
  @objc private func handlePanGesture(sender: UIPanGestureRecognizer) {
    let card = sender.view as! SwipeCard
    let velocity = sender.velocity(in: card)
    
    if abs(velocity.x) > abs(velocity.y) {
      if velocity.x < 0 {
        // 취소 스와이프 감지
        Observable.empty()
          .map { MatchingViewReactor.Action.didBeginSwipe(.cancel) }
          .bind(to: reactor.action)
          .disposed(by: disposeBag)
      } else {
        // 좋아요 스와이프 감지
        Observable.empty()
          .map { MatchingViewReactor.Action.didBeginSwipe(.heart) }
          .bind(to: reactor.action)
          .disposed(by: disposeBag)
      }
    }
    
    if sender.state == .ended {
      // 스와이프 종료 이벤트
      Observable.empty()
        .map { MatchingViewReactor.Action.didBeginSwipe(.none) }
        .bind(to: reactor.action)
        .disposed(by: disposeBag)
    }
  }
}
