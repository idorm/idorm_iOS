//
//  CalendarDateSelectionCell.swift
//  idorm
//
//  Created by 김응철 on 8/3/23.
//

import UIKit

import SnapKit

@objc protocol CalendarDateSelectionCellDelegate: AnyObject {
  @objc optional func calendarDidSelect(_ currentDateString: String)
  @objc optional func pickerViewDidChangeRow(_ currentTimeString: String)
}

final class CalendarDateSelectionCell: UICollectionViewCell, BaseViewProtocol {
  
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
  
  weak var delegate: CalendarDateSelectionCellDelegate?
  private var bottomInset: Constraint?
  
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
      self.bottomInset = make.bottom.equalToSuperview().inset(24.0).constraint
    }
  }
  
  // MARK: - Functions
  
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
    self.delegate?.calendarDidSelect?(currentDateString)
  }
}

// MARK: - PickerViewDelegate

extension CalendarDateSelectionCell: CalendarDatePickerViewDelegate {
  func pickerViewDidChangeRow(_ timeString: String) {
    self.delegate?.pickerViewDidChangeRow?(timeString)
  }
}
