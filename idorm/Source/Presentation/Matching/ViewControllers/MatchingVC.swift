import UIKit

import PanModal
import SnapKit
import RxSwift
import RxCocoa
import DeviceKit
import Then
import Shuffle_iOS

class MatchingViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let filterButton = UIButton().then {
    var config = UIButton.Configuration.plain()
    config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    config.image = UIImage(named: "filter(Matching)")
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
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    // MARK: - Input
    
    // 자신의 공유 상태 업데이트
    MemberInfoStorage.instance.isPublicMatchingInfoObserver
      .distinctUntilChanged()
      .compactMap { $0 }
      .bind(to: viewModel.input.updatePublicState)
      .disposed(by: disposeBag)

    // 화면 최초 접근
    Observable.just(Void())
      .delay(.microseconds(10000), scheduler: MainScheduler.instance)
      .bind(to: viewModel.input.viewDidLoad)
      .disposed(by: disposeBag)
    
    // 필터버튼 클릭
    filterButton.rx.tap
      .bind(to: viewModel.input.filterButtonDidTap)
      .disposed(by: disposeBag)
    
    // 취소버튼 클릭
    cancelButton.rx.tap
      .throttle(.seconds(1), scheduler: MainScheduler.instance)
      .map { [unowned self] in
        cardStack.swipe(.left, animated: true)
      }
      .bind(to: viewModel.input.cancelButtonDidTap)
      .disposed(by: disposeBag)
    
    // 메세지버튼 클릭
    messageButton.rx.tap
//      .filter { [weak self] in
//        guard let self = self else { return }
//        return self.cardStack.topCardIndex != nil
//      }
      .bind(to: viewModel.input.messageButtonDidTap)
      .disposed(by: disposeBag)
    
    // 하트버튼 클릭
    heartButton.rx.tap
      .throttle(.seconds(1), scheduler: MainScheduler.instance)
      .map { [weak self] in
        self?.cardStack.swipe(.right, animated: true)
      }
      .bind(to: viewModel.input.heartButtonDidTap)
      .disposed(by: disposeBag)
    
    // 백버튼 클릭
    backButton.rx.tap
      .throttle(.seconds(1), scheduler: MainScheduler.instance)
      .map { [unowned self] in
        cardStack.undoLastSwipe(animated: true)
      }
      .bind(to: viewModel.input.backButtonDidTap)
      .disposed(by: disposeBag)
    
    // MARK: - Output
    
