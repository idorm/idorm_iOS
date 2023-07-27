//
//  CalendarMemberCell.swift
//  idorm
//
//  Created by 김응철 on 7/13/23.
//

import UIKit

import SnapKit
import Kingfisher

/// 멤버의 프로필사진과 닉네임이  노출되는 `Cell`입니다.
final class CalendarMemberCell: UICollectionViewCell, BaseView {
  
  // MARK: - UI Components
  
  private let calendarMemberView: CalendarMemberView = {
    let view = CalendarMemberView()
    return view
  }()
  
  // MARK: - Life Cycle
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }
  
  // MARK: - Setup
  
  func setupStyles() {
    self.contentView.backgroundColor = .clear
  }
  
  func setupLayouts() {
    self.contentView.addSubview(self.calendarMemberView)
  }
  
  func setupConstraints() {
    self.calendarMemberView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  // MARK: - Configure
  
  func configure(with member: TeamMember) {
    self.calendarMemberView.configure(with: member)
  }
}
