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
import Koloda
import RxSwift
import RxCocoa
import RxOptional
import ReactorKit

final class MatchingMateViewController: BaseViewController, View {
  
  typealias Reactor = MatchingMateViewReactor
  
  // MARK: - UI Components
  
  /// `ic_filter인 `UIButton`
  private let filterButton: UIButton = {
    let button = UIButton()
    button.setImage(.iDormIcon(.filter), for: .normal)
    return button
  }()
  
  /// 새로고침 `UIButton`
  private let refreshButton: iDormButton = {
    let button = iDormButton("새로고침")
    button.baseBackgroundColor = .white
    button.baseForegroundColor = .iDormColor(.iDormBlue)
    button.contentInset =
    NSDirectionalEdgeInsets(top: 3.0, leading: 10.0, bottom: 3.0, trailing: 10.0)
    button.cornerRadius = 18.0
    button.font = .iDormFont(.bold, size: 12.0)
    return button
  }()
  
  /// 상단 모서리가 둥근 `UIView`
  private let topCornerView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .iDormImage(.matchingMate_background)?.withRenderingMode(.alwaysTemplate)
    imageView.tintColor = .iDormColor(.iDormBlue)
    return imageView
  }()
  
  /// 카드 리스트가 모여있는 `KolodaView`
  private lazy var cardStackView: KolodaView = {
    let view = KolodaView()
    view.dataSource = self
    view.delegate = self
    return view
  }()
  
  /// 버튼이 모여있는 `UIView`
  private lazy var buttonsView: MatchingMateButtonsView = {
    let view = MatchingMateButtonsView()
    view.buttonHandler = { buttonType in
      switch buttonType {
      case .like:
        self.cardStackView.swipe(.right)
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
          self.topCornerView.tintColor = .iDormColor(.iDormGreen)
        }) { isFinished in
          UIView.animate(withDuration: 0.2, delay: 0) {
            self.topCornerView.tintColor = .iDormColor(.iDormBlue)
          }
        }
      case .dislike:
        self.cardStackView.swipe(.left)
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
          self.topCornerView.tintColor = .iDormColor(.iDormRed)
        }) { isFinished in
          UIView.animate(withDuration: 0.2, delay: 0) {
            self.topCornerView.tintColor = .iDormColor(.iDormBlue)
          }
        }
      case .message:
        let viewController = iDormPopupViewController(.kakao)
        let index = self.cardStackView.currentCardIndex
        viewController.modalPresentationStyle = .overFullScreen
        viewController.confirmButtonHandler = {
          self.reactor?.action.onNext(.kakaoButtonDidTap(index: index))
        }
        self.present(viewController, animated: false)
      case .reverse:
        self.cardStackView.revertAction(direction: .down)
      }
    }
    return view
  }()
  
  private lazy var quotationView: MatchingMateQuotationView = {
    let view = MatchingMateQuotationView()
    view.updateTitle(.noCard)
    return view
  }()
  
  // MARK: - Properties
  
  override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
  
  // MARK: - LifeCycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.setNavigationBarHidden(true, animated: true)
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    self.view.backgroundColor = .iDormColor(.iDormMatchingScreen)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [
      self.topCornerView,
      self.quotationView,
      self.cardStackView,
      self.refreshButton,
      self.filterButton,
      self.buttonsView
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.topCornerView.snp.makeConstraints { make in
      make.top.directionalHorizontalEdges.equalToSuperview()
    }
    
    self.filterButton.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide).inset(16.0)
      make.trailing.equalToSuperview().inset(24.0)
    }
    
    self.refreshButton.snp.makeConstraints { make in
      make.centerY.equalTo(self.filterButton)
      make.trailing.equalTo(self.filterButton.snp.leading).offset(-16.0)
      make.height.equalTo(24.0)
    }
    
    self.cardStackView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset((self.view.frame.height - 436) / 3)
      make.centerX.equalToSuperview()
      make.width.equalTo(327.0)
      make.height.equalTo(450.0)
    }
    
    self.buttonsView.snp.makeConstraints { make in
      make.top.equalTo(self.cardStackView.snp.bottom)
      make.directionalHorizontalEdges.equalToSuperview()
      make.bottom.equalTo(self.view.safeAreaLayoutGuide)
    }
    
    self.quotationView.snp.makeConstraints { make in
      make.center.equalTo(self.cardStackView)
    }
  }
  
  // MARK: - Bind
  
  func bind(reactor: MatchingMateViewReactor) {
    
    // Action
    
    self.rx.viewDidLoad
      .map { Reactor.Action.viewDidLoad }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.rx.viewWillAppear
      .map { _ in Reactor.Action.viewWillAppear }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.refreshButton.rx.tap
      .map { Reactor.Action.refreshButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    
    reactor.pulse(\.$quotationType)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, viewType in
        owner.quotationView.updateTitle(viewType)
      }
      .disposed(by: self.disposeBag)
    
    reactor.pulse(\.$mates).skip(1)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, mates in
        owner.cardStackView.reloadData()
      }
      .disposed(by: self.disposeBag)
    
    reactor.pulse(\.$openURL).skip(1)
      .compactMap { $0 }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive { UIApplication.shared.open($0) }
      .disposed(by: self.disposeBag)
    
    reactor.pulse(\.$presentToWelcomePopupVC).skip(1)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        let viewController = iDormPopupViewController(.welcome)
        viewController.modalPresentationStyle = .overFullScreen
        viewController.confirmButtonHandler = {
          owner.navigateToMatchingInfoSetupVC()
        }
        owner.present(viewController, animated: false)
      }
      .disposed(by: self.disposeBag)
    
    reactor.pulse(\.$presentToNoPublicPopupVC).skip(1)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        let viewController = iDormPopupViewController(.noPublicMatchingInfo)
        viewController.modalPresentationStyle = .overFullScreen
        viewController.confirmButtonHandler = {
          owner.reactor?.action.onNext(.publicButtonDidTap)
        }
        owner.present(viewController, animated: false)
      }
      .disposed(by: self.disposeBag)
    

