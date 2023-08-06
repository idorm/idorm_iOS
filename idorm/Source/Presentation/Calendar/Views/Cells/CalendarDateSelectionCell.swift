//
//  CalendarDateSelectionCell.swift
//  idorm
//
//  Created by 김응철 on 8/3/23.
//

import UIKit

import SnapKit

protocol CalendarDateSelectionCellDelegate: AnyObject {
  func calendarDidSelect(_ currentDateString: String)
  func pickerViewDidChangeRow(_ currentTimeString: String)
}

final class CalendarDateSelectionCell: UICollectionViewCell, BaseView {
  
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
  
  weak var delegate: CalendarDateSelectionCellDelegate?
  
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
    [
      self.calendarView,
      self.pickerView
    ].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.calendarView.snp.makeConstraints { make in
      make.top.directionalHorizontalEdges.equalToSuperview()
      make.height.equalTo(280.0)
    }
    
    self.pickerView.snp.makeConstraints { make in
      make.top.equalTo(self.calendarView.snp.bottom)
      make.directionalHorizontalEdges.equalToSuperview().inset(40.0)
      make.bottom.equalToSuperview().inset(24.0)
    }
  }
  
  // MARK: - Functions
  
  /// 초기에 셀의 데이터를 주입할 때
  /// `Calendar`와 `PickerView`의 값을 업데이트합니다.
  ///
  /// - Parameters:
  ///  - date: 업데이트할 날짜
  ///  - time: 업데이트할 시간
  func updateUI(date: String, time: String) {
    print(#function)
    self.calendarView.updateSelectedDate(date)
    self.pickerView.updateSelectedRow(time)
  }
}

// MARK: - CalendarDelegate

extension CalendarDateSelectionCell: iDormCalendarViewDelegate {
  func calendarDidSelect(_ currentDateString: String) {
    self.delegate?.calendarDidSelect(currentDateString)
  }
}

// MARK: - PickerViewDelegate

extension CalendarDateSelectionCell: CalendarDatePickerViewDelegate {
  func pickerViewDidChangeRow(_ timeString: String) {
    self.delegate?.pickerViewDidChangeRow(timeString)
  }
}
