//
//  iDormMatchingCardHabitView.swift
//  idorm
//
//  Created by 김응철 on 9/18/23.
//

import UIKit

import SnapKit

final class iDormMatchingCardLabel: BaseView {
  
  // MARK: - UI Components
  
  /// 제목 `UILabel`
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .iDormFont(.medium, size: 14.0)
    label.textColor = .black
    return label
  }()
  
  /// 부가적인 설명을 해주는 `UILabel`
  private let subtitleLabel: UILabel = {
    let label = UILabel()
    label.font = .iDormFont(.bold, size: 14.0)
    return label
  }()
  
  // MARK: - Properties
  
  private var subtitleLeadingOffset: Constraint?
  private let item: iDormMatchingCardItem
  
  // MARK: - Initializer
  
  init(_ item: iDormMatchingCardItem) {
    self.item = item
    super.init(frame: .zero)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    self.layer.cornerRadius = 16.0
    self.layer.shadowOpacity = 0.21
    self.layer.shadowRadius = 3.0
    self.layer.shadowOffset = CGSize(width: .zero, height: 4.0)
    
    self.titleLabel.font = .iDormFont(.bold, size: 14.0)
    self.subtitleLabel.font = .iDormFont(.medium, size: 14.0)
    self.subtitleLabel.textColor = .iDormColor(.iDormGray400)
    switch self.item {
    case .snoring, .grinding, .smoking, .allowedFood, .allowedEarphones:
      self.subtitleLeadingOffset?.update(offset: 4.0)
      self.subtitleLabel.font = .iDormFont(.bold, size: 14.0)
      self.titleLabel.font = .iDormFont(.medium, size: 14.0)
    case .mbti:
      self.subtitleLeadingOffset?.update(offset: 24.0)
    default:
      self.subtitleLeadingOffset?.update(offset: 6.0)
    }
    
    switch self.item {
    case .snoring(let isSnoring):
      self.titleLabel.text = "코골이"
      self.subtitleLabel.text = isSnoring ? "있음" : "없음"
      self.subtitleLabel.textColor = isSnoring ? .iDormColor(.iDormRed) : .iDormColor(.iDormBlue)
    case .grinding(let isGrinding):
      self.titleLabel.text = "이갈이"
      self.subtitleLabel.text = isGrinding ? "있음" : "없음"
      self.subtitleLabel.textColor = isGrinding ? .iDormColor(.iDormRed) : .iDormColor(.iDormBlue)
    case .smoking(let isSmoking):
      self.titleLabel.text = "흡연"
      self.subtitleLabel.text = isSmoking ? "함" : "안 함"
      self.subtitleLabel.textColor = isSmoking ? .iDormColor(.iDormRed) : .iDormColor(.iDormBlue)
    case .allowedFood(let isAllowed):
      self.titleLabel.text = "실내 음식"
      self.subtitleLabel.text = isAllowed ? "섭취 함" : "섭취 안 함"
      self.subtitleLabel.textColor = isAllowed ? .iDormColor(.iDormRed) : .iDormColor(.iDormBlue)
    case .allowedEarphones(let isAllowed):
      self.titleLabel.text = "이어폰 착용"
      self.subtitleLabel.text = isAllowed ? "함" : "안 함"
      self.subtitleLabel.textColor = isAllowed ? .iDormColor(.iDormBlue) : .iDormColor(.iDormRed)
    case .wakeUpTime(let wakeUpTime):
      self.titleLabel.text = "기상시간"
      self.subtitleLabel.text = wakeUpTime
    case .arrangement(let arrangement):
      self.titleLabel.text = "정리정돈"
      self.subtitleLabel.text = arrangement
    case .showerTime(let showerTime):
      self.titleLabel.text = "샤워시간"
      self.subtitleLabel.text = showerTime
    case .mbti(let mbti):
      self.titleLabel.text = "MBTI"
      self.subtitleLabel.text = mbti
    }
  }
  
  override func setupLayouts() {
    [
      self.titleLabel,
      self.subtitleLabel
    ].forEach {
      self.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.titleLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(8.0)
      make.directionalVerticalEdges.equalToSuperview().inset(4.0)
    }
    
    self.subtitleLabel.snp.makeConstraints { make in
      self.subtitleLeadingOffset =
      make.leading.equalTo(self.titleLabel.snp.trailing).offset(4.0).constraint
      make.trailing.equalToSuperview().inset(8.0)
      make.directionalVerticalEdges.equalToSuperview().inset(4.0)
    }
  }
}
