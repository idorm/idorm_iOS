import UIKit

import DeviceKit
import PanModal
import SnapKit
import Then
import Shuffle_iOS
import RxSwift
import RxCocoa
import RxOptional

final class MatchingViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let filterButton = UIButton().then {
    var config = UIButton.Configuration.plain()
    config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    config.image = UIImage(named: "filter(Matching)")
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
    $0.image = UIImage(named: "topRoundedBackground(Matching)")?.withRenderingMode(.alwaysTemplate)
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
  private let viewModel = MatchingViewModel()
  
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
  
  override func bind() {
    super.bind()
    
    // MARK: - Input
    
    // 자신의 공유 상태 업데이트
    MemberInfoStorage.instance.publicStateDidChange
      .distinctUntilChanged()
      .filterNil()
      .bind(to: viewModel.input.publicStateDidChange)
      .disposed(by: disposeBag)

    // 화면 접근
    rx.viewWillAppear
      .map { _ in Void() }
      .bind(to: viewModel.input.viewWillAppear)
      .disposed(by: disposeBag)
    
    // 필터버튼 클릭
    filterButton.rx.tap
      .bind(to: viewModel.input.filterButtonDidTap)
      .disposed(by: disposeBag)
    
    // 새로고침 버튼 클릭
    refreshButton.rx.tap
      .withUnretained(self)
      .filter { $0.0.viewModel.output.isLoading.value == false }
      .map { _ in Void() }
      .bind(to: viewModel.input.refreshButtonDidTap)
      .disposed(by: disposeBag)
    
    // 취소버튼 클릭
    cancelButton.rx.tap
      .throttle(.seconds(1), scheduler: MainScheduler.instance)
      .withUnretained(self)
      .map { $0.0 }
      .map { $0.cardStack.swipe(.left, animated: true) }
      .bind(to: viewModel.input.cancelButtonDidTap)
      .disposed(by: disposeBag)
    
    // 메세지버튼 클릭
    messageButton.rx.tap
      .withUnretained(self)
      .map { $0.0 }
      .map { $0.cardStack.topCardIndex }
      .filterNil()
      .bind(to: viewModel.input.messageButtonDidTap)
      .disposed(by: disposeBag)
    
    // 하트버튼 클릭
    heartButton.rx.tap
      .throttle(.seconds(1), scheduler: MainScheduler.instance)
      .withUnretained(self)
      .map { $0.0 }
      .map { $0.cardStack.swipe(.right, animated: true) }
      .bind(to: viewModel.input.heartButtonDidTap)
      .disposed(by: disposeBag)
    
    // 백버튼 클릭
    backButton.rx.tap
      .throttle(.seconds(1), scheduler: MainScheduler.instance)
      .withUnretained(self)
      .map { $0.0 }
      .map { $0.cardStack.undoLastSwipe(animated: true) }
      .bind(to: viewModel.input.backButtonDidTap)
      .disposed(by: disposeBag)
    
    // MARK: - Output
    
    // 백그라운드 컬러 기본 컬러로 다시 바꾸기
    viewModel.output.drawBackTopBackgroundColor
      .withUnretained(self)
      .bind(onNext: { owner, _ in
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
          owner.topRoundedBackgroundView.tintColor = .idorm_blue
        }
      })
      .disposed(by: disposeBag)
    
