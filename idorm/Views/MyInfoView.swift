//
//  InfoView.swift
//  idorm
//
//  Created by 김응철 on 2022/07/23.
//

import SnapKit
import UIKit

class MyInfoView: UIView {
  // MARK: - Properties
  var myInfo: MyInfo?
  
  lazy var backgroundImageView: UIImageView = {
    let iv = UIImageView()
    iv.image = UIImage(named: "OnboardingBackGround")?.withRenderingMode(.alwaysOriginal)
    iv.contentMode = .scaleToFill
    
    return iv
  }()
  
  lazy var dormLabel: UILabel = {
    let label = UILabel()
    label.font = .init(name: Font.bold.rawValue, size: 24)
    label.text = "3 기숙사"
    label.textColor = .black
    
    return label
  }()
  
  lazy var periodButton: UIButton = {
    var config = UIButton.Configuration.plain()
    var container = AttributeContainer()
    container.font = UIFont.init(name: Font.bold.rawValue, size: 12)
    container.foregroundColor = UIColor.white
    config.attributedTitle = AttributedString(myInfo?.period ?? "", attributes: container)
    config.image = UIImage(named: "Building")
    config.imagePlacement = .leading
    config.imagePadding = 8
    let button = UIButton(configuration: config)
    
    return button
  }()
  
  // MARK: - LifeCycle
  
  // MARK: - Helpers
  func configureUI(myinfo: MyInfo) {
    self.myInfo = myinfo
    
    let snoreLabel = createBoolComponent(query: "코골이")
    let grindingLabel = createBoolComponent(query: "이갈이")
    let smokingLabel = createBoolComponent(query: "흡연")
    let allowedFoodLabel = createBoolComponent(query: "실내 음식")
    let allowedEarphoneLabel = createBoolComponent(query: "이어폰 착용")
    
    let wakeupTimeLabel = createStringComponent(query: "기상시간")
    let cleanupLabel = createStringComponent(query: "정리정돈")
    let showerTimeLabel = createStringComponent(query: "샤워시간")
    let mbtiLabel = createStringComponent(query: "MBTI")
    
    let wishTextLabel = createWishTextLabel()
    
    let bottomView = createBottomView()
    
    [ backgroundImageView, bottomView ]
      .forEach { addSubview($0) }
    
    backgroundImageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    bottomView.snp.makeConstraints { make in
      make.top.equalTo(backgroundImageView.snp.bottom)
      make.leading.trailing.equalTo(backgroundImageView)
    }
    
    [ dormLabel, periodButton, snoreLabel, grindingLabel, smokingLabel, allowedFoodLabel, allowedEarphoneLabel, wakeupTimeLabel, cleanupLabel, showerTimeLabel, mbtiLabel, wishTextLabel ]
      .forEach { backgroundImageView.addSubview($0) }
    
    dormLabel.snp.makeConstraints { make in
      make.leading.top.equalToSuperview().inset(26)
    }
    
    periodButton.snp.makeConstraints { make in
      make.trailing.top.equalToSuperview().inset(26)
    }
    
    snoreLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(26)
      make.top.equalTo(dormLabel.snp.bottom).offset(16)
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
      make.leading.equalToSuperview().inset(26)
      make.top.equalTo(snoreLabel.snp.bottom).offset(8)
    }
    
    allowedEarphoneLabel.snp.makeConstraints { make in
      make.leading.equalTo(allowedFoodLabel.snp.trailing).offset(7)
      make.centerY.equalTo(allowedFoodLabel)
    }
    
    wakeupTimeLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(26)
      make.top.equalTo(allowedFoodLabel.snp.bottom).offset(16)
    }
    
    cleanupLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(26)
      make.top.equalTo(wakeupTimeLabel.snp.bottom).offset(8)
    }
    
    showerTimeLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(26)
      make.top.equalTo(cleanupLabel.snp.bottom).offset(8)
    }
  
    mbtiLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(26)
      make.top.equalTo(showerTimeLabel.snp.bottom).offset(8)
    }
    
    wishTextLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(26)
      make.top.equalTo(mbtiLabel.snp.bottom).offset(16)
    }
  }
  
  private func createBoolComponent(query: String) -> UIView {
    guard let myInfo = myInfo else { return UIView() }

    let view = UIView()
    view.backgroundColor = .white
    view.layer.cornerRadius = 16
    view.layer.shadowOffset = CGSize(width: 0, height: 5)
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOpacity = 0.2
    
    let queryLabel = UILabel()
    queryLabel.text = query
    queryLabel.textColor = .black
    queryLabel.font = .init(name: Font.medium.rawValue, size: 14)
    
    let validLabel = UILabel()
    validLabel.font = .init(name: Font.bold.rawValue, size: 14)
    
    if query == "코골이" {
      validLabel.textColor = myInfo.snore ? UIColor.red : UIColor.mainColor
      validLabel.text = myInfo.snore ? "있음" : "없음"
    } else if query == "이갈이" {
      validLabel.textColor = myInfo.grinding ? UIColor.red : UIColor.mainColor
      validLabel.text = myInfo.grinding ? "있음" : "없음"
    } else if query == "흡연" {
      validLabel.textColor = myInfo.smoke ? UIColor.red : UIColor.mainColor
      validLabel.text = myInfo.smoke ? "함" : "안함"
    } else if query == "실내음식" {
      validLabel.textColor = myInfo.allowedFood ? UIColor.mainColor : UIColor.red
      validLabel.text = myInfo.allowedFood ? "가능" : "불가능"
    } else {
      validLabel.textColor = myInfo.earphone ? UIColor.mainColor : UIColor.red
      validLabel.text = myInfo.earphone ? "가능" : "불가능"
    }
    
    let stack = UIStackView(arrangedSubviews: [ queryLabel, validLabel ])
    stack.axis = .horizontal
    stack.alignment = .center
    stack.spacing = 4
    
    view.addSubview(stack)
    
    view.snp.makeConstraints { make in
      make.height.equalTo(30)
    }
    
    stack.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(10)
      make.centerY.equalToSuperview()
    }
    
    return view
  }
  
  private func createStringComponent(query: String) -> UIView {
    guard let myInfo = myInfo else { return UIView() }
    
    let view = UIView()
    view.layer.cornerRadius = 12
    view.backgroundColor = .white
    view.layer.shadowOffset = CGSize(width: 0, height: 5)
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOpacity = 0.2
    
    let queryLabel = UILabel()
    queryLabel.text = query
    queryLabel.textColor = .black
    queryLabel.font = .init(name: Font.bold.rawValue, size: 10)
    queryLabel.setContentHuggingPriority(.init(rawValue: 251), for: .horizontal)
    
    let contentsLabel = UILabel()
    contentsLabel.font = .init(name: Font.bold.rawValue, size: 10)
    contentsLabel.textColor = .darkgrey_custom
    
    if query == "기상시간" {
      contentsLabel.text = myInfo.wakeupTime
    } else if query == "정리정돈" {
      contentsLabel.text = myInfo.cleanUpStatus
    } else if query == "샤워시간" {
      contentsLabel.text = myInfo.showerTime
    } else if query == "MBTI" {
      contentsLabel.text = myInfo.mbti
    }
    
    let stack = UIStackView(arrangedSubviews: [ queryLabel, contentsLabel ])
    stack.axis = .horizontal
    stack.spacing = 6
    stack.alignment = .leading
    
    view.addSubview(stack)
    
    view.snp.makeConstraints { make in
      make.height.equalTo(23)
    }
    
    stack.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(10)
      make.centerY.equalToSuperview()
    }
    
    return view
  }
  
  private func createWishTextLabel() -> UIView {
    guard let myInfo = myInfo else { return UIView() }

    let view = UIView()
    view.layer.cornerRadius = 6
    view.backgroundColor = .white
    
    let contentsLabel = UILabel()
    contentsLabel.font = .init(name: Font.regular.rawValue, size: 12)
    contentsLabel.text = myInfo.wishText
    contentsLabel.textColor = .black
    contentsLabel.numberOfLines = 0
    contentsLabel.textAlignment = .left
    
    view.addSubview(contentsLabel)
    
    view.snp.makeConstraints { make in
      make.height.equalTo(92)
    }
    
    contentsLabel.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview().inset(10)
      make.bottom.lessThanOrEqualToSuperview().inset(10)
    }
    
    return view
  }
  
  private func createBottomView() -> UIView {
    guard let myInfo = myInfo else { return UIView() }
    
    let view = UIView()
    view.backgroundColor = .white
    view.layer.borderColor = UIColor.bluegrey.cgColor
    view.layer.borderWidth = 1
    
    let humanImageView = UIImageView(image: UIImage(named: "Human"))
    
    let genderLabel = UILabel()
    genderLabel.text = myInfo.gender ? "남자," : "여자,"
    genderLabel.font = .init(name: Font.bold.rawValue, size: 12)
    genderLabel.textColor = .darkgrey_custom
    
    let ageLabel = UILabel()
    ageLabel.text = myInfo.age + " 세"
    ageLabel.textColor = .darkGray
    ageLabel.font = .init(name: Font.bold.rawValue, size: 12)
    
    let mbtiLabel = UILabel()
    mbtiLabel.text = myInfo.mbti
    mbtiLabel.textColor = .grey_custom
    mbtiLabel.font = .init(name: Font.bold.rawValue, size: 12)
    
    let stack = UIStackView(arrangedSubviews: [ genderLabel, ageLabel ])
    stack.axis = .horizontal
    stack.spacing = 4
    
    [ humanImageView, stack, mbtiLabel ]
      .forEach { view.addSubview($0) }
    
    view.snp.makeConstraints { make in
      make.height.equalTo(40)
    }
    
    humanImageView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview().inset(26)
    }
    
    stack.snp.makeConstraints { make in
      make.leading.equalTo(humanImageView.snp.trailing).offset(8)
      make.centerY.equalTo(humanImageView)
    }
    
    mbtiLabel.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(26)
      make.centerY.equalTo(humanImageView)
    }
    
    return view
  }
}
