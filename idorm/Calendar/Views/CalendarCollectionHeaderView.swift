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
    calendar.placeholderType = .none
    
    calendar.backgroundColor = .white
    
    calendar.scrollDirection = .horizontal
    calendar.scrollEnabled = true
    
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
    configureCalendar()
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
  
  private func moveCurrentPage(moveUp: Bool) {
    let nextPage: Int = moveUp ? +1 : -1
    let getNextMonth = Calendar.current.date(byAdding: .month, value: nextPage, to: calendar.currentPage)!
    calendarHeaderView.onChangedMonth.onNext(getNextMonth)
    calendar.setCurrentPage(getNextMonth, animated: true)
  }

  private func configureCalendar() {
    calendar.calendarWeekdayView.weekdayLabels[0].textColor = .idorm_red
    calendar.calendarWeekdayView.weekdayLabels[6].textColor = .idorm_red
  }
}

extension CalendarCollectionHeaderView: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
}
