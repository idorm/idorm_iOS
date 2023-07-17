//
//  iDormCalendar.swift
//  idorm
//
//  Created by 김응철 on 7/7/23.
//

import UIKit

import FSCalendar
import SnapKit
import RxSwift
import RxCocoa

protocol iDormCalendarDelegate: AnyObject {
  func monthDidChage(_ nextDate: Date)
}

/// 일정을 볼 수 있는 메인 캘린더입니다.
final class iDormCalendar: UIView, BaseView {
  
  enum ViewType {
    /// 메인이 되는 캘린더입니다.
    case main
    /// 바텀시트에 필요한 캘린더입니다.
    case sub
  }
  
  // MARK: - UI Components
  
  private let leftButton: UIButton = {
    let btn = UIButton()
    btn.setImage(.iDormIcon(.left), for: .normal)
    return btn
  }()
  
  private let rightButton: UIButton = {
    let btn = UIButton()
    btn.setImage(.iDormIcon(.right), for: .normal)
    return btn
  }()
  
  /// 메인이 되는 달력 UI입니다.
  private lazy var calendar: FSCalendar = {
    let calendar = FSCalendar()
    // 기본 설정
    calendar.scrollEnabled = false
    calendar.delegate = self
    calendar.dataSource = self
    calendar.register(iDormCalendarCell.self, forCellReuseIdentifier: iDormCalendarCell.identifier)
    
    // 일
    calendar.appearance.titleFont = .idormFont(.regular, size: 12)
    calendar.appearance.titleDefaultColor = .idorm_gray_400
    
    // 주
    calendar.appearance.weekdayFont = .idormFont(.regular, size: 12)
    calendar.appearance.weekdayTextColor = .idorm_gray_400
    calendar.locale = Locale(identifier: "ko_KR")
    
    // 달
    calendar.appearance.headerTitleFont = .idormFont(.medium, size: 16)
    calendar.appearance.headerTitleColor = .black
    calendar.appearance.headerDateFormat = "M월"
    calendar.headerHeight = 52.0
    calendar.appearance.headerMinimumDissolvedAlpha = 0.0
    calendar.appearance.headerTitleOffset = CGPoint(x: 0, y: -4)
    calendar.placeholderType = .none
    
    // 선택
    calendar.appearance.todayColor = .idorm_gray_200
    calendar.appearance.titleTodayColor = .idorm_gray_400
    calendar.appearance.borderSelectionColor = .iDormColor(.iDormBlue)
    
    switch self.viewType {
    case .main:
      calendar.isUserInteractionEnabled = false
    case .sub:
      break
    }
    
    return calendar
  }()
  
  /// 둥근 모서리가 포함되어있는 콘테이너 뷰입니다.
  private let containerView: UIView = {
    let view = UIView()
    view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    view.layer.cornerRadius = 24.0
    view.backgroundColor = .white
    return view
  }()
  
  // MARK: - Properties
  
  private var disposeBag = DisposeBag()
  
  weak var delegate: iDormCalendarDelegate?
  
  /// 현재 캘린더에 적용된 타입니다.
  private let viewType: ViewType

  // MARK: - Initializer
  
  init(_ viewType: ViewType) {
    self.viewType = viewType
    super.init(frame: .zero)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
    self.bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycle
  
  // MARK: - Setup
  
  func setupStyles() {
    // 일요일과 토요일 레이블의 색상을 빨간색으로 바꿉니다.
    self.calendar.calendarWeekdayView.weekdayLabels.first!.textColor = .idorm_red
    self.calendar.calendarWeekdayView.weekdayLabels.last!.textColor = .idorm_red
    
    switch self.viewType {
    case .main:
      self.backgroundColor = .iDormColor(.iDormGray100)
    case .sub:
      self.backgroundColor = .white
    }
  }
  
  func setupLayouts() {
    [
      self.containerView,
      self.calendar,
      self.leftButton,
      self.rightButton
    ].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.calendar.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview().inset(24.0)
      make.directionalVerticalEdges.equalToSuperview()
    }
    
    self.leftButton.snp.makeConstraints { make in
      make.centerY.equalTo(self.calendar.calendarHeaderView)
      make.leading.equalToSuperview().inset(16.0)
    }
    
    self.rightButton.snp.makeConstraints { make in
      make.centerY.equalTo(self.calendar.calendarHeaderView)
      make.trailing.equalToSuperview().inset(16.0)
    }
    
    self.containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  // MARK: - Bind
  
  private func bind() {
    // 이전 달로 바꾸기
    self.leftButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.updateCurrentPage(false)
      }
      .disposed(by: self.disposeBag)
    
    // 다음 달로 바꾸기
    self.rightButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.updateCurrentPage(true)
      }
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Functions
  
  /// 캘린더 선택 여부를 업데이트합니다.
  ///
  /// - Parameters:
  ///  - allowsSelection: 선택 여부
  func updateAllowsSelection(_ allowsSelection: Bool) {
    self.calendar.allowsSelection = allowsSelection
  }
  
  /// 캘린더의 달을 변경합니다.
  ///
  /// - Parameters:
  ///  - next: 다음 달, 이전 달을 선택할 수 있습니다.
  func updateCurrentPage(_ next: Bool) {
    var dateComponents = DateComponents()
    dateComponents.month = next ? 1 : -1
    let nextPage = Calendar.current.date(
      byAdding: dateComponents,
      to: self.calendar.currentPage
    )!
    self.calendar.setCurrentPage(nextPage, animated: true)
  }
  
  /// 일정을 받아서 달력 UI를 업데이트합니다.
  ///
  /// - Parameters:
  ///  - calendars: 서버에서 받아온 팀 일정들
  func configure(_ calendars: [TeamCalendar]) {
    let targetDates = Set(calendars.map { $0.startDate })
     
    self.calendar.visibleCells().forEach {
      // 현재 보여지고 있는 모든 셀의 날짜
      let date = self.calendar.date(for: $0)!
      
    }
  }
  
  /// 변화가 생기면, 셀을 업데이트 합니다.
  ///
  /// - Parameters:
  ///  - cell: 다시 구성할 셀입니다.
  ///  - date: 선택된 날짜입니다.
  ///  - position: 현재 달이 이번, 이전, 다음 달인지 알 수 있습니다.
  func configureCell(_ cell: FSCalendarCell, date: Date, position: FSCalendarMonthPosition) {
    
  }
}

// MARK: - FSCalendar DataSource

extension iDormCalendar: FSCalendarDataSource {
  // 새로운 `CalendarCell`을 반환합니다.
  func calendar(
    _ calendar: FSCalendar,
    cellFor date: Date,
    at position: FSCalendarMonthPosition
  ) -> FSCalendarCell {
    guard let cell = calendar.dequeueReusableCell(
      withIdentifier: iDormCalendarCell.identifier,
      for: date,
      at: position
    ) as? iDormCalendarCell else {
      fatalError("iDormCalendarCell을 참조할 수 없습니다.")
    }
    cell.configureViewType(self.viewType)
    
    return cell
  }
}

// MARK: - FSCalendar Delegate

extension iDormCalendar: FSCalendarDelegate {
  func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
    self.delegate?.monthDidChage(calendar.currentPage)
  }
}