//    // 필터VC 이동
//    reactor.state
//      .map { $0.isOpenedFilterVC }
//      .filter { $0 }
//      .withUnretained(self)
//      .bind { owner, _ in
//        let viewController = MatchingFilterViewController()
//        viewController.reactor = MatchingFilterViewReactor()
//        viewController.hidesBottomBarWhenPushed = true
//        owner.navigationController?.pushViewController(viewController, animated: true)
//        
//        // 필터 변경
//        viewController.reactor?.state
//          .map { $0.requestCard }
//          .distinctUntilChanged()
//          .filter { $0 }
//          .map { _ in MatchingViewReactor.Action.didChangeFilter }
//          .bind(to: reactor.action)
//          .disposed(by: owner.disposeBag)
//      }
//      .disposed(by: disposeBag)
//    
//    // 온보딩VC 이동
//    reactor.state
//      .map { $0.isOpenedOnboardingVC }
//      .filter { $0 }
//      .withUnretained(self)
//      .bind { owner, _ in
//        let viewController = MatchingInfoSetupViewController()
////        viewController.reactor = OnboardingViewReactor(.main)
//        viewController.hidesBottomBarWhenPushed = true
//        owner.navigationController?.pushViewController(viewController, animated: true)
//      }
//      .disposed(by: disposeBag)
//    
//    // 매칭공개여부 팝업
//    reactor.state
//      .map { $0.isOpenedNoPublicPopup }
//      .filter { $0 }
//      .withUnretained(self)
//      .bind { owner, _ in
//        let popup = NoPublicStatePopUp()
//        popup.modalPresentationStyle = .overFullScreen
//        owner.present(popup, animated: false)
//        
//        // 공개허용 클릭
//        popup.confirmLabel.rx.tapGesture()
//          .skip(1)
//          .map { _ in MatchingViewReactor.Action.didTapPublicButton }
//          .bind(to: reactor.action)
//          .disposed(by: owner.disposeBag)
//        
//        // 팝업 창 닫기
//        reactor.state
//          .map { $0.isDismissedPopup }
//          .filter { $0 }
//          .bind { _ in popup.dismiss(animated: false) }
//          .disposed(by: owner.disposeBag)
//      }
//      .disposed(by: disposeBag)
//    
//    // 매칭정보없음 팝업
//    reactor.state
//      .map { $0.isOpenedNoMatchingInfoPopup }
//      .filter { $0 }
//      .withUnretained(self)
//      .bind { owner, _ in
//        let popup = NoMatchingInfoPopup()
//        popup.modalPresentationStyle = .overFullScreen
//        owner.present(popup, animated: false)
//
//        // 프로필 이미지 만들기 버튼
//        popup.makeButton.rx.tap
//          .map { MatchingViewReactor.Action.didTapMakeProfileButton }
//          .bind(to: reactor.action)
//          .disposed(by: owner.disposeBag)
//        
//        // 팝업 창 닫기
//        reactor.state
//          .map { $0.isDismissedPopup }
//          .filter { $0 }
//          .bind { _ in popup.dismiss(animated: false) }
//          .disposed(by: owner.disposeBag)
//      }
//      .disposed(by: disposeBag)
//    
//    // 매칭정보없음_최초 팝업
//    reactor.state
//      .map { $0.isOpenedNoMatchingInfoPopup_Initial }
//      .filter { $0 }
//      .withUnretained(self)
//      .bind { owner, _ in
//        let popup = NoMatchingInfoPopup_Initial()
//        popup.modalPresentationStyle = .overFullScreen
//        owner.present(popup, animated: false)
//        
//        // 프로필 이미지 만들기 버튼
//        popup.confirmButton.rx.tap
//          .map { MatchingViewReactor.Action.didTapMakeProfileButton }
//          .bind(to: reactor.action)
//          .disposed(by: owner.disposeBag)
//        
//        // 팝업 창 닫기
//        reactor.state
//          .map { $0.isDismissedPopup }
//          .filter { $0 }
//          .bind { _ in popup.dismiss(animated: false) }
//          .disposed(by: owner.disposeBag)
//      }
//      .disposed(by: disposeBag)
//    
//    // 카카오 팝업
//    reactor.state
//      .map { $0.isOpenedKakaoPopup }
//      .filter { $0.0 }
//      .withUnretained(self)
//      .bind { owner, link in
//        let popup = KakaoPopup()
//        popup.modalPresentationStyle = .overFullScreen
//        owner.present(popup, animated: false)
//        
//        // 링크 바로가기 버튼
//        popup.kakaoButton.rx.tap
//          .map { MatchingViewReactor.Action.didTapKakaoLinkButton }
//          .bind(to: reactor.action)
//          .disposed(by: owner.disposeBag)
//        
//        // 팝업 창 닫기
//        reactor.state
//          .map { $0.isDismissedPopup }
//          .filter { $0 }
//          .bind { _ in popup.dismiss(animated: false) }
//          .disposed(by: owner.disposeBag)
//        
//        // 외부 브라우저 이동
//        reactor.state
//          .map { $0.isOpenedWeb }
//          .filter { $0 }
//          .bind { _ in UIApplication.shared.open(URL(string: link.1)!) }
//          .disposed(by: owner.disposeBag)
//      }
//      .disposed(by: disposeBag)
//    
//    // 링크 오류 팝업
//    reactor.state
//      .map { $0.isOpenedBasicPopup }
//      .filter { $0 }
//      .withUnretained(self)
//      .bind { owner, _ in
//        let popup = iDormPopupViewController(contents: "유효한 주소가 아닙니다.")
//        popup.modalPresentationStyle = .overFullScreen
//        owner.present(popup, animated: false)
//      }
//      .disposed(by: disposeBag)
//    
//    // 현재 텍스트 이미지
//    reactor.state
//      .map { $0.currentTextImage }
//      .map { UIImage(named: $0.imageName) }
//      .bind(to: informationImageView.rx.image)
//      .disposed(by: disposeBag)
//    
//    // 로딩중
//    reactor.state
//      .map { $0.isLoading }
//      .withUnretained(self)
//      .bind { owner, isLoading in
//        if isLoading {
//          owner.loadingIndicator.startAnimating()
//          owner.view.isUserInteractionEnabled = false
//        } else {
//          owner.loadingIndicator.stopAnimating()
//          owner.view.isUserInteractionEnabled = true
//        }
//      }
//      .disposed(by: disposeBag)
//    
//    // MatchingBottomSheet Present
//    reactor.state
//      .map { $0.isOpenedBottomSheet }
//      .filter { $0 }
//      .withUnretained(self)
//      .bind {
//        let bottomSheet = MatchingBottomSheet()
//        $0.0.presentPanModal(bottomSheet)
//      }
//      .disposed(by: disposeBag)
//    
//    // TopRoundedBackgroundView 좋아요 반응
//    reactor.state
//      .map { $0.isGreenBackgroundColor }
//      .filter { $0 }
//      .withUnretained(self)
//      .bind { owner, _ in
//        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
//          owner.topRoundedBackgroundView.tintColor = .idorm_green
//        }) { isFinished in
//          UIView.animate(withDuration: 0.2, delay: 0) {
//            owner.topRoundedBackgroundView.tintColor = .idorm_blue
//          }
//        }
//      }
//      .disposed(by: disposeBag)
//    
//    // TopRoundedBackgroundView 싫어요 반응
//    reactor.state
//      .map { $0.isRedBackgroundColor }
//      .filter { $0 }
//      .withUnretained(self)
//      .bind { owner, _ in
//        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
//          owner.topRoundedBackgroundView.tintColor = .idorm_red
//        }) { isFinished in
//          UIView.animate(withDuration: 0.2, delay: 0) {
//            owner.topRoundedBackgroundView.tintColor = .idorm_blue
//          }
//        }
//      }
//      .disposed(by: disposeBag)
  }
}

