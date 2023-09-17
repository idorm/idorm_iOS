//
//  OnboardingHeaderView.swift
//  idorm
//
//  Created by 김응철 on 9/14/23.
//

import UIKit

import SnapKit

final class OnboardingHeaderView: UICollectionReusableView, BaseViewProtocol {
  
  // MARK: - UI Components
  
  /// `룸메이트 매칭을 위한 기본정보를 알려주세요!`가 적혀있는 `UILabel`
  private let letMeKnowLabel: UILabel = {
    let label = UILabel()
    label.text = "룸메이트 매칭을 위한 기본정보를 알려주세요!"
    label.textColor = .iDormColor(.iDormGray300)
    label.font = .iDormFont(.bold, size: 12.0)
    return label
  }()
  
  /// `불호요소가 있는 내 습관을 미리 알려주세요.`가 적혀있는 `UILabel`
  private let letMeKnowHabitLabel: UILabel = {
    let label = UILabel()
    label.text = "불호요소가 있는 내 습관을 미리 알려주세요."
    label.textColor = .iDormColor(.iDormGray300)
    label.font = .iDormFont(.medium, size: 12.0)
    return label
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .black
    label.font = .iDormFont(.medium, size: 16.0)
    return label
  }()
  
  private let subTitleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .iDormColor(.iDormGray400)
    label.font = .iDormFont(.medium, size: 14.0)
    return label
  }()
  
  /// `(필수)`가 적혀있는 `UILabel`
  private let essentialLabel: UILabel = {
    let label = UILabel()
    label.textColor = .iDormColor(.iDormBlue)
    label.font = .iDormFont(.regular, size: 14.0)
    label.text = "(필수)"
    return label
  }()
  
  /// 해당 HeaderView의 끝 지점을 알려주는 `UIView`
  private let supportView: UIView = {
    let view = UIView()
    view.backgroundColor = .clear
    return view
  }()
  
  /// 100자까지 제한이 있는 `UILabel`
  private let maxLengthLabel: UILabel = {
    let label = UILabel()
    label.text = " / 100 pt"
    label.textColor = .iDormColor(.iDormGray300)
    label.font = .iDormFont(.medium, size: 14.0)
    label.isHidden = true
    return label
  }()
  
  /// 현재 글자 수를 나타내는 `UILabel`
  private let currentLengthLabel: UILabel = {
    let label = UILabel()
    label.text = "0"
    label.textColor = .iDormColor(.iDormBlue)
    label.font = .iDormFont(.medium, size: 14.0)
    label.isHidden = true
    return label
  }()
  
  // MARK: - Properties
  
  private var heightConstraint: Constraint?
  private var titleLabelTopInset: Constraint?
  
  // MARK: - Initializer
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  func setupStyles() {}
  
  func setupLayouts() {
    [
      self.letMeKnowLabel,
      self.titleLabel,
      self.letMeKnowHabitLabel,
      self.subTitleLabel,
      self.essentialLabel,
      self.supportView,
      self.maxLengthLabel,
      self.currentLengthLabel
    ].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.letMeKnowLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(16.0)
      make.leading.equalToSuperview()
    }
    
    self.titleLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      self.titleLabelTopInset = make.top.equalToSuperview().inset(16.0).constraint
    }
    
    self.letMeKnowHabitLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.top.equalTo(self.titleLabel.snp.bottom).offset(2.0)
    }
    
    self.subTitleLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.top.equalToSuperview().inset(16.0)
    }
    
    self.essentialLabel.snp.makeConstraints { make in
      make.leading.equalTo(self.subTitleLabel.snp.trailing).offset(6.0)
      make.centerY.equalTo(self.subTitleLabel)
    }
    
    self.maxLengthLabel.snp.makeConstraints { make in
      make.centerY.equalTo(self.subTitleLabel)
      make.trailing.equalToSuperview()
    }
    
    self.currentLengthLabel.snp.makeConstraints { make in
      make.centerY.equalTo(self.subTitleLabel)
      make.trailing.equalTo(self.maxLengthLabel.snp.leading).offset(-2.0)
    }
    
    self.supportView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      self.heightConstraint = make.height.equalTo(45.0).constraint
    }
  }
  
  // MARK: - Configure
  
  func configure(with section: OnboardingSection) {
    self.titleLabel.text = section.title
    self.subTitleLabel.text = section.subTitle
    self.essentialLabel.isHidden = true
    self.letMeKnowLabel.isHidden = true
    self.letMeKnowHabitLabel.isHidden = true
    self.titleLabel.isHidden = true
    self.subTitleLabel.isHidden = true
    self.maxLengthLabel.isHidden = true
    self.currentLengthLabel.isHidden = true
     
    switch section {
    case .dormitory:
      self.letMeKnowLabel.isHidden = false
      self.titleLabel.isHidden = false
      self.heightConstraint?.update(offset: 84.0)
      self.titleLabelTopInset?.update(inset: 50.0)
    case .habit:
      self.titleLabel.isHidden = false
      self.letMeKnowHabitLabel.isHidden = false
      self.heightConstraint?.update(offset: 72.0)
      self.titleLabelTopInset?.update(inset: 16.0)
    case .gender, .period, .age:
      self.titleLabel.isHidden = false
      self.heightConstraint?.update(offset: 50.0)
      self.titleLabelTopInset?.update(inset: 16.0)
    case .wakeUpTime, .arrangement, .showerTime, .kakao:
      self.subTitleLabel.isHidden = false
      self.essentialLabel.isHidden = false
      self.heightConstraint?.update(offset: 45.0)
    case .mbti:
      self.subTitleLabel.isHidden = false
      self.heightConstraint?.update(offset: 45.0)
    case .wantToSay:
      self.subTitleLabel.isHidden = false
      self.heightConstraint?.update(offset: 45.0)
      self.maxLengthLabel.isHidden = false
      self.currentLengthLabel.isHidden = false
    }
  }
  
  // MARK: - Functions
  
  func updateCurrentLength(_ text: String) {
    self.currentLengthLabel.text = "\(text.count)"
  }
}
