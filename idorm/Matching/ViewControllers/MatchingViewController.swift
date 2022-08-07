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
  
  lazy var infoView: MyInfoView = {
    let infoView = MyInfoView()
    infoView.configureUI(myinfo: myInfo)

    return infoView
  }()
  
  lazy var topRoundedBackgroundView = UIImageView(image: UIImage(named: "topRoundedBackground(Matching)"))
  let noMatchingImageView = UIImageView(image: UIImage(named: "noMatchingLabel(Matching)"))
  lazy var cancelButton = createButton(imageName: "cancel")
  lazy var messageButton = createButton(imageName: "message")
  lazy var heartButton = createButton(imageName: "heart")
  lazy var backButton = createButton(imageName: "back")
  
  let disposeBag = DisposeBag()
  let viewModel = MatchingViewModel()
  
  // MARK: - LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bind()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.isHidden = true
    tabBarController?.tabBar.isHidden = false
  }
  
  // MARK: - Bind
  private func bind() {
    // 필터버튼 클릭
    filterButton.rx.tap
      .bind(onNext: { [weak self] in
        let matchingFilterVC = MatchingFilterViewController()
        self?.navigationController?.pushViewController(matchingFilterVC, animated: true)
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: - Configuration
  private func configureUI() {
    view.backgroundColor = .white
    
    let buttonStack = UIStackView(arrangedSubviews: [ cancelButton, backButton, messageButton, heartButton ])
    buttonStack.spacing = 4
    
    [ topRoundedBackgroundView, noMatchingImageView, buttonStack, filterButton ]
      .forEach { view.addSubview($0) }
    
    topRoundedBackgroundView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
    }
    
    filterButton.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide).inset(16)
      make.trailing.equalToSuperview().inset(24)
    }
    
    noMatchingImageView.snp.makeConstraints { make in
      make.centerX.centerY.equalToSuperview()
    }
    
    buttonStack.snp.makeConstraints { make in
      make.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide)
    }
    
//    infoView.snp.makeConstraints { make in
//      make.center.equalToSuperview()
//    }
    
    let deviceManager = DeviceManager.shared
    
//    if deviceManager.isFourIncheDevices() {
//      cardStack.snp.makeConstraints { make in
//        make.top.equalToSuperview().inset(4)
//        make.leading.trailing.equalToSuperview().inset(12)
//        make.bottom.equalTo(buttonStack.snp.top).offset(-4)
//      }
//
//      buttonStack.snp.makeConstraints { make in
//        make.centerX.equalToSuperview()
//        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(4)
//      }
//    } else if deviceManager.isFiveIncheDevices() {
//      cardStack.snp.makeConstraints { make in
//        make.top.equalTo(filterButton.snp.bottom).offset(4)
//        make.leading.trailing.equalToSuperview().inset(24)
//        make.height.equalTo(400)
//      }
//
//      buttonStack.snp.makeConstraints { make in
//        make.centerX.equalToSuperview()
//        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(4)
//      }
//    } else if deviceManager.isFiveInchePlusDevices() {
//
//    } else if deviceManager.isXSeriesDevices() {
//
//    } else {
//      cardStack.snp.makeConstraints { make in
//        make.centerY.equalToSuperview().offset(-120)
//        make.leading.trailing.equalToSuperview().inset(24)
//      }
//
//      buttonStack.snp.makeConstraints { make in
//        make.centerX.equalToSuperview()
//        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(62)
//      }
//    }
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
    return nil
  }
  
  func card(at index: Int) -> SwipeCardView {
    let card = SwipeCardView()
    card.dataSource = swipeDataModels[index]
    return card
  }
}
