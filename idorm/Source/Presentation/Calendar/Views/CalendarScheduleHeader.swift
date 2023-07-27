//
//  CalendarHeader.swift
//  idorm
//
//  Created by 김응철 on 7/16/23.
//

import UIKit

import SnapKit

/// `우리방 일정` 또는 `기숙사 일정`이 있는 헤더입니다.
final class CalendarScheduleHeader: UICollectionReusableView, BaseView {
  
  // MARK: - UI Components
  
  private let contentLabel: UILabel = {
    let label = UILabel()
    label.font = .iDormFont(.regular, size: 12)
    label.textColor = .iDormColor(.iDormGray400)
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
    self.backgroundColor = .white
  }
  
  func setupLayouts() {
    self.addSubview(self.contentLabel)
  }
  
  func setupConstraints() {
    self.contentLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.centerY.equalToSuperview()
    }
  }
  
  // MARK: - Configure
  
  /// 헤더의 레이블에 들어갈 텍스트를 주입합니다.
  ///
  /// - Parameters:
  ///  - content: `String`값
  func configure(_ content: String) {
    self.contentLabel.text = content
  }
}
