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
        self.reactor?.action.onNext(
          .speechBubbleButtonDidTap(index: self.cardStackView.currentCardIndex)
        )
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
    
    navigationController?.setNavigationBarHidden(true, animated: false)
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
      make.directionalHorizontalEdges.equalToSuperview().inset(24.0)
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
    
    self.filterButton.rx.tap
      .map { Reactor.Action.filterButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    UserStorage.shared.matchingMateFilter
      .map { _ in Reactor.Action.matchingInfofilterDidChange }
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
      .debug()
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
    
    reactor.pulse(\.$navigateToMatchingInfoSetupVC).skip(1)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        let viewController = MatchingInfoSetupViewController()
        let reactor = MatchingInfoSetupViewReactor(.theFirstTime)
        viewController.reactor = reactor
        owner.navigationController?.pushViewController(viewController, animated: true)
      }
      .disposed(by: self.disposeBag)
    
    reactor.pulse(\.$navigateToMatchingInfoFilterSetupVC).skip(1)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        let viewController = MatchingInfoFilterSetupViewController()
        let reactor = MatchingInfoFilterSetupViewReactor()
        viewController.reactor = reactor
        owner.navigationController?.pushViewController(viewController, animated: true)
      }
      .disposed(by: self.disposeBag)
  }
}

// MARK: - KolodaView

extension MatchingMateViewController: KolodaViewDataSource, KolodaViewDelegate {
  // 카드 생성
  func koloda(_ koloda: Koloda.KolodaView, viewForCardAt index: Int) -> UIView {
    guard let mates = self.reactor?.currentState.mates else { return .init() }
    let cardView = iDormMatchingCardView(mates[index])
    cardView.optionButtonHandler = { _ in self.reactor?.action.onNext(.optionButtonDidTap) }
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
