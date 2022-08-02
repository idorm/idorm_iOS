//
//  MatchingViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/23.
//

import SnapKit
import UIKit
import RxSwift
import Shuffle_iOS

class MatchingViewController: UIViewController {
  // MARK: - Properties
  let myInfo = MyInfo(dormNumber: .no1, period: .period_16, gender: .female, age: "21", snoring: true, grinding: false, smoke: true, allowedFood: false, earphone: true, wakeupTime: "8시", cleanUpStatus: "33", showerTime: "33", mbti: "ISFJ", wishText: "하고싶은 말입니다.", chatLink: nil)
  
  lazy var filterButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    config.image = UIImage(named: "filter(Matching)")
    let button = UIButton(configuration: config)
    
    return button
  }()
  
  lazy var backwardButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.image = UIImage(named: "backward(Matching)")
    config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    let button = UIButton(configuration: config)
    
    return button
  }()
  
  lazy var infoView: MyInfoView = {
    let infoView = MyInfoView()
    infoView.configureUI(myinfo: myInfo)

    return infoView
  }()
  
  lazy var cardStack: SwipeCardStack = {
    let cardStack = SwipeCardStack()
    cardStack.cardStackInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    cardStack.dataSource = self
    cardStack.delegate = self
    
    return cardStack
  }()

  lazy var topRoundedBackgroundView = UIImageView(image: UIImage(named: "topRoundedBackground(Matching)"))
  let noMatchingImageView = UIImageView(image: UIImage(named: "noMatchingLabel(Matching)"))
  lazy var cancelButton = createButton(imageName: "cancel")
  lazy var messageButton = createButton(imageName: "message")
  lazy var heartButton = createButton(imageName: "heart")
  
  let disposeBag = DisposeBag()
  
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
    filterButton.rx.tap
      .bind(onNext: { [weak self] in
        let matchingFilterVC = MatchingFilterViewController()
        self?.navigationController?.pushViewController(matchingFilterVC, animated: true)
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: - Helpers
  private func configureUI() {
    view.backgroundColor = .white
    
    let buttonStack = UIStackView(arrangedSubviews: [ cancelButton, messageButton, heartButton ])
    buttonStack.spacing = 24
    
    [ buttonStack, topRoundedBackgroundView, noMatchingImageView, backwardButton, cardStack, filterButton ]
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
    
    cardStack.snp.makeConstraints { make in
      make.top.equalTo(backwardButton.snp.bottom).offset(12)
      make.leading.trailing.equalToSuperview().inset(24)
      make.bottom.equalTo(buttonStack.snp.top).offset(-28)
    }
    
    buttonStack.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
    }
    
    backwardButton.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(view.safeAreaLayoutGuide).inset(16)
    }
  }
}

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
  
  func createCard(from infoView: MyInfoView) -> SwipeCard {
    infoView.snp.makeConstraints { make in
      make.width.equalTo(view.frame.width - 48)
    }
    
    let card = SwipeCard()
    card.swipeDirections = [.left, .right]
    card.content = infoView
    
    let leftOverlay = UIView()
    leftOverlay.backgroundColor = .green
    
    let rightOverlay = UIView()
    rightOverlay.backgroundColor = .red
    
    card.setOverlays([.left: leftOverlay, .right: rightOverlay])
    
    return card
  }
}

extension MatchingViewController: SwipeCardStackDataSource, SwipeCardStackDelegate {
  func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
    let cardImages = [ infoView, infoView, infoView ]
    return createCard(from: cardImages[index])
  }
  
  func numberOfCards(in cardStack: SwipeCardStack) -> Int {
    return 3
  }
}
