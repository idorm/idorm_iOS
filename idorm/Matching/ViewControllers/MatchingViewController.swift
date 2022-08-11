//
//  MatchingViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/23.
//

import SnapKit
import UIKit
import RxSwift
import RxCocoa
import DeviceKit

class MatchingViewController: UIViewController {
  // MARK: - Properties
  let myInfo = MyInfo(dormNumber: .no1, period: .period_16, gender: .female, age: "21", snoring: true, grinding: false, smoke: true, allowedFood: false, earphone: true, wakeupTime: "8시", cleanUpStatus: "33", showerTime: "33", mbti: "ISFJ", wishText: "하고싶은 말입니다.", chatLink: nil)
  
  lazy var swipeDataModels = [ myInfo, myInfo, myInfo, myInfo, myInfo, myInfo ]
  
  lazy var filterButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    config.image = UIImage(named: "filter(Matching)")
    let button = UIButton(configuration: config)
    
    return button
  }()
  
  lazy var topRoundedBackgroundView = UIImageView(image: UIImage(named: "topRoundedBackground(Matching)")?.withRenderingMode(.alwaysTemplate))
  let noMatchingImageView = UIImageView(image: UIImage(named: "noMatchingLabel(Matching)"))
  lazy var cancelButton = createButton(imageName: "cancel")
  lazy var messageButton = createButton(imageName: "message")
  lazy var heartButton = createButton(imageName: "heart")
  lazy var backButton = createButton(imageName: "back")
  lazy var infoView = MyInfoView(myInfo: myInfo)
  
  var stackContainer: StackContainerView!
  let disposeBag = DisposeBag()
  let viewModel = MatchingViewModel()
  
  // MARK: - LifeCycle
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.isHidden = true
    tabBarController?.tabBar.isHidden = false
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    stackContainer.dataSource = self
    bind()
  }
  
  override func loadView() {
    super.loadView()
    stackContainer = StackContainerView(viewModel: viewModel)
    view.addSubview(stackContainer)
    configureUI()
  }
  
  // MARK: - Bind
  private func bind() {
    // --------------------------------
    //             IN PUT
    // --------------------------------

    // 필터버튼 클릭 ( 수정 해야 함 )
    filterButton.rx.tap
      .bind(to: viewModel.input.filterButtonObserver)
      .disposed(by: disposeBag)
    
    // 취소버튼 클릭
    cancelButton.rx.tap
      .asDriver()
      .throttle(.seconds(1))
      .drive(viewModel.input.cancelButtonObserver)
      .disposed(by: disposeBag)
    
    // 하트버튼 클릭
    heartButton.rx.tap
      .asDriver()
      .throttle(.seconds(1))
      .drive(viewModel.input.heartButtonObserver)
      .disposed(by: disposeBag)
    
    // 백버튼 클릭
    backButton.rx.tap
      .throttle(.seconds(1), scheduler: MainScheduler.instance)
      .bind(to: viewModel.input.backButtonObserver)
      .disposed(by: disposeBag)
    
    // --------------------------------
    //             OUT PUT
    // --------------------------------
    
    viewModel.output.drawBackTopBackgroundColor
      .bind(onNext: { [weak self] in
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
          self?.topRoundedBackgroundView.tintColor = .idorm_blue
        }
      })
      .disposed(by: disposeBag)
    
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
    
    // FilterViewController 보여주기
    viewModel.output.showFliterVC
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        let matchingFilterVC = MatchingFilterViewController()
        self.navigationController?.pushViewController(matchingFilterVC, animated: true)
      })
      .disposed(by: disposeBag)
    
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
  }
  
  // MARK: - Configuration
  private func configureUI() {
    view.backgroundColor = .white
    topRoundedBackgroundView.tintColor = .idorm_blue
    
    let buttonStack = UIStackView(arrangedSubviews: [ cancelButton, backButton, messageButton, heartButton ])
    buttonStack.spacing = 4
    
    [ topRoundedBackgroundView, buttonStack, filterButton, noMatchingImageView, stackContainer ]
      .forEach { view.addSubview($0) }
    
    topRoundedBackgroundView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
    }
    
    filterButton.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide).inset(16)
      make.trailing.equalToSuperview().inset(24)
    }
    
    noMatchingImageView.snp.makeConstraints { make in
      make.top.equalTo(topRoundedBackgroundView.snp.bottom).offset(100)
      make.centerX.equalToSuperview()
    }
    
    let deviceManager = DeviceManager.shared
    
    if deviceManager.isFourIncheDevices() {
      stackContainer.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(16)
        make.top.equalToSuperview()
        make.height.equalTo(400)
      }
      
      buttonStack.snp.makeConstraints { make in
        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(4)
        make.centerX.equalToSuperview()
      }
    } else if deviceManager.isFiveIncheDevices() {
      stackContainer.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(filterButton.snp.bottom).offset(16)
        make.height.equalTo(400)
      }

      buttonStack.snp.makeConstraints { make in
        make.centerX.equalToSuperview()
        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(8)
      }
    } else if deviceManager.isFiveInchePlusDevices() {
      stackContainer.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(32)
        make.top.equalTo(filterButton.snp.bottom).offset(40)
        make.height.equalTo(400)
      }
      
      buttonStack.snp.makeConstraints { make in
        make.centerX.equalToSuperview()
        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(32)
      }
    } else if deviceManager.isXSeriesDevices_812() {
      buttonStack.spacing = 8
      
      stackContainer.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(filterButton.snp.bottom).offset(40)
        make.height.equalTo(400)
      }

      buttonStack.snp.makeConstraints { make in
        make.centerX.equalToSuperview()
        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(40)
      }
    } else if deviceManager.isXSeriesDevices_844() {
      buttonStack.spacing = 8
      
      stackContainer.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(filterButton.snp.bottom).offset(40)
        make.height.equalTo(400)
      }

      buttonStack.snp.makeConstraints { make in
        make.centerX.equalToSuperview()
        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(62)
      }
    } else if deviceManager.isXSeriesDevices_896() {
      buttonStack.spacing = 8
      
      stackContainer.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(filterButton.snp.bottom).offset(40)
        make.height.equalTo(400)
      }

      buttonStack.snp.makeConstraints { make in
        make.centerX.equalToSuperview()
        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(80)
      }
    } else {
      buttonStack.spacing = 8
      
      stackContainer.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(42)
        make.top.equalTo(filterButton.snp.bottom).offset(40)
        make.height.equalTo(400)
      }

      buttonStack.snp.makeConstraints { make in
        make.centerX.equalToSuperview()
        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(100)
      }
    }
  }
}

// MARK: - 프로퍼티 만들기
extension MatchingViewController {
  func createButton(imageName: String) -> UIButton {
    var config = UIButton.Configuration.plain()
    let name = imageName + "(Matching)"
    let hoveredName = imageName + "Hover(Matching)"
    config.image = UIImage(named: name)
    config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    let button = UIButton(configuration: config)
    
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      switch button.state {
      case .highlighted:
        button.configuration?.image = UIImage(named: hoveredName)
      default:
        button.configuration?.image = UIImage(named: name)
      }
    }
    button.configurationUpdateHandler = handler
    
    return button
  }
}

extension MatchingViewController: SwipeCardsDataSource {
  func numberOfCardsToShow() -> Int {
    return swipeDataModels.count
  }
  
  func emptyView() -> UIView? {
    return noMatchingImageView
  }
  
  func card(at index: Int) -> SwipeCardView {
    let card = SwipeCardView(myInfo: swipeDataModels[index], viewModel: viewModel)
    return card
  }
}
