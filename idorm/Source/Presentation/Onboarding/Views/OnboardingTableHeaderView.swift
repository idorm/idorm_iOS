//
//  OnboardingTableHeaderView.swift
//  idorm
//
//  Created by 김응철 on 2022/07/08.
//

import UIKit
import SnapKit
import CHIOTPField
import RxSwift
import RxCocoa
import RangeSeekSlider

enum OnboardingTableViewType {
  case normal
  case matchingFilter
}

enum OnboardingHeaderListType: String, CaseIterable {
  case dorm
  case gender
  case period
  case snore
  case grinding
  case smoke
  case allowedFood
  case earphone
  case age
  
  var query: String {
    switch self {
    case .dorm: return "기숙사"
    case .gender: return "성별"
    case .period: return "입사 기간"
    case .snore, .grinding, .smoke, .allowedFood, .earphone: return "내 습관"
    case .age: return "나이"
    }
  }
}

class OnboardingTableHeaderView: UITableViewHeaderFooterView {
  // MARK: - Properties
  lazy var ageTextField: CHIOTPFieldTwo = {
    let tf = CHIOTPFieldTwo()
    tf.numberOfDigits = 2
    tf.borderColor = .idorm_gray_200
    tf.font = .init(name: MyFonts.medium.rawValue, size: 14)
    tf.cornerRadius = 10
    tf.spacing = 2
    
    return tf
  }()
  
  lazy var ageDescriptionLabel: UILabel = {
    let label = UILabel()
    label.text = "살"
    label.textColor = .idorm_gray_300
    label.font = .init(name: MyFonts.medium.rawValue, size: 12)
    
    return label
  }()
  
  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.text = "룸메이트 매칭을 위한 기본정보를 알려주세요!"
    label.textColor = .idorm_gray_300
    label.font = .init(name: MyFonts.bold.rawValue, size: 12.0)
    
