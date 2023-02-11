import UIKit

import SnapKit
import Then
import RxSwift
import RxCocoa

final class MatchingCard: UIView {
  
  // MARK: - Properties
  
  private let backgroundImageView = UIImageView().then {
    $0.image = UIImage(
      named: "background_card"
    )?.withRenderingMode(.alwaysOriginal)
    $0.contentMode = .scaleToFill
  }
  
  private lazy var dormLabel = UILabel().then {
    $0.font = .init(name: MyFonts.bold.rawValue, size: 20)
    $0.text = member.dormCategory.cardString
    $0.textColor = .white
  }
  
  private lazy var periodButton = UIButton().then {
    var config = UIButton.Configuration.plain()
    var container = AttributeContainer()
    container.font = UIFont.init(name: MyFonts.bold.rawValue, size: 12)
    container.foregroundColor = UIColor.white
    config.attributedTitle = AttributedString(member.joinPeriod.cardString, attributes: container)
    config.image = UIImage(named: "building")
    config.imagePlacement = .leading
    config.imagePadding = 8
    $0.configuration = config
  }
  
  private lazy var snoringView = MatchingCardBoolView(member, type: .snoring)
  private lazy var grindingView = MatchingCardBoolView(member, type: .grinding)
  private lazy var smokingView = MatchingCardBoolView(member, type: .smoking)
  private lazy var foodView = MatchingCardBoolView(member, type: .food)
  private lazy var earphoneView = MatchingCardBoolView(member, type: .earphone)
  private lazy var wakeupView = MatchingCardStringView(member, type: .wakeUp)
  private lazy var cleanUpView = MatchingCardStringView(member, type: .cleanUp)
  private lazy var showerView = MatchingCardStringView(member, type: .showerTime)
  private lazy var mbtiView = MatchingCardStringView(member, type: .mbti)
  private lazy var wishTextLabel = MatchingCardWishTextView(member)
  private var bottomContainerView: UIView!
  private let humanImageView = UIImageView(image: #imageLiteral(resourceName: "human_white"))
  var optionButton: UIButton!
  private var genderLabel: UILabel!
  private var ageLabel: UILabel!
  private var mbtiLabel: UILabel!
  private let member: MatchingResponseModel.Member
  
  // MARK: - LifeCycle
  
  init(_ member: MatchingResponseModel.Member) {
    self.member = member
    super.init(frame: .zero)
    setupBottomView()
    setupLayouts()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  private func setupBottomView() {
    let containerView = UIView()
    containerView.backgroundColor = .white
    containerView.layer.borderColor = UIColor.idorm_gray_200.cgColor
    containerView.layer.borderWidth = 1
    self.bottomContainerView = containerView
    
    let optionButton = UIButton().then {
      var config = UIButton.Configuration.plain()
      config.image = UIImage(named: "option")
      $0.configuration = config
    }
    self.optionButton = optionButton

    let genderLabel = UILabel().then {
      $0.text = member.gender == .male ? "남자," : "여자,"
      $0.textColor = .idorm_gray_400
      $0.font = .init(name: MyFonts.bold.rawValue, size: 12)
    }
    self.genderLabel = genderLabel
    
    let ageLabel = UILabel().then {
      $0.text = String(member.age) + " 세"
      $0.textColor = .idorm_gray_400
      $0.font = .init(name: MyFonts.bold.rawValue, size: 12)
    }
    self.ageLabel = ageLabel
    
    let mbtiLabel = UILabel().then {
      $0.text = member.mbti
      $0.textColor = .idorm_gray_300
      $0.font = .init(name: MyFonts.bold.rawValue, size: 12)
    }
    self.mbtiLabel = mbtiLabel
  }
  
  private func setupLayouts() {
    [
      backgroundImageView,
      bottomContainerView
    ]
      .forEach { addSubview($0) }
    
    [
      humanImageView,
      genderLabel,
      ageLabel,
      mbtiLabel,
      optionButton
    ]
      .forEach { bottomContainerView.addSubview($0) }
    
    [
      dormLabel,
      periodButton,
      snoringView,
      grindingView,
      smokingView,
      foodView,
      earphoneView,
      wakeupView,
      cleanUpView,
      showerView,
      mbtiView,
      wishTextLabel
    ]
      .forEach { backgroundImageView.addSubview($0) }
  }
  
  private func setupConstraints() {
    backgroundImageView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
    }
    
    dormLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(10)
      make.leading.equalToSuperview().inset(14)
    }
    
    periodButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(14)
      make.centerY.equalTo(dormLabel)
    }
    
    snoringView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(14)
      make.top.equalTo(dormLabel.snp.bottom).offset(10)
      make.height.equalTo(29)
    }
    
    grindingView.snp.makeConstraints { make in
      make.leading.equalTo(snoringView.snp.trailing).offset(7)
      make.centerY.equalTo(snoringView)
      make.height.equalTo(29)
    }
    
    smokingView.snp.makeConstraints { make in
      make.leading.equalTo(grindingView.snp.trailing).offset(7)
      make.centerY.equalTo(snoringView)
      make.height.equalTo(29)
    }
    
    foodView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(14)
      make.top.equalTo(snoringView.snp.bottom).offset(8)
      make.height.equalTo(29)
    }
    
    earphoneView.snp.makeConstraints { make in
      make.leading.equalTo(foodView.snp.trailing).offset(7)
      make.centerY.equalTo(foodView)
      make.height.equalTo(29)
    }
    
    wakeupView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(14)
      make.top.equalTo(foodView.snp.bottom).offset(10)
      make.height.equalTo(29)
    }
    
    cleanUpView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(14)
      make.top.equalTo(wakeupView.snp.bottom).offset(8)
      make.height.equalTo(29)
    }
    
    showerView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(14)
      make.top.equalTo(cleanUpView.snp.bottom).offset(8)
      make.height.equalTo(29)
    }
  
    mbtiView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(14)
      make.top.equalTo(showerView.snp.bottom).offset(8)
      make.height.equalTo(29)
    }
    
    wishTextLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(14)
      make.top.equalTo(mbtiView.snp.bottom).offset(10)
      make.height.equalTo(104)
    }
    
    bottomContainerView.snp.makeConstraints { make in
      make.leading.trailing.equalTo(backgroundImageView)
      make.top.equalTo(backgroundImageView.snp.bottom)
      make.bottom.equalToSuperview()
    }
    
    humanImageView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview().inset(12)
    }
    
    genderLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalTo(humanImageView.snp.trailing).offset(8)
    }
    
    ageLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalTo(genderLabel.snp.trailing).offset(4)
    }
    
    optionButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(12)
      make.centerY.equalToSuperview()
    }
    
    mbtiLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.trailing.equalTo(optionButton.snp.leading).offset(-8)
    }
  }
}
