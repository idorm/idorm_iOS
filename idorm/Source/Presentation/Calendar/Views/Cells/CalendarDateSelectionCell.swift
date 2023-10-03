//
//  CalendarDateSelectionCell.swift
//  idorm
//
//  Created by 김응철 on 8/3/23.
//

import UIKit

import SnapKit

final class CalendarDateSelectionCell: BaseCollectionViewCell {
  
  enum CellType {
    case teamCalendar(date: String, time: String)
    case sleepover(date: String)
  }
  
  // MARK: - UI Components
  
  private lazy var calendarView: iDormCalendarView = {
    let calendarView = iDormCalendarView(.sub)
    calendarView.delegate = self
    return calendarView
  }()
  
  private lazy var pickerView: CalendarDatePickerView = {
    let pickerView = CalendarDatePickerView()
    pickerView.delegate = self
    return pickerView
  }()
  
  // MARK: - Properties
  
  private var bottomInset: Constraint?
  var calendarHandler: ((String) -> Void)?
  var pickerViewHandler: ((String) -> Void)?
  
  // MARK: - Setup
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [
      self.calendarView,
      self.pickerView
    ].forEach {
      self.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.calendarView.snp.makeConstraints { make in
      make.top.directionalHorizontalEdges.equalToSuperview()
      make.height.equalTo(280.0)
    }
    
    self.pickerView.snp.makeConstraints { make in
      make.top.equalTo(self.calendarView.snp.bottom)
      make.directionalHorizontalEdges.equalToSuperview().inset(40.0)
      self.bottomInset = make.bottom.equalToSuperview().inset(24.0).constraint
    }
  }
  
  // MARK: - Configure
  
  /// 초기에 셀의 데이터를 주입할 때
  /// `Calendar`와 `PickerView`의 값을 업데이트합니다.
  ///
  /// - Parameters:
  ///  - cellType: 이 셀에 적용할 분기값
  func configure(_ cellType: CellType) {
    self.pickerView.isHidden = false
    switch cellType {
    case let .teamCalendar(date, time):
      self.calendarView.updateSelectedDate(date)
      self.pickerView.updateSelectedRow(time)
      self.bottomInset?.update(inset: 24.0)
    case .sleepover(let date):
      self.calendarView.updateSelectedDate(date)
      self.pickerView.isHidden = true
      self.bottomInset?.update(inset: 0)
    }
  }
}

// MARK: - CalendarDelegate

extension CalendarDateSelectionCell: iDormCalendarViewDelegate {
  func calendarDidSelect(_ currentDateString: String) {
    self.calendarHandler?(currentDateString)
  }
}

// MARK: - PickerViewDelegate

extension CalendarDateSelectionCell: CalendarDatePickerViewDelegate {
  func pickerViewDidChangeRow(_ timeString: String) {
    self.pickerViewHandler?(timeString)
  }
}
