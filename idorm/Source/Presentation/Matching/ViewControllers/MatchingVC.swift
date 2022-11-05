import UIKit

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
  
  private let informationImageView = UIImageView()
  private let cancelButton = MatchingUtilities.matchingButton(imageName: "cancel")
  private let messageButton = MatchingUtilities.matchingButton(imageName: "message")
  private let heartButton = MatchingUtilities.matchingButton(imageName: "heart")
  private let backButton = MatchingUtilities.matchingButton(imageName: "back")
  private var buttonStack: UIStackView!
  
  private let cardStack = SwipeCardStack()
  private let viewModel = MatchingViewModel()
  private let loadingIndicator = UIActivityIndicatorView()
  
  // MARK: - LifeCycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.isHidden = true
    tabBarController?.tabBar.isHidden = false
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    cardStack.dataSource = self
    cardStack.delegate = self
    
    // 화면 접속 이벤트
    viewModel.input.viewDidLoadObserver.onNext(Void())
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    // MARK: - Input
    
    // 필터버튼 클릭
    filterButton.rx.tap
      .bind(to: viewModel.input.filterButtonObserver)
      .disposed(by: disposeBag)
    
    // 취소버튼 클릭
    cancelButton.rx.tap
      .throttle(.seconds(1), scheduler: MainScheduler.instance)
      .map { [unowned self] in
        cardStack.swipe(.left, animated: true)
      }
      .bind(to: viewModel.input.cancelButtonObserver)
      .disposed(by: disposeBag)
    
    // 하트버튼 클릭
    heartButton.rx.tap
      .throttle(.seconds(1), scheduler: MainScheduler.instance)
      .map { [unowned self] in
        cardStack.swipe(.right, animated: true)
      }
      .bind(to: viewModel.input.heartButtonObserver)
      .disposed(by: disposeBag)
    
    // 백버튼 클릭
    backButton.rx.tap
      .throttle(.seconds(1), scheduler: MainScheduler.instance)
      .map { [unowned self] in
        cardStack.undoLastSwipe(animated: true)
      }
      .bind(to: viewModel.input.backButtonObserver)
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
    viewModel.output.showFliterVC
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        let viewController = MatchingFilterViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
        
        // 선택 초기화 -> POP 필터VC -> 카드 다시 요청
        viewController.viewModel.output.requestCards
          .take(1)
          .bind(onNext: {
            self.viewModel.requestMatchingAPI()
          })
          .disposed(by: self.disposeBag)
        
        // 필터링 완료 -> POP 필터VC -> 필터링 카드 요청
        viewController.viewModel.output.requestFilteredCards
          .take(1)
          .bind(onNext: {
          })
          .disposed(by: self.disposeBag)
      })
      .disposed(by: disposeBag)
    
    // 백그라운드 컬러 감지 (터치할 때)
    viewModel.output.onChangedTopBackgroundColor_WithTouch
      .bind(onNext: { [weak self] type in
        switch type {
        case .heart:
          UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
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
    viewModel.output.showFirstPopupVC
      .bind(onNext: { [weak self] in
        self?.informationImageView.image = UIImage(named: "noMatchingInfomation")
        let matchingPopupVC = MatchingPopupViewController()
        matchingPopupVC.modalPresentationStyle = .overFullScreen
        self?.present(matchingPopupVC, animated: false)
      })
      .disposed(by: disposeBag)
    
    // 카드 스택 뷰 리로드
    viewModel.output.reloadCardStack
      .bind(onNext: { [unowned self] in
        self.cardStack.reloadData()
      })
      .disposed(by: disposeBag)
    
    // 로딩 시작
    viewModel.output.startLoading
      .bind(onNext: { [unowned self] in
        self.loadingIndicator.startAnimating()
      })
      .disposed(by: disposeBag)

    // 로딩 종료
    viewModel.output.stopLoading
      .bind(onNext: { [unowned self] in
        self.loadingIndicator.stopAnimating()
      })
      .disposed(by: disposeBag)
    
    // 매칭 이미지 뷰 변경
    viewModel.output.informationImageViewStatus
      .bind(onNext: { [unowned self] type in
        let imageName = type.imageName
        switch type {
        case .noMatchingCard:
          self.informationImageView.image = UIImage(named: imageName)
        case .noMatchingInformation:
          self.informationImageView.image = UIImage(named: imageName)
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
    let deviceManager = DeviceManager.shared
    
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
    
    if deviceManager.isFourIncheDevices() {
      cardStack.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalToSuperview()
        make.height.equalTo(420)
      }
      
      buttonStack.snp.makeConstraints { make in
        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(4)
        make.centerX.equalToSuperview()
      }
    } else if deviceManager.isFiveIncheDevices() {
      cardStack.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(filterButton.snp.bottom).offset(16)
        make.height.equalTo(420)
      }

      buttonStack.snp.makeConstraints { make in
        make.centerX.equalToSuperview()
        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(8)
      }
    } else if deviceManager.isFiveInchePlusDevices() {
      cardStack.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(filterButton.snp.bottom).offset(40)
        make.height.equalTo(400)
      }
      
      buttonStack.snp.makeConstraints { make in
        make.centerX.equalToSuperview()
        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(32)
      }
    } else if deviceManager.isXSeriesDevices_812() {
      buttonStack.spacing = 8
      
      cardStack.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(filterButton.snp.bottom).offset(40)
        make.height.equalTo(420)
      }

      buttonStack.snp.makeConstraints { make in
        make.centerX.equalToSuperview()
        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(40)
      }
    } else if deviceManager.isXSeriesDevices_844() {
      buttonStack.spacing = 8
      
      cardStack.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(filterButton.snp.bottom).offset(40)
        make.height.equalTo(420)
      }

      buttonStack.snp.makeConstraints { make in
        make.centerX.equalToSuperview()
        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(62)
      }
    } else if deviceManager.isXSeriesDevices_896() {
      buttonStack.spacing = 8
      
      cardStack.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(filterButton.snp.bottom).offset(40)
        make.height.equalTo(420)
      }

      buttonStack.snp.makeConstraints { make in
        make.centerX.equalToSuperview()
        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(80)
      }
    } else {
      buttonStack.spacing = 8
      
      cardStack.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(filterButton.snp.bottom).offset(40)
        make.height.equalTo(420)
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
  func card(from matchingMember: MatchingMember) -> SwipeCard {
    let matchingInfo = MatchingInfo(dormNumber: matchingMember.dormNum, period: matchingMember.joinPeriod, gender: matchingMember.gender, age: String(matchingMember.age), snoring: matchingMember.isSnoring, grinding: matchingMember.isGrinding, smoke: matchingMember.isSmoking, allowedFood: matchingMember.isAllowedFood, earphone: matchingMember.isWearEarphones, wakeupTime: matchingMember.wakeUpTime, cleanUpStatus: matchingMember.cleanUpStatus, showerTime: matchingMember.showerTime)

    let card = SwipeCard()
    card.swipeDirections = [.left, .right]
    card.content = MatchingCard(myInfo: matchingInfo)
    card.footerHeight = 0
    card.panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture))
    
    return card
  }
  
  func cardStack(_ cardStack: Shuffle_iOS.SwipeCardStack, cardForIndexAt index: Int) -> Shuffle_iOS.SwipeCard {
    return card(from: viewModel.output.matchingMembers.value[index])
  }
  
  func numberOfCards(in cardStack: Shuffle_iOS.SwipeCardStack) -> Int {
    return viewModel.output.matchingMembers.value.count
  }
  
  func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
    let card = viewModel.output.matchingMembers.value[index]
    let memberId = card.memberId
    switch direction {
    case .left: viewModel.input.dislikeMemberObserver.onNext(memberId)
    case .right: viewModel.input.likeMemberObserver.onNext(memberId)
    default: break
    }
  }
  
  @objc private func handlePanGesture(sender: UIPanGestureRecognizer) {
    let card = sender.view as! SwipeCard
    let velocity = sender.velocity(in: card)
    
    if abs(velocity.x) > abs(velocity.y) {
      if velocity.x < 0 {
        // 취소 스와이프 감지
        viewModel.input.swipeObserver.onNext(.cancel)
      } else {
        // 좋아요 스와이프 감지
        viewModel.input.swipeObserver.onNext(.heart)
      }
    }
    
    if sender.state == .ended {
      // 스와이프 종료 이벤트
      viewModel.input.didEndSwipeObserver.onNext(.none)
    }
  }
}

// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct MatchingVCPreView: PreviewProvider {
  static var previews: some View {
    MatchingViewController().toPreview()
  }
}
#endif