    return label
  }()
  
  lazy var habitDescriptionLabel: UILabel = {
    let label = UILabel()
    label.text = "불호요소가 있는 내 습관을 미리 알려주세요."
    label.font = .init(name: MyFonts.medium.rawValue, size: 12)
    label.textColor = .idorm_gray_300
    
    return label
  }()
  
  lazy var slider: RangeSeekSlider = {
    let slider = RangeSeekSlider()
    slider.backgroundColor = .white
    slider.colorBetweenHandles = .idorm_blue
    slider.tintColor = .idorm_gray_100
    slider.labelPadding = 6
    slider.minLabelColor = .black
    slider.maxLabelColor = .black
    slider.minLabelFont = .init(name: MyFonts.medium.rawValue, size: 12)!
    slider.maxLabelFont = .init(name: MyFonts.medium.rawValue, size: 12)!
    slider.minValue = 20
    slider.maxValue = 40
    slider.selectedMaxValue = 30
    slider.selectedMinValue = 20
    slider.lineHeight = 11
    slider.handleImage = UIImage(named: "thumb(Matching)")
    slider.minDistance = 1
    slider.enableStep = true
    slider.selectedHandleDiameterMultiplier = 1.0
    
    return slider
  }()
  
  let dormLabel = OnboardingUtilities.getBasicLabel(text: "기숙사")
  let dorm1Button = OnboardingUtilities.getBasicButton(title: "1 기숙사")
  let dorm2Button = OnboardingUtilities.getBasicButton(title: "2 기숙사")
  let dorm3Button = OnboardingUtilities.getBasicButton(title: "3 기숙사")
  let dormLine = OnboardingUtilities.getSeparatorLine()
  
  let genderLabel = OnboardingUtilities.getBasicLabel(text: "성별")
  let maleButton = OnboardingUtilities.getBasicButton(title: "남성")
  let femaleButton = OnboardingUtilities.getBasicButton(title: "여성")
  let genderLine = OnboardingUtilities.getSeparatorLine()
  
  let periodLabel = OnboardingUtilities.getBasicLabel(text: "입사 기간")
  let period16Button = OnboardingUtilities.getBasicButton(title: "16 주")
  let period24Button = OnboardingUtilities.getBasicButton(title: "24 주")
  let periodLine = OnboardingUtilities.getSeparatorLine()
  
  let habitLabel = OnboardingUtilities.getBasicLabel(text: "내 습관")
  let snoreButton = OnboardingUtilities.getBasicButton(title: "코골이")
  let grindingButton = OnboardingUtilities.getBasicButton(title: "이갈이")
  let smokingButton = OnboardingUtilities.getBasicButton(title: "흡연")
  let allowedFoodButton = OnboardingUtilities.getBasicButton(title: "실내 음식 섭취 함")
  let allowedEarphoneButton = OnboardingUtilities.getBasicButton(title: "이어폰 착용 안함")
  let habitLine = OnboardingUtilities.getSeparatorLine()
  
  let ageLabel = OnboardingUtilities.getBasicLabel(text: "나이")
  let ageLine = OnboardingUtilities.getSeparatorLine()
  
  static let identifier = "OnboardingTableHeaderView"
  
  let disposeBag = DisposeBag()
  
  let onChangedDorm1Button = PublishSubject<Bool>()
  let onChangedDorm2Button = PublishSubject<Bool>()
  let onChangedDorm3Button = PublishSubject<Bool>()
  
  let onChangedMaleButton = PublishSubject<Bool>()
  let onChangedFemaleButton = PublishSubject<Bool>()
  
  let onChangedPeriod16Button = PublishSubject<Bool>()
  let onChangedPeriod24Button = PublishSubject<Bool>()
  
  let onChangedSnoringButton = PublishSubject<Bool>()
  let onChangedGrindingButton = PublishSubject<Bool>()
  let onChangedSmokingButton = PublishSubject<Bool>()
  let onChangedAllowedFoodButton = PublishSubject<Bool>()
  let onChangedAllowedEarphoneButton = PublishSubject<Bool>()
  
  let onChangedAgeTextField = PublishSubject<String>()
  
  var type: OnboardingTableViewType = .normal
  
  // MARK: - LifeCycle
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Selectors
  @objc private func didTapDorm1Button() {
    dorm1Button.isSelected = true
    dorm2Button.isSelected = false
    dorm3Button.isSelected = false
    onChangedDorm1Button.onNext(dorm1Button.isSelected)
  }
  
  @objc private func didTapDorm2Button() {
    dorm1Button.isSelected = false
    dorm2Button.isSelected = true
    dorm3Button.isSelected = false
    onChangedDorm2Button.onNext(dorm2Button.isSelected)
  }
  
  @objc private func didTapDorm3Button() {
    dorm1Button.isSelected = false
    dorm2Button.isSelected = false
    dorm3Button.isSelected = true
    onChangedDorm3Button.onNext(dorm3Button.isSelected)
  }
  
  @objc private func didTapMaleButton() {
    maleButton.isSelected = true
    femaleButton.isSelected = false
    onChangedMaleButton.onNext(maleButton.isSelected)
  }
  
  @objc private func didTapFemaleButton() {
    maleButton.isSelected = false
    femaleButton.isSelected = true
    onChangedFemaleButton.onNext(femaleButton.isSelected)
  }
  
  @objc private func didTapPeriod16Button() {
    period16Button.isSelected = true
    period24Button.isSelected = false
    onChangedPeriod16Button.onNext(period16Button.isSelected)
  }
  
  @objc private func didTapPeriod24Button() {
    period16Button.isSelected = false
    period24Button.isSelected = true
    onChangedPeriod24Button.onNext(period24Button.isSelected)
  }
  
  @objc private func didTapSnoringButton() {
    snoreButton.isSelected = !snoreButton.isSelected
    onChangedSnoringButton.onNext(snoreButton.isSelected)
  }
  
  @objc private func didTapGrindingButton() {
    grindingButton.isSelected = !grindingButton.isSelected
    onChangedGrindingButton.onNext(grindingButton.isEnabled)
  }

  @objc private func didTapSmokingButton() {
    smokingButton.isSelected = !smokingButton.isSelected
    onChangedSmokingButton.onNext(smokingButton.isSelected)
  }

  @objc private func didTapAllowedFoodButton() {
    allowedFoodButton.isSelected = !allowedFoodButton.isSelected
    onChangedAllowedFoodButton.onNext(allowedFoodButton.isSelected)
  }
  
  @objc private func didTapAllowedEarphoneButton() {
    allowedEarphoneButton.isSelected = !allowedEarphoneButton.isSelected
    onChangedAllowedEarphoneButton.onNext(allowedEarphoneButton.isSelected)
  }
  
  // MARK: - Helpers
  private func bind() {
    dorm1Button.addTarget(self, action: #selector(didTapDorm1Button), for: .touchUpInside)
    dorm2Button.addTarget(self, action: #selector(didTapDorm2Button), for: .touchUpInside)
    dorm3Button.addTarget(self, action: #selector(didTapDorm3Button), for: .touchUpInside)
    period16Button.addTarget(self, action: #selector(didTapPeriod16Button), for: .touchUpInside)
    period24Button.addTarget(self, action: #selector(didTapPeriod24Button), for: .touchUpInside)
    snoreButton.addTarget(self, action: #selector(didTapSnoringButton), for: .touchUpInside)
    grindingButton.addTarget(self, action: #selector(didTapGrindingButton), for: .touchUpInside)
    smokingButton.addTarget(self, action: #selector(didTapSmokingButton), for: .touchUpInside)
    allowedFoodButton.addTarget(self, action: #selector(didTapAllowedFoodButton), for: .touchUpInside)
    allowedEarphoneButton.addTarget(self, action: #selector(didTapAllowedEarphoneButton), for: .touchUpInside)
    maleButton.addTarget(self, action: #selector(didTapMaleButton), for: .touchUpInside)
    femaleButton.addTarget(self, action: #selector(didTapFemaleButton), for: .touchUpInside)
    
    ageTextField.rx.text
      .orEmpty
      .asDriver(onErrorJustReturn: "")
      .drive(onNext: { [weak self] text in
        self?.onChangedAgeTextField.onNext(text)
        print(text)
      })
      .disposed(by: disposeBag)
  }
  
  func configureUI(type: OnboardingTableViewType) {
    let dormStack = UIStackView(arrangedSubviews: [ dorm1Button, dorm2Button, dorm3Button ])
    dormStack.spacing = 12
    
    let genderStack = UIStackView(arrangedSubviews: [ maleButton, femaleButton ])
    genderStack.spacing = 12
    
    let periodStack = UIStackView(arrangedSubviews: [ period16Button, period24Button ])
    periodStack.spacing = 12
    
    let habitStack1 = UIStackView(arrangedSubviews: [ snoreButton, grindingButton, smokingButton ])
    let habitStack2 = UIStackView(arrangedSubviews: [ allowedFoodButton, allowedEarphoneButton ])
    habitStack1.spacing = 12
    habitStack2.spacing = 12
    
    self.type = type

    [ titleLabel, dormLabel, dormStack, dormLine, periodLabel, periodStack, periodLine, habitLabel, habitDescriptionLabel, habitStack2, habitStack1, habitLine, ageLabel, ageTextField, ageDescriptionLabel, ageLine, genderStack, genderLine, genderLabel, slider ]
      .forEach { addSubview($0) }
    
    switch type {
    case .normal:
      slider.removeFromSuperview()
      
      titleLabel.snp.makeConstraints { make in
        make.leading.equalToSuperview().inset(25)
        make.top.equalToSuperview().inset(20)
      }
      
      dormLabel.snp.makeConstraints { make in
        make.leading.equalToSuperview().inset(25)
        make.top.equalTo(titleLabel.snp.bottom).offset(16)
      }
      
      ageTextField.snp.makeConstraints { make in
        make.top.equalTo(ageLabel.snp.bottom).offset(10)
        make.leading.equalToSuperview().inset(25)
        make.width.equalTo(90)
        make.height.equalTo(33)
      }

      ageDescriptionLabel.snp.makeConstraints { make in
        make.centerY.equalTo(ageTextField)
        make.leading.equalTo(ageTextField.snp.trailing).offset(8)
      }
      
      ageLine.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(25)
        make.top.equalTo(ageTextField.snp.bottom).offset(16)
        make.height.equalTo(1)
        make.bottom.equalToSuperview().inset(16)
      }
    case .matchingFilter:
      titleLabel.removeFromSuperview()
      ageTextField.removeFromSuperview()
      ageLine.removeFromSuperview()
      
      habitLabel.text = "불호 요소"
      habitDescriptionLabel.text = "선택하신 요소를 가진 룸메이트는 나와 매칭되지 않아요."
      ageDescriptionLabel.text = "선택하신 연령대의 룸메이트만 나와 매칭돼요."

      dormLabel.snp.makeConstraints { make in
        make.leading.equalToSuperview().inset(25)
        make.top.equalToSuperview().inset(16)
      }
      
      ageDescriptionLabel.snp.makeConstraints { make in
        make.top.equalTo(ageLabel.snp.bottom).offset(2)
        make.leading.equalToSuperview().inset(25)
      }
      
      slider.snp.makeConstraints { make in
        make.top.equalTo(ageDescriptionLabel.snp.bottom).offset(10)
        make.leading.trailing.equalToSuperview().inset(25)
        make.bottom.equalToSuperview().inset(16)
      }
    }
    
    dormStack.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalTo(dormLabel.snp.bottom).offset(10)
    }
    
    dormLine.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(25)
      make.top.equalTo(dormStack.snp.bottom).offset(16)
      make.height.equalTo(1)
    }
    
    genderLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalTo(dormLine.snp.bottom).offset(16)
    }
    
    genderStack.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalTo(genderLabel.snp.bottom).offset(10)
    }
    
    genderLine.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(25)
      make.top.equalTo(genderStack.snp.bottom).offset(16)
      make.height.equalTo(1)
    }
    
    periodLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalTo(genderLine.snp.bottom).offset(16)
    }
    
    periodStack.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalTo(periodLabel.snp.bottom).offset(10)
    }
    
    periodLine.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(25)
      make.top.equalTo(periodStack.snp.bottom).offset(16)
      make.height.equalTo(1)
    }
    
    habitLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalTo(periodLine.snp.bottom).offset(16)
    }
    
    habitDescriptionLabel.snp.makeConstraints { make in
      make.top.equalTo(habitLabel.snp.bottom)
      make.leading.equalToSuperview().inset(25)
    }
    
    habitStack1.snp.makeConstraints { make in
      make.top.equalTo(habitDescriptionLabel.snp.bottom).offset(12)
      make.leading.equalToSuperview().inset(25)
    }
    
    habitStack2.snp.makeConstraints { make in
      make.top.equalTo(habitStack1.snp.bottom).offset(10)
      make.leading.equalToSuperview().inset(25)
    }
    
    habitLine.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(25)
      make.top.equalTo(habitStack2.snp.bottom).offset(16)
      make.height.equalTo(1)
    }
    
    ageLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalTo(habitLine.snp.bottom).offset(16)
    }
  }
}
