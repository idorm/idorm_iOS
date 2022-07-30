//
//  CalendarCollectionHeaderView.swift
//  idorm
//
//  Created by 김응철 on 2022/07/27.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import FSCalendar

class CalendarCollectionHeaderView: UICollectionReusableView {
  lazy var calendar: FSCalendar = {
    let calendar = FSCalendar()
    calendar.scope = .month
    calendar.locale = Locale(identifier: "ko_KR")
    calendar.fs_height = 234
    
    calendar.appearance.headerTitleFont = .init(name: Font.medium.rawValue, size: 16)
    calendar.appearance.headerTitleColor = .black
    calendar.appearance.headerDateFormat = "M월"
    calendar.headerHeight = 0
    calendar.appearance.weekdayFont = .init(name: Font.regular.rawValue, size: 12)
    calendar.appearance.weekdayTextColor = .idorm_gray_400
    calendar.appearance.titleFont = .init(name: Font.regular.rawValue, size: 12)
    calendar.appearance.titleDefaultColor = .idorm_gray_400
    calendar.appearance.headerMinimumDissolvedAlpha = 0
    calendar.appearance.selectionColor = .white
    calendar.appearance.titleSelectionColor = .idorm_gray_400
    calendar.appearance.todayColor = .white
    calendar.appearance.titleTodayColor = .idorm_gray_400
    calendar.appearance.borderRadius = 0
    
    calendar.placeholderType = .none
    calendar.backgroundColor = .white
    calendar.scrollDirection = .horizontal
    calendar.scrollEnabled = true
    calendar.register(CalendarCell.self, forCellReuseIdentifier: CalendarCell.identifier)
    calendar.dataSource = self
    calendar.delegate = self
    
    return calendar
  }()
  
  lazy var calendarHeaderView: CalendarHeaderView = {
    let view = CalendarHeaderView()
    view.configureUI(date: calendar.today ?? Date())
    
    return view
  }()
  
  static let identifier = "MainCalendarCollectionHeaderView"
  let disposeBag = DisposeBag()
  
  // MARK: - LifeCycle
  override init(frame: CGRect) {
    super.init(frame: frame)
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Bind
  private func bind() {
    calendarHeaderView.arrowButtonPublisher
      .bind(onNext: { [weak self] moveUp in
        self?.moveCurrentPage(moveUp: moveUp)
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: - Helpers
  func configureUI() {
    calendar.calendarWeekdayView.weekdayLabels[0].textColor = .idorm_red
    calendar.calendarWeekdayView.weekdayLabels[6].textColor = .idorm_red
    calendar.visibleCells()

    [ calendar, calendarHeaderView ]
      .forEach { addSubview($0) }
    
    calendarHeaderView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
      make.height.equalTo(63)
    }
    
    calendar.snp.makeConstraints { make in
      make.top.equalTo(calendarHeaderView.snp.bottom)
      make.leading.trailing.equalToSuperview().inset(24)
      make.bottom.equalToSuperview()
    }
  }
  
  private func stringToDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
  }
  
  private func moveCurrentPage(moveUp: Bool) {
    let nextPage: Int = moveUp ? +1 : -1
    let getNextMonth = Calendar.current.date(byAdding: .month, value: nextPage, to: calendar.currentPage)!
    calendarHeaderView.onChangedMonth.onNext(getNextMonth)
    calendar.setCurrentPage(getNextMonth, animated: true)
  }
  
  private func datesRagne(from: Date, to: Date) -> [Date] {
    if from > to { return [Date]() }
    var tempDate = from
    var array = [tempDate]
    
    while tempDate > to {
      tempDate = Calendar.current.date(byAdding: .day, value: 1, to: tempDate)!
      array.append(tempDate)
    }
    
    return array
  }
}

extension CalendarCollectionHeaderView: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
  func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
    calendarHeaderView.onChangedMonth.onNext(calendar.currentPage)
  }
  
  func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
    guard let cell = calendar.dequeueReusableCell(withIdentifier: CalendarCell.identifier, for: date, at: .current) as? CalendarCell else { return FSCalendarCell() }
    cell.configureUI()
    return cell
  }
  
  func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
  }
  
  func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
    switch stringToDate(date) {
    case "2022-07-28":
      return .idorm_blue
    default:
      return .clear
    }
  }
  
  func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
    print(date)
  }
}
