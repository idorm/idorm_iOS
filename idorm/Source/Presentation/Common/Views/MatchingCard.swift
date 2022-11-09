import UIKit

import SnapKit
import Then
import RxSwift
import RxCocoa

final class MatchingCard: UIView {
  
  // MARK: - Properties
  
  private lazy var backgroundImageView = UIImageView().then {
    $0.image = UIImage(
      named: "OnboardingBackGround"
    )?.withRenderingMode(.alwaysOriginal)
    $0.contentMode = .scaleToFill
  }
  
  private lazy var dormLabel = UILabel().then {
    $0.font = .init(name: MyFonts.bold.rawValue, size: 20)
    $0.text = matchingInfo.dormNumber.cardString
    $0.textColor = .white
  }
  
  private lazy var periodButton = UIButton().then {
    var config = UIButton.Configuration.plain()
    var container = AttributeContainer()
    container.font = UIFont.init(name: MyFonts.bold.rawValue, size: 12)
    container.foregroundColor = UIColor.white
    config.attributedTitle = AttributedString(matchingInfo.period.cardString, attributes: container)
    config.image = UIImage(named: "Building")
    config.imagePlacement = .leading
    config.imagePadding = 8
    $0.configuration = config
  }
  
  private let matchingInfo: MatchingInfo
  
  private var snoreLabel: UIView!
  private var grindingLabel: UIView!
  private var smokingLabel: UIView!
  private var allowedFoodLabel: UIView!
  private var allowedEarphoneLabel: UIView!
  
  private var wakeupTimeLabel: UIView!
  private var cleanupLabel: UIView!
  private var showerTimeLabel: UIView!
  private var mbtiLabel: UIView!
  
  private var wishTextLabel: UIView!
  
  private var bottomView: MatchingCardBottomView!
  
  // MARK: - LifeCycle
  
  init(myInfo: MatchingInfo) {
    self.matchingInfo = myInfo
    super.init(frame: .zero)
    setupComponents()
    setupLayouts()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  private func setupComponents() {
    let snoreLabel = createBoolComponent(query: "코골이")
    let grindingLabel = createBoolComponent(query: "이갈이")
    let smokingLabel = createBoolComponent(query: "흡연")
    let allowedFoodLabel = createBoolComponent(query: "실내음식")
    let allowedEarphoneLabel = createBoolComponent(query: "이어폰 착용")
    
    let wakeupTimeLabel = createStringComponent(query: "기상시간")
    let cleanupLabel = createStringComponent(query: "정리정돈")
    let showerTimeLabel = createStringComponent(query: "샤워시간")
    let mbtiLabel = createStringComponent(query: "MBTI")
    
    let wishTextLabel = createWishTextLabel()
    let bottomView = MatchingCardBottomView(matchingInfo)
    
    self.snoreLabel = snoreLabel
    self.grindingLabel = grindingLabel
    self.smokingLabel = smokingLabel
    self.allowedFoodLabel = allowedFoodLabel
    self.allowedEarphoneLabel = allowedEarphoneLabel
    
    self.wakeupTimeLabel = wakeupTimeLabel
    self.cleanupLabel = cleanupLabel
    self.showerTimeLabel = showerTimeLabel
    self.mbtiLabel = mbtiLabel
    
    self.wishTextLabel = wishTextLabel
    self.bottomView = bottomView
  }
  
  private func setupLayouts() {
    [ backgroundImageView, bottomView ]
      .forEach { addSubview($0) }
    
    [ dormLabel, periodButton, snoreLabel, grindingLabel, smokingLabel, allowedFoodLabel, allowedEarphoneLabel, wakeupTimeLabel, cleanupLabel, showerTimeLabel, mbtiLabel, wishTextLabel ]
      .forEach { backgroundImageView.addSubview($0) }
  }
  
  private func setupConstraints() {
    backgroundImageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    bottomView.snp.makeConstraints { make in
      make.top.equalTo(backgroundImageView.snp.bottom)
      make.leading.trailing.equalTo(backgroundImageView)
      make.height.equalTo(40)
    }
    
    dormLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(10)
      make.leading.equalToSuperview().inset(14)
    }
    
    periodButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(14)
      make.centerY.equalTo(dormLabel)
    }
    
    snoreLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(14)
      make.top.equalTo(dormLabel.snp.bottom).offset(10)
    }
    
    grindingLabel.snp.makeConstraints { make in
      make.leading.equalTo(snoreLabel.snp.trailing).offset(7)
      make.centerY.equalTo(snoreLabel)
    }
    
    smokingLabel.snp.makeConstraints { make in
      make.leading.equalTo(grindingLabel.snp.trailing).offset(7)
      make.centerY.equalTo(snoreLabel)
    }
    
    allowedFoodLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(14)
      make.top.equalTo(snoreLabel.snp.bottom).offset(8)
    }
    
    allowedEarphoneLabel.snp.makeConstraints { make in
      make.leading.equalTo(allowedFoodLabel.snp.trailing).offset(7)
      make.centerY.equalTo(allowedFoodLabel)
    }
    
    wakeupTimeLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(14)
      make.top.equalTo(allowedFoodLabel.snp.bottom).offset(10)
    }
    
    cleanupLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(14)
      make.top.equalTo(wakeupTimeLabel.snp.bottom).offset(8)
    }
    
    showerTimeLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(14)
      make.top.equalTo(cleanupLabel.snp.bottom).offset(8)
    }
  
    mbtiLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(14)
      make.top.equalTo(showerTimeLabel.snp.bottom).offset(8)
    }
    
    wishTextLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(14)
      make.top.equalTo(mbtiLabel.snp.bottom).offset(10)
      make.height.equalTo(104)
    }
  }
}

