//
//  DormCalendarEmptyCell.swift
//  idorm
//
//  Created by 김응철 on 7/27/23.
//

import UIKit

import SnapKit

/// 기숙사 일정이 존재하지 않을 때 보여지는 `UICollectionViewCell`
final class DormCalendarEmptyCell: UICollectionViewCell, BaseView {
  
  // MARK: - UI Components
  
  private let noCalendarsLabel: UILabel = {
    let label = UILabel()
    label.textColor = .iDormColor(.iDormGray200)
    label.font = .iDormFont(.bold, size: 14.0)
    label.text = "아직 공지된 기숙사 일정이 없어요."
    return label
  }()
  
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
  
  func setupStyles() {
    self.contentView.backgroundColor = .iDormColor(.iDormGray100)
    self.contentView.layer.cornerRadius = 14.0
  }
  
  func setupLayouts() {
    self.contentView.addSubview(self.noCalendarsLabel)
  }
  
  func setupConstraints() {
    self.noCalendarsLabel.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
}