    // 백그라운드 컬러 변경 감지
    viewModel.output.onChangedTopBackgroundColor
      .withUnretained(self)
      .bind(onNext: { owner, direction in
        switch direction {
        case .cancel:
          UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            owner.topRoundedBackgroundView.tintColor = .idorm_red
          })
        case .heart:
          UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            owner.topRoundedBackgroundView.tintColor = .idorm_green
          })
        }
      })
      .disposed(by: disposeBag)
    
    // FilterVC 보여주기
    viewModel.output.pushToFilterVC
      .withUnretained(self)
      .bind(onNext: { owner, _ in
        let viewController = MatchingFilterViewController()
        viewController.reactor = MatchingFilterViewReactor()
        viewController.hidesBottomBarWhenPushed = true
        owner.navigationController?.pushViewController(viewController, animated: true)
        
//        // 선택 초기화 -> POP 필터VC -> 카드 다시 요청
//        viewController.viewModel.output.requestCards
//          .bind(to: owner.viewModel.input.resetFilterButtonDidTap)
//          .disposed(by: owner.disposeBag)
//
//        // 필터링 완료 -> POP 필터VC -> 필터링 카드 요청
//        viewController.viewModel.output.requestFilteredCards
//          .bind(to: owner.viewModel.input.confirmFilterButtonDidTap)
//          .disposed(by: owner.disposeBag)
      })
      .disposed(by: disposeBag)
    
    // 백그라운드 컬러 감지 (터치할 때)
    viewModel.output.onChangedTopBackgroundColor_WithTouch
      .withUnretained(self)
      .bind(onNext: { owner, type in
        switch type {
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
        }
      })
      .disposed(by: disposeBag)
    
    // 프로필 이미지 만들기 팝업 창 띄우기
    viewModel.output.presentMatchingPopupVC
      .withUnretained(self)
      .map { $0.0 }
      .bind {
        let matchingPopupVC = NoMatchingInfoPopup()
        matchingPopupVC.modalPresentationStyle = .overFullScreen
        $0.present(matchingPopupVC, animated: false)
        
        // 프로필 이미지 만들기 버튼 클릭
        matchingPopupVC.makeButton.rx.tap
          .bind(to: $0.viewModel.input.makeProfileImageButtonDidTap)
          .disposed(by: $0.disposeBag)
         
        // 팝업 창 닫기
        $0.viewModel.output.dismissNoMatchingPopup
          .bind { matchingPopupVC.dismiss(animated: false) }
          .disposed(by: $0.disposeBag)
      }
      .disposed(by: disposeBag)
    
    // 온보딩 페이지로 이동
    viewModel.output.pushToOnboardingVC
      .withUnretained(self)
      .bind {
        let viewController = OnboardingViewController(.initial2)
        viewController.hidesBottomBarWhenPushed = true
        $0.0.navigationController?.pushViewController(viewController, animated: true)
      }
      .disposed(by: disposeBag)
    
    // 팝업 창 띄우기
    viewModel.output.presentPopup
      .withUnretained(self)
      .bind {
        let popup = BasicPopup(contents: $0.1)
        popup.modalPresentationStyle = .overFullScreen
        $0.0.present(popup, animated: false)
      }
      .disposed(by: disposeBag)
    
    // 카드 스택 뷰 리로드
    viewModel.output.reloadCardStack
      .withUnretained(self)
      .map { $0.0 }
      .bind(onNext: { $0.cardStack.reloadData() })
      .disposed(by: disposeBag)
    
    // 인디케이터 제어
    viewModel.output.isLoading
      .bind(to: loadingIndicator.rx.isAnimating)
      .disposed(by: disposeBag)
    
    // 화면 인터렉션 제어
    viewModel.output.isLoading
      .map { !$0 }
      .bind(to: view.rx.isUserInteractionEnabled)
      .disposed(by: disposeBag)

    // 매칭 이미지 뷰 변경
    viewModel.output.informationImageViewStatus
      .map { UIImage(named: $0.imageName) }
      .bind(to: informationImageView.rx.image)
      .disposed(by: disposeBag)
    
    // 매칭 공개 여부 팝업 띄우기
    viewModel.output.presentNoSharePopupVC
      .withUnretained(self)
      .bind(onNext: { owner, _ in
        let popupVC = NoPublicStatePopUp()
        popupVC.modalPresentationStyle = .overFullScreen
        owner.present(popupVC, animated: false)
        
        // 공개 허용 버튼 클릭
        popupVC.confirmLabel.rx.tapGesture()
          .skip(1)
          .map { _ in Void() }
          .bind(to: owner.viewModel.input.publicButtonDidTap)
          .disposed(by: owner.disposeBag)
        
        // 팝업창 닫기
        owner.viewModel.output.dismissNoSharePopupVC
          .bind(onNext: { popupVC.dismiss(animated: false) })
          .disposed(by: self.disposeBag)
      })
      .disposed(by: disposeBag)
    
    // 카카오 링크 페이지 띄우기
    viewModel.output.presentKakaoPopupVC
      .withUnretained(self)
      .bind(onNext: { owner, index in
        let viewController = KakaoPopup()
        viewController.modalPresentationStyle = .overFullScreen
        owner.present(viewController, animated: false)
        
        // 오픈채팅 링크 바로 가기 버튼 클릭
        viewController.kakaoButton.rx.tap
          .map { index }
          .bind(to: owner.viewModel.input.kakaoLinkButtonDidTap)
          .disposed(by: owner.disposeBag)
        
        // KakaoLinkVC 닫기
        owner.viewModel.output.dismissKakaoLinkVC
          .bind(onNext: { viewController.dismiss(animated: false) })
          .disposed(by: self.disposeBag)
      })
      .disposed(by: disposeBag)
    
   // 카카오 링크 사파리로 열기
    viewModel.output.presentSafari
      .withUnretained(self)
      .bind(onNext: { owner, link in UIApplication.shared.open(URL(string: link)!) })
      .disposed(by: disposeBag)
  }
}

// MARK: - Card Swipe

extension MatchingViewController: SwipeCardStackDataSource, SwipeCardStackDelegate, UIGestureRecognizerDelegate {
  func card(from member: MatchingModel.Member) -> SwipeCard {
    let card = SwipeCard()
    card.swipeDirections = [.left, .right]
    card.content = MatchingCard(member)
    card.panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture))
    
    return card
  }
  
  func cardStack(_ cardStack: Shuffle_iOS.SwipeCardStack, cardForIndexAt index: Int) -> Shuffle_iOS.SwipeCard {
    return card(from: viewModel.matchingMembers.value[index])
  }
  
  func numberOfCards(in cardStack: Shuffle_iOS.SwipeCardStack) -> Int {
    return viewModel.matchingMembers.value.count
  }
  
  func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
    let card = viewModel.matchingMembers.value[index]
    let memberId = card.memberId
    switch direction {
    case .left: viewModel.input.leftSwipeDidEnd.onNext(memberId)
    case .right: viewModel.input.rightSwipeDidEnd.onNext(memberId)
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
        viewModel.input.swipingCard.onNext(.cancel)
      } else {
        // 좋아요 스와이프 감지
        viewModel.input.swipingCard.onNext(.heart)
      }
    }
    
    if sender.state == .ended {
      // 스와이프 종료 이벤트
      viewModel.input.swipeDidEnd.onNext(.none)
    }
  }
}