// MARK: - Create UI Components

extension MatchingCard {
  private func createBoolComponent(query: String) -> UIView {
    let view = UIView()
    view.backgroundColor = .white
    view.layer.cornerRadius = 15
    view.layer.shadowOffset = CGSize(width: 0, height: 5)
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOpacity = 0.2
    
    let queryLabel = UILabel()
    queryLabel.text = query
    queryLabel.textColor = .black
    queryLabel.font = .init(name: MyFonts.medium.rawValue, size: 14)
    
    let validLabel = UILabel()
    validLabel.font = .init(name: MyFonts.bold.rawValue, size: 14)
    
    if query == "코골이" {
      validLabel.textColor = matchingInfo.snoring ? UIColor.red : UIColor.idorm_blue
      validLabel.text = matchingInfo.snoring ? "있음" : "없음"
    } else if query == "이갈이" {
      validLabel.textColor = matchingInfo.grinding ? UIColor.red : UIColor.idorm_blue
      validLabel.text = matchingInfo.grinding ? "있음" : "없음"
    } else if query == "흡연" {
      validLabel.textColor = matchingInfo.smoke ? UIColor.red : UIColor.idorm_blue
      validLabel.text = matchingInfo.smoke ? "함" : "안함"
    } else if query == "실내음식" {
      validLabel.textColor = matchingInfo.allowedFood ? UIColor.idorm_blue : UIColor.red
      validLabel.text = matchingInfo.allowedFood ? "가능" : "불가능"
    } else {
      validLabel.textColor = matchingInfo.earphone ? UIColor.idorm_blue : UIColor.red
      validLabel.text = matchingInfo.earphone ? "가능" : "불가능"
    }
    
    let stack = UIStackView(arrangedSubviews: [ queryLabel, validLabel ])
    stack.axis = .horizontal
    stack.alignment = .center
    stack.spacing = 4
    
    view.addSubview(stack)
    
    view.snp.makeConstraints { make in
      make.height.equalTo(29)
    }
    
    stack.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(10)
      make.centerY.equalToSuperview()
    }
    
    return view
  }
  
  private func createStringComponent(query: String) -> UIView {
    let view = UIView()
    view.layer.cornerRadius = 12
    view.backgroundColor = .white
    view.layer.shadowOffset = CGSize(width: 0, height: 5)
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOpacity = 0.2
    
    let queryLabel = UILabel()
    queryLabel.text = query
    queryLabel.textColor = .black
    queryLabel.font = .init(name: MyFonts.bold.rawValue, size: 14)
    queryLabel.setContentCompressionResistancePriority(.init(751), for: .horizontal)
    
    let contentsLabel = UILabel()
    contentsLabel.font = .init(name: MyFonts.medium.rawValue, size: 14)
    contentsLabel.textColor = .idorm_gray_400
    
    if query == "기상시간" {
      contentsLabel.text = matchingInfo.wakeupTime
    } else if query == "정리정돈" {
      contentsLabel.text = matchingInfo.cleanUpStatus
    } else if query == "샤워시간" {
      contentsLabel.text = matchingInfo.showerTime
    } else if query == "MBTI" {
      contentsLabel.text = matchingInfo.mbti
    }
    
    let stack = UIStackView(arrangedSubviews: [ queryLabel, contentsLabel ])
    stack.axis = .horizontal
    stack.spacing = 6
    stack.alignment = .leading
    
    view.addSubview(stack)
    
    view.snp.makeConstraints { make in
      make.height.equalTo(29)
    }
    
    stack.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(10)
      make.centerY.equalToSuperview()
    }
    
    return view
  }
  
  private func createWishTextLabel() -> UIView {
    let view = UIView()
    view.layer.cornerRadius = 6
    view.backgroundColor = .white
    
    let contentsLabel = UILabel()
    contentsLabel.font = .init(name: MyFonts.medium.rawValue, size: 14)
    contentsLabel.text = matchingInfo.wishText
    contentsLabel.textColor = .idorm_gray_400
    contentsLabel.numberOfLines = 0
    contentsLabel.textAlignment = .left
    
    view.addSubview(contentsLabel)
    
    view.snp.makeConstraints { make in
      make.height.equalTo(104)
    }
    
    contentsLabel.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(10)
    }
    
    return view
  }
}
