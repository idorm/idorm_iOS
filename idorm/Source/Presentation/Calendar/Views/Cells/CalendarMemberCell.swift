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
final class CalendarMemberCell: BaseCollectionViewCell {
  
  // MARK: - UI Components
  
  private let calendarMemberView: CalendarMemberView = {
    let view = CalendarMemberView()
    return view
  }()
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    self.contentView.backgroundColor = .clear
    self.isUserInteractionEnabled = true
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    self.contentView.addSubview(self.calendarMemberView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.calendarMemberView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  // MARK: - Configure
  
  func configure(with member: TeamMember, isEditing: Bool) {
    self.calendarMemberView.teamMember = member
    self.calendarMemberView.isEditing = isEditing
  }
}
