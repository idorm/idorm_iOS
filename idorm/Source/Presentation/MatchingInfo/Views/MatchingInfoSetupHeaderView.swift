//
//  OnboardingHeaderView.swift
//  idorm
//
//  Created by 김응철 on 9/14/23.
//

import UIKit

import SnapKit

final class MatchingInfoSetupHeaderView: UICollectionReusableView, BaseViewProtocol {
  
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
  private let noticeLabel: UILabel = {
    let label = UILabel()
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
      self.noticeLabel,
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
    
    self.noticeLabel.snp.makeConstraints { make in
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
      self.heightConstraint = make.height.equalTo(45.0).constraint.update(priority: .high)
    }
  }
  
  // MARK: - Configure
  
  func configure(with section: MatchingInfoSetupSection) {
    self.titleLabel.text = section.title
    self.noticeLabel.text = section.subTitle
    self.subTitleLabel.text = section.subTitle
    self.subviews.forEach { $0.isHidden = true }
    self.heightConstraint?.update(offset: section.headerHeight)
    self.titleLabelTopInset?.update(inset: 16.0)
    
    switch section {
    case .dormitory(let isFilterSetupVC):
      self.letMeKnowLabel.isHidden = isFilterSetupVC ? true : false
      if !isFilterSetupVC { self.titleLabelTopInset?.update(inset: 50.0) }
      self.titleLabel.isHidden = false
    case .habit:
      self.titleLabel.isHidden = false
      self.noticeLabel.isHidden = false
    case .gender, .period:
      self.titleLabel.isHidden = false
    case .age(let isFilterSetupVC):
      self.noticeLabel.isHidden = !isFilterSetupVC
      self.titleLabel.isHidden = false
    case .wakeUpTime, .arrangement, .showerTime, .kakao:
      self.subTitleLabel.isHidden = false
      self.essentialLabel.isHidden = false
    case .mbti:
      self.subTitleLabel.isHidden = false
    case .wantToSay:
      self.subTitleLabel.isHidden = false
      self.maxLengthLabel.isHidden = false
      self.currentLengthLabel.isHidden = false
    }
  }
  
  // MARK: - Functions
  
  func updateCurrentLength(_ text: String) {
    self.currentLengthLabel.text = "\(text.count)"
  }
}
