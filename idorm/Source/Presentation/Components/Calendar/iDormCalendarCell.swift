//
//  iDormCalendarCell.swift
//  idorm
//
//  Created by 김응철 on 7/8/23.
//

import UIKit

import FSCalendar
import SnapKit

final class iDormCalendarCell: FSCalendarCell, BaseView {
  
  private enum Metric {
    
  }
  
  // MARK: - Properties
  
  static let identifier = "iDormCalendarCell"
  
  /// 현재 어떤 캘린더를 사용하는지 알 수 있습니다.
  private var viewType: iDormCalendarView.ViewType = .main
  
  // MARK: - UI Components
  
  // MARK: - LifeCycle
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }
  
  // MARK: - Setup
  
  func setupStyles() {
//    switch self.viewType {
//    case .main:
//      
//    case .sub:
//      
//    }
  }
  
  func setupLayouts() {
  }
  
  func setupConstraints() {
  }

  // MARK: - Override
  
  /// 셀을 선택했을 때 불려지는 메서드입니다.
  override func performSelecting() {
    self.titleLabel.textColor = .white
    self.contentView.backgroundColor = .iDormColor(.iDormBlue)
  }
  
  /// 셀의 이벤트가 들어왔을 때 무조건적으로 불려지는 메서드입니다.
  override func configureAppearance() {
    super.configureAppearance()
    
    self.contentView.backgroundColor = self.isSelected ? .iDormColor(.iDormBlue) : .white
  }
  
  // MARK: - Configure
  
  func configure(_ viewType: iDormCalendarView.ViewType) {
    self.viewType = viewType
  }
}
