//
//  TeamCalendarCell.swift
//  idorm
//
//  Created by 김응철 on 7/16/23.
//

import UIKit

import SnapKit

final class TeamCalendarCell: UICollectionViewCell, BaseView {
  
  // MARK: - UI Components
  
  /// 오른쪽 방향의 아이콘인 버튼
  private let rightButton: UIButton = {
    let button = UIButton()
    button.setImage(.iDormIcon(.right), for: .normal)
    return button
  }()
  
  /// 일정의 날짜를 보여주는 레이블
  let dateLabel: UILabel = {
    let label = UILabel()
    label.font = .idormFont(.medium, size: 12)
    return label
  }()
  
  /// 일정의 상세 내역을 보여주는 레이블
  let contentLabel: UILabel = {
    let label = UILabel()
    label.font = .idormFont(.regular, size: 12)
    label.textColor = .iDormColor(.iDormGray300)
    return label
  }()
  
  // MARK: - Setup
  
  func setupStyles() {}
  
  func setupLayouts() {
    [
      self.rightButton,
      self.dateLabel,
      self.contentLabel
    ].forEach {
      self.contentView.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.dateLabel.snp.makeConstraints { make in
      make.leading.top.equalToSuperview()
    }
    
    self.contentLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.top.equalTo(self.dateLabel.snp.bottom)
    }
    
    self.rightButton.snp.makeConstraints { make in
      make.top.trailing.equalToSuperview()
    }
  }
}