    // 백그라운드 컬러 기본 컬러로 다시 바꾸기
    viewModel.output.drawBackTopBackgroundColor
      .bind(onNext: { [weak self] in
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
          self?.topRoundedBackgroundView.tintColor = .idorm_blue
        }
      })
      .disposed(by: disposeBag)
    
    // 백그라운드 컬러 변경 감지
    viewModel.output.onChangedTopBackgroundColor
      .bind(onNext: { [weak self] direction in
        guard let self = self else { return }
        switch direction {
        case .cancel:
          UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.topRoundedBackgroundView.tintColor = .idorm_red
          })
        case .heart:
          UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.topRoundedBackgroundView.tintColor = .idorm_green
          })
        }
      })
      .disposed(by: disposeBag)
    
    // FilterVC 보여주기
    viewModel.output.pushToFilterVC
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        let viewController = MatchingFilterViewController()
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
        
        // 선택 초기화 -> POP 필터VC -> 카드 다시 요청
        viewController.viewModel.output.requestCards
          .bind(to: self.viewModel.input.resetFilterButtonDidTap)
          .disposed(by: self.disposeBag)

        // 필터링 완료 -> POP 필터VC -> 필터링 카드 요청
        viewController.viewModel.output.requestFilteredCards
          .bind(to: self.viewModel.input.confirmFilterButtonDidTap)
          .disposed(by: self.disposeBag)
      })
      .disposed(by: disposeBag)
    
    // 백그라운드 컬러 감지 (터치할 때)
    viewModel.output.onChangedTopBackgroundColor_WithTouch
      .bind(onNext: { [weak self] type in
        switch type {
        case .heart:
          UIView.animate(withDuration: 0.2, animations: {
            self?.topRoundedBackgroundView.tintColor = .idorm_green
          }) { isFinished in
            if isFinished {
              UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
                self?.topRoundedBackgroundView.tintColor = .idorm_blue
              }
            }
          }
        case .cancel:
          UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self?.topRoundedBackgroundView.tintColor = .idorm_red
          }) { isFinished in
            if isFinished {
              UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
                self?.topRoundedBackgroundView.tintColor = .idorm_blue
              }
            }
          }
        }
      })
      .disposed(by: disposeBag)
    
    // 프로필 이미지 만들기 팝업 창 띄우기
    viewModel.output.presentFirstPopupVC
      .bind(onNext: { [weak self] in
        self?.informationImageView.image = UIImage(named: "noMatchingInfomation")
        let matchingPopupVC = MatchingPopupViewController()
        matchingPopupVC.modalPresentationStyle = .overFullScreen
        self?.present(matchingPopupVC, animated: false)
      })
      .disposed(by: disposeBag)
    
    // 카드 스택 뷰 리로드
    viewModel.output.reloadCardStack
      .bind(onNext: { [weak self] in
        self?.cardStack.reloadData()
      })
      .disposed(by: disposeBag)
    
    // 인디케이터 제어
    viewModel.output.indicatorState
      .bind(onNext: { [weak self] in
        if $0 {
          self?.loadingIndicator.startAnimating()
          self?.view.isUserInteractionEnabled = false
        } else {
          self?.loadingIndicator.stopAnimating()
          self?.view.isUserInteractionEnabled = true
        }
      })
      .disposed(by: disposeBag)

    // 매칭 이미지 뷰 변경
    viewModel.output.informationImageViewStatus
      .bind(onNext: { [unowned self] type in
        let imageName = type.imageName
        self.informationImageView.image = UIImage(named: imageName)
      })
      .disposed(by: disposeBag)
    
    // 매칭 공개 여부 팝업 띄우기
    viewModel.output.presentNoSharePopupVC
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        
        let popupVC = MatchingNoSharePopUpViewController()
        popupVC.modalPresentationStyle = .overFullScreen
        self.present(popupVC, animated: false)
        
        // 공개 허용 버튼 클릭
        popupVC.confirmLabel.rx.tapGesture()
          .skip(1)
          .map { _ in Void() }
          .bind(to: self.viewModel.input.publicButtonDidTap)
          .disposed(by: self.disposeBag)
        
        // 팝업창 닫기
        self.viewModel.output.dismissNoSharePopupVC
          .bind(onNext: {
            popupVC.dismiss(animated: false)
          })
          .disposed(by: self.disposeBag)
      })
      .disposed(by: disposeBag)
    
    // 카카오 링크 페이지 띄우기
    viewModel.output.presentKakaoPopupVC
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        let viewController = KakaoLinkViewController()
        viewController.modalPresentationStyle = .overFullScreen
        self.present(viewController, animated: false)
        
        // 오픈채팅 링크 바로 가기 버튼 클릭
        viewController.kakaoButton.rx.tap
          .bind(to: self.viewModel.input.kakaoLinkButtonDidTap)
          .disposed(by: self.disposeBag)
        
        // KakaoLinkVC 닫기
        self.viewModel.output.dismissKakaoLinkVC
          .bind(onNext: {
            viewController.dismiss(animated: false)
          })
          .disposed(by: self.disposeBag)
      })
      .disposed(by: disposeBag)
    
    // 카카오 링크 사파리로 열기
    viewModel.output.presentSafari
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        if let index = self.cardStack.topCardIndex {
          let url = self.viewModel.state.matchingMembers.value[index].openKakaoLink
          UIApplication.shared.open(URL(string: url)!)
        }
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: - Setup
  
  override func setupLayouts() {
    super.setupLayouts()
    [topRoundedBackgroundView, buttonStack, filterButton, informationImageView, cardStack, loadingIndicator]
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
    return card(from: viewModel.state.matchingMembers.value[index])
  }
  
  func numberOfCards(in cardStack: Shuffle_iOS.SwipeCardStack) -> Int {
    return viewModel.state.matchingMembers.value.count
  }
  
  func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
    let card = viewModel.state.matchingMembers.value[index]
    let memberId = card.memberId
    switch direction {
    case .left: viewModel.state.addDislikeAPI.onNext(memberId)
    case .right: viewModel.state.addlikeAPI.onNext(memberId)
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
