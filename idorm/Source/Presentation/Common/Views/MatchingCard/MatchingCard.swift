import UIKit

import SnapKit
import Then
import RxSwift
import RxCocoa

final class MatchingCard: UIView {
  
  // MARK: - Properties
  
  private let backgroundImageView = UIImageView().then {
    $0.image = UIImage(
      named: "OnboardingBackGround"
    )?.withRenderingMode(.alwaysOriginal)
    $0.contentMode = .scaleToFill
  }
  
  private lazy var dormLabel = UILabel().then {
    $0.font = .init(name: MyFonts.bold.rawValue, size: 20)
    $0.text = matchingMember.dormNum.cardString
    $0.textColor = .white
  }
  
  private lazy var periodButton = UIButton().then {
    var config = UIButton.Configuration.plain()
    var container = AttributeContainer()
    container.font = UIFont.init(name: MyFonts.bold.rawValue, size: 12)
    container.foregroundColor = UIColor.white
    config.attributedTitle = AttributedString(matchingMember.joinPeriod.cardString, attributes: container)
    config.image = UIImage(named: "Building")
    config.imagePlacement = .leading
    config.imagePadding = 8
    $0.configuration = config
  }
  
  private let matchingMember: MatchingMember
  
  private var snoringView: MatchingCardBoolView!
  private var grindingView: MatchingCardBoolView!
  private var smokingView: MatchingCardBoolView!
  private var foodView: MatchingCardBoolView!
  private var earphoneView: MatchingCardBoolView!
  
  private var wakeupView: MatchingCardStringView!
  private var cleanUpView: MatchingCardStringView!
  private var showerView: MatchingCardStringView!
  private var mbtiView: MatchingCardStringView!
  
  private var wishTextLabel: UIView!
  
  private var bottomView: MatchingCardBottomView!
  
  // MARK: - LifeCycle
  
  init(myInfo: MatchingMember) {
    self.matchingMember = myInfo
    super.init(frame: .zero)
    setupBoolView()
    setupStringView()
    setupComponents()
    setupLayouts()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  private func setupBoolView() {
    self.snoringView = MatchingCardBoolView(matchingMember, type: .snoring)
    self.grindingView = MatchingCardBoolView(matchingMember, type: .grinding)
    self.smokingView = MatchingCardBoolView(matchingMember, type: .smoking)
    self.foodView = MatchingCardBoolView(matchingMember, type: .food)
    self.earphoneView = MatchingCardBoolView(matchingMember, type: .earphone)
  }
  
  private func setupStringView() {
    self.wakeupView = MatchingCardStringView(matchingMember, type: .wakeUp)
    self.cleanUpView = MatchingCardStringView(matchingMember, type: .cleanUp)
    self.showerView = MatchingCardStringView(matchingMember, type: .showerTime)
    self.mbtiView = MatchingCardStringView(matchingMember, type: .mbti)
  }
  
  private func setupComponents() {
    let wishTextLabel = MatchingCardWishTextView(matchingMember)
    let bottomView = MatchingCardBottomView(matchingMember)
    
    self.wishTextLabel = wishTextLabel
    self.bottomView = bottomView
  }
  
  private func setupLayouts() {
    [backgroundImageView, bottomView]
      .forEach { addSubview($0) }
    
    [dormLabel, periodButton, snoringView, grindingView, smokingView, foodView, earphoneView, wakeupView, cleanUpView, showerView, mbtiView, wishTextLabel]
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
  }
}
