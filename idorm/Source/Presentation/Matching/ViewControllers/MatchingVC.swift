//
//  MatchingViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/12/21.
//

import UIKit

import DeviceKit
import PanModal
import SnapKit
import Then
import Koloda
import RxSwift
import RxCocoa
import RxOptional
import ReactorKit

final class MatchingViewController: BaseViewController, View {
  
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
    $0.image = #imageLiteral(resourceName: "background_curve_blue").withRenderingMode(.alwaysTemplate)
    $0.tintColor = .idorm_blue
  }
  
  private let loadingIndicator = UIActivityIndicatorView().then {
    $0.color = .darkGray
  }
  
  private lazy var kolodaView = KolodaView().then {
    $0.dataSource = self
    $0.delegate = self
  }
  
  private lazy var buttonStack = UIStackView().then { stack in
    [cancelButton, backButton, messageButton, heartButton]
      .forEach { stack.addArrangedSubview($0) }
    stack.spacing = 4
  }
  
  private let informationImageView = UIImageView()
  private let cancelButton = MatchingUtilities.matchingButton(imageName: "circle_dislike_red")
  private let messageButton = MatchingUtilities.matchingButton(imageName: "circle_speechBubble_yellow")
  private let heartButton = MatchingUtilities.matchingButton(imageName: "circle_heart_green")
  private let backButton = MatchingUtilities.matchingButton(imageName: "circle_back_blue")
  
  // MARK: - LifeCycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isNavigationBarHidden = true
    tabBarController?.tabBar.isHidden = false
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    view.backgroundColor = .white
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [
      topRoundedBackgroundView,
      buttonStack,
      filterButton,
      refreshButton,
      informationImageView,
      kolodaView,
      loadingIndicator
    ]
      .forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    loadingIndicator.snp.makeConstraints { make in
      make.center.equalTo(kolodaView)
    }
    
    topRoundedBackgroundView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
    }
    
    filterButton.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide).inset(16)
      make.trailing.equalToSuperview().inset(24)
    }
    
    informationImageView.snp.makeConstraints { make in
      make.centerY.equalTo(kolodaView).offset(50)
      make.centerX.equalToSuperview()
    }
    
    refreshButton.snp.makeConstraints { make in
      make.centerY.equalTo(filterButton)
      make.trailing.equalTo(filterButton.snp.leading).offset(-16)
    }
    
    let deviceManager = DeviceManager.shared
    
    if deviceManager.isResoultion568() {
      kolodaView.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalToSuperview()
        make.height.equalTo(436)
      }
      
      buttonStack.snp.makeConstraints { make in
        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(4)
        make.centerX.equalToSuperview()
      }
    } else if deviceManager.isResolution667() {
      kolodaView.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(filterButton.snp.bottom).offset(4)
        make.height.equalTo(436)
      }
      
      buttonStack.snp.makeConstraints { make in
        make.centerX.equalToSuperview()
        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(8)
      }
    } else if deviceManager.isResolution736() {
      kolodaView.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(filterButton.snp.bottom).offset(40)
        make.height.equalTo(436)
      }
      
      buttonStack.snp.makeConstraints { make in
        make.centerX.equalToSuperview()
        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(32)
      }
    } else if deviceManager.isResolution812() {
      buttonStack.spacing = 8
      
      kolodaView.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(filterButton.snp.bottom).offset(40)
        make.height.equalTo(436)
      }
      
      buttonStack.snp.makeConstraints { make in
        make.centerX.equalToSuperview()
        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(40)
      }
    } else if deviceManager.isResolution844() {
      buttonStack.spacing = 8
      
      kolodaView.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(filterButton.snp.bottom).offset(40)
        make.height.equalTo(436)
      }
      
      buttonStack.snp.makeConstraints { make in
        make.centerX.equalToSuperview()
        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(62)
      }
    } else if deviceManager.isResolution852() {
      buttonStack.spacing = 8
      
      kolodaView.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(filterButton.snp.bottom).offset(40)
        make.height.equalTo(436)
      }
      
      buttonStack.snp.makeConstraints { make in
        make.centerX.equalToSuperview()
        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(62)
      }
    } else if deviceManager.isResolution896(){
      buttonStack.spacing = 8
      
      kolodaView.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(filterButton.snp.bottom).offset(40)
        make.height.equalTo(436)
      }
      
      buttonStack.snp.makeConstraints { make in
        make.centerX.equalToSuperview()
        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(80)
      }
    } else if deviceManager.isResolution926() {
      buttonStack.spacing = 8
      
      kolodaView.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(32)
        make.top.equalTo(filterButton.snp.bottom).offset(40)
        make.height.equalTo(436)
      }
      
      buttonStack.snp.makeConstraints { make in
        make.centerX.equalToSuperview()
        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(100)
      }
    } else if deviceManager.isResolution932() {
      buttonStack.spacing = 8
      
      kolodaView.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(32)
        make.top.equalTo(filterButton.snp.bottom).offset(40)
        make.height.equalTo(436)
      }
      
      buttonStack.snp.makeConstraints { make in
        make.centerX.equalToSuperview()
        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(100)
      }
    } else {
      kolodaView.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(filterButton.snp.bottom).offset(40)
        make.height.equalTo(436)
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
    
    rx.viewWillAppear
      .take(1)
      .map { _ in MatchingViewReactor.Action.viewDidLoad }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    rx.viewWillAppear
      .map { _ in MatchingViewReactor.Action.viewWillAppear }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    cancelButton.rx.tap
      .withUnretained(self)
      .map { $0.0.kolodaView.swipe(.left, force: true) }
      .map { MatchingViewReactor.Action.didTapXmarkButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    heartButton.rx.tap
      .withUnretained(self)
      .map { $0.0.kolodaView.swipe(.right) }
      .map { MatchingViewReactor.Action.didTapHeartButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    backButton.rx.tap
      .withUnretained(self)
      .bind { owner, _ in owner.kolodaView.revertAction(direction: .down) }
      .disposed(by: disposeBag)
    
    messageButton.rx.tap
      .withUnretained(self)
      .map { $0.0.kolodaView.currentCardIndex }
      .map { MatchingViewReactor.Action.didTapSpeechBubbleButton($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    filterButton.rx.tap
      .map { MatchingViewReactor.Action.didTapFilterButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    refreshButton.rx.tap
      .map { MatchingViewReactor.Action.didTapRefreshButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // MARK: - State
    
    // ReloadData
    reactor.state
      .map { $0.matchingMembers }
      .distinctUntilChanged()
      .withUnretained(self)
      .bind { $0.0.kolodaView.reloadData() }
      .disposed(by: disposeBag)
    
    // 필터VC 이동
    reactor.state
      .map { $0.isOpenedFilterVC }
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        let viewController = MatchingFilterViewController()
        viewController.reactor = MatchingFilterViewReactor()
        viewController.hidesBottomBarWhenPushed = true
        owner.navigationController?.pushViewController(viewController, animated: true)
        
        // 필터 변경
        viewController.reactor?.state
          .map { $0.requestCard }
          .distinctUntilChanged()
          .filter { $0 }
          .map { _ in MatchingViewReactor.Action.didChangeFilter }
          .bind(to: reactor.action)
          .disposed(by: owner.disposeBag)
      }
      .disposed(by: disposeBag)
    
    // 온보딩VC 이동
    reactor.state
      .map { $0.isOpenedOnboardingVC }
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        let viewController = OnboardingViewController(.main)
        viewController.reactor = OnboardingViewReactor(.main)
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
          .skip(1)
          .map { _ in MatchingViewReactor.Action.didTapPublicButton }
          .bind(to: reactor.action)
          .disposed(by: owner.disposeBag)
        
        // 팝업 창 닫기
        reactor.state
          .map { $0.isDismissedPopup }
          .filter { $0 }
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
          .bind(to: reactor.action)
          .disposed(by: owner.disposeBag)
        
        // 팝업 창 닫기
        reactor.state
          .map { $0.isDismissedPopup }
          .filter { $0 }
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
          .bind(to: reactor.action)
          .disposed(by: owner.disposeBag)
        
        // 팝업 창 닫기
        reactor.state
          .map { $0.isDismissedPopup }
          .filter { $0 }
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
          .bind(to: reactor.action)
          .disposed(by: owner.disposeBag)
        
        // 팝업 창 닫기
        reactor.state
          .map { $0.isDismissedPopup }
          .filter { $0 }
          .bind { _ in popup.dismiss(animated: false) }
          .disposed(by: owner.disposeBag)
        
        // 외부 브라우저 이동
        reactor.state
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
    
    // 바텀 시트
    reactor.state
      .map { $0.isOpenedBottomSheet }
      .filter { $0 }
      .withUnretained(self)
      .bind {
        let bottomSheet = MatchingBottomSheet()
        $0.0.presentPanModal(bottomSheet)
      }
      .disposed(by: disposeBag)
    
    // TODO: 매칭 카드 맞추기
    
    reactor.state
      .map { $0.isGreenBackgroundColor }
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
          owner.topRoundedBackgroundView.tintColor = .idorm_green
        }) { isFinished in
          UIView.animate(withDuration: 0.2, delay: 0) {
            owner.topRoundedBackgroundView.tintColor = .idorm_blue
          }
        }
      }
      .disposed(by: disposeBag)
    
    reactor.state
      .map { $0.isRedBackgroundColor }
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
          owner.topRoundedBackgroundView.tintColor = .idorm_red
        }) { isFinished in
          UIView.animate(withDuration: 0.2, delay: 0) {
            owner.topRoundedBackgroundView.tintColor = .idorm_blue
          }
        }
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - KolodaView

extension MatchingViewController: KolodaViewDataSource, KolodaViewDelegate {
  // 카드 생성
  func koloda(_ koloda: Koloda.KolodaView, viewForCardAt index: Int) -> UIView {
    guard let reactor = reactor else { return UIView() }
    let members = reactor.currentState.matchingMembers
    let card = MatchingCard(members[index])
    
    // 옵션 버튼 클릭 이벤트
    card.optionButton.rx.tap
      .map { MatchingViewReactor.Action.didTapOptionButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    return card
  }
  
  // 카드 갯수
  func kolodaNumberOfCards(_ koloda: Koloda.KolodaView) -> Int {
    guard let reactor = reactor else { return 0 }
    return reactor.currentState.matchingMembers.count
  }
  
  // 카드 조회 애니메이션 유무
  func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool {
    return false
  }
  
  // 다음 카드 투명화 유무
  func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
    return false
  }
  
  // 카드 스와이프 종료
  func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
    guard let reactor = reactor else { return }
    let memberID = reactor.currentState.matchingMembers[index].memberId
    switch direction {
    case .left:
      Observable<MatchingViewReactor.Action>.just(.dislikeCard(memberID))
        .bind(to: reactor.action)
        .disposed(by: disposeBag)
    case .right:
      Observable<MatchingViewReactor.Action>.just(.likeCard(memberID))
        .bind(to: reactor.action)
        .disposed(by: disposeBag)
    default:
      break
    }
    
    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
      self.topRoundedBackgroundView.tintColor = .idorm_blue
    })
  }
  
  // 카드 드래그 종료
  func kolodaPanFinished(_ koloda: KolodaView, card: DraggableCardView) {
    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
      self.topRoundedBackgroundView.tintColor = .idorm_blue
    })
  }
  
  // 카드 드래그 시작
  func koloda(_ koloda: KolodaView, draggedCardWithPercentage finishPercentage: CGFloat, in direction: SwipeResultDirection) {
    switch direction {
    case .left:
      UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
        self.topRoundedBackgroundView.tintColor = .idorm_red
      })
    case .right:
      UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
        self.topRoundedBackgroundView.tintColor = .idorm_green
      })
    default:
      break
    }
  }
}
