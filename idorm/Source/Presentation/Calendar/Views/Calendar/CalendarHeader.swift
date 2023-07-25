//
//  CalendarHeader.swift
//  idorm
//
//  Created by 김응철 on 7/16/23.
//

import UIKit

import SnapKit
import FSCalendar

/// `CalendarVC`에 사용하는 달력이 포함되어 있는 헤더입니다.
final class CalendarHeader: UICollectionReusableView, BaseView {
  
  // MARK: - UI Components
  
  lazy var calendarView: iDormCalendarView = {
    let calendarView = iDormCalendarView(.main)
    return calendarView
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
  
  func setupStyles() {}
  
  func setupLayouts() {
    self.addSubview(self.calendarView)
  }
  
  func setupConstraints() {
    self.calendarView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  // MARK: - Configure
  
  func configure(
    _ currentDate: String,
    teamCalendars: [TeamCalendar],
    dormCalendars: [DormCalendar]
  ) {
    let currentDate = currentDate.toDate(format: "yyyy-MM")
    self.calendarView.configure(
      currentDate,
      teamCalendars: teamCalendars,
      dormCalendars: dormCalendars
    )
  }
}
