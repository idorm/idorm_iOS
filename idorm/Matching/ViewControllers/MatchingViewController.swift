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
import CardSlider

struct Item: CardSliderItem {
  var image: UIImage
  var rating: Int?
  var title: String
  var subtitle: String?
  var description: String?
}

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

  lazy var topRoundedBackgroundView = UIImageView(image: UIImage(named: "topRoundedBackground(Matching)"))
  let noMatchingImageView = UIImageView(image: UIImage(named: "noMatchingLabel(Matching)"))
  lazy var cancelButton = createButton(imageName: "cancel")
  lazy var messageButton = createButton(imageName: "message")
  lazy var heartButton = createButton(imageName: "heart")
  
  // MARK: - LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.isHidden = true
  }
  
  // MARK: - Helpers
  private func configureUI() {
    view.backgroundColor = .white
    
    let infoView = MyInfoView()
    infoView.configureUI(myinfo: myInfo)
    
    let buttonStack = UIStackView(arrangedSubviews: [ cancelButton, messageButton, heartButton ])
    buttonStack.spacing = 24
    
    [ buttonStack, topRoundedBackgroundView, noMatchingImageView, filterButton, backwardButton ]
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
      make.centerX.equalToSuperview()
      make.bottom.equalTo(view.safeAreaLayoutGuide).inset(52)
    }
    
    backwardButton.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
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
}

// MARK: - CardSlider
extension MatchingViewController: CardSliderDataSource {
  func item(for index: Int) -> CardSliderItem {
    <#code#>
  }
  
  func numberOfItems() -> Int {
    <#code#>
  }
}
