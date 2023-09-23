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
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .black
    label.text = self.item.title
    label.font = self.item.titleFont
    label.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
    return label
  }()
  
  /// 부가적인 설명을 해주는 `UILabel`
  private lazy var subtitleLabel: UILabel = {
    let label = UILabel()
    label.font = self.item.subtitleFont
    label.textColor = self.item.subtitleColor
    label.text = self.item.subtitleString
    label.setContentCompressionResistancePriority(UILayoutPriority(751), for: .horizontal)
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
    self.layer.cornerRadius = 14.0
    self.layer.shadowOpacity = 0.21
    self.layer.shadowRadius = 3.0
    self.layer.shadowOffset = CGSize(width: .zero, height: 4.0)
    self.backgroundColor = .white
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
      switch self.item {
      case .snoring, .grinding, .smoking, .allowedFood, .allowedEarphones:
        make.leading.equalTo(self.titleLabel.snp.trailing).offset(4.0)
      case .mbti:
        make.leading.equalTo(self.titleLabel.snp.trailing).offset(23.0)
      default:
        make.leading.equalTo(self.titleLabel.snp.trailing).offset(6.0)
      }
      make.trailing.equalToSuperview().inset(8.0)
      make.directionalVerticalEdges.equalToSuperview().inset(4.0)
    }
  }
}
