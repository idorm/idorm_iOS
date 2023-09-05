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
    self.contentView.backgroundColor = .clear
    self.isUserInteractionEnabled = true
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
  
  func configure(with member: TeamCalendarSingleMemberResponseDTO, isEditing: Bool) {
    self.calendarMemberView.configure(with: member, isEditing: isEditing)
  }
}