// MARK: - Privates

private extension MatchingMateViewController {
  func navigateToMatchingInfoSetupVC() {
    let viewController = MatchingInfoSetupViewController()
    let reactor = MatchingInfoSetupViewReactor(.theFirstTime)
    viewController.reactor = reactor
    self.navigationController?.pushViewController(viewController, animated: true)
  }
}

// MARK: - KolodaView

extension MatchingMateViewController: KolodaViewDataSource, KolodaViewDelegate {
  // 카드 생성
  func koloda(_ koloda: Koloda.KolodaView, viewForCardAt index: Int) -> UIView {
    guard let mates = self.reactor?.currentState.mates else { return .init() }
    let cardView = iDormMatchingCardView(mates[index])
    cardView.optionButtonHandler = { $0 }
    return cardView
  }
  
  // 카드 갯수
  func kolodaNumberOfCards(_ koloda: Koloda.KolodaView) -> Int {
    guard let mates = self.reactor?.currentState.mates else { return 0 }
    return mates.count
  }
  
  // 카드 조회 애니메이션 유무
  func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool {
    return false
  }
  
  // 다음 카드 투명화 유무
  func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
    return true
  }
  
  // 카드 스와이프 종료
  func koloda(
    _ koloda: KolodaView,
    didSwipeCardAt index: Int,
    in direction: SwipeResultDirection
  ) {
    guard let identifier = self.reactor?.currentState.mates[index].identifier else { return }
    switch direction {
    case .left:
      self.reactor?.action.onNext(.dislike(identifier: identifier))
    case .right:
      self.reactor?.action.onNext(.like(identifier: identifier))
    default:
      break
    }
    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
      self.topCornerView.tintColor = .iDormColor(.iDormBlue)
    }
  }
  
  // 카드 드래그 시작
  func koloda(
    _ koloda: KolodaView,
    draggedCardWithPercentage finishPercentage: CGFloat,
    in direction: SwipeResultDirection
  ) {
    switch direction {
    case .left:
      UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
        self.topCornerView.tintColor = .iDormColor(.iDormRed)
      }
    case .right:
      UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
        self.topCornerView.tintColor = .iDormColor(.iDormGreen)
      }
    default: break
    }
  }
  
  // 카드 드래그 종료
  func kolodaPanFinished(_ koloda: KolodaView, card: DraggableCardView) {
    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
      self.topCornerView.tintColor = .iDormColor(.iDormBlue)
    }
  }
}
