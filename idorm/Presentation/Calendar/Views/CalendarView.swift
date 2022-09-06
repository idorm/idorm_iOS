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

enum CalendarViewType {
  case main
  case set
}

class CalendarView: UIView {
  lazy var calendarGrid: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    let grid = UICollectionView(frame: .zero, collectionViewLayout: layout)
    grid.backgroundColor = .white
    grid.register(CustomCalendarCell.self, forCellWithReuseIdentifier: CustomCalendarCell.identifier)
    grid.isScrollEnabled = false
    grid.delegate = self
    
    return grid
  }()
  
  lazy var weekdayHeaderView: WeekdayCalendarView = {
    let view = WeekdayCalendarView()
    view.configureUI()
    
    return view
  }()

//  static let identifier = "CalendarHeaderView"
  
  let type: CalendarViewType
  let disposeBag = DisposeBag()
  
  /// 월의 일 수 String 배열
  /// 캘린더의 실질적인 데이터 값
  let totalSquaresRelay = BehaviorRelay<[String]>(value: [])
  /// 월이 바뀌는 Date
  var nextDate = Date()
  /// 1일 전에 빈 칸 갯수
  var currentWeekDay: Int = 0
  /// 현재 선택된 날짜
  var selectedDate: Date?
  let selectedDateSubject = PublishSubject<Date>()
  
  // MARK: - LifeCycle
  init(type: CalendarViewType) {
    self.type = type
    super.init(frame: .zero)
    setMonthValue()
    configureUI()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Bind
  private func bind() {
    /// 월 바꾸기 ( 왼쪽 )
    weekdayHeaderView.leftArrowButton.rx.tap
      .map { false }
      .bind(onNext: { [weak self] in
        self?.moveCurrentPage(moveUp: $0)
      })
      .disposed(by: disposeBag)
    
    /// 월 바꾸기 ( 오른쪽 )
    weekdayHeaderView.rightArrowButton.rx.tap
      .map { true }
      .bind(onNext: { [weak self] in
        self?.moveCurrentPage(moveUp: $0)
      })
      .disposed(by: disposeBag)
    
    /// 캘린더 셀 생성
    totalSquaresRelay
      .bind(to: calendarGrid.rx.items(cellIdentifier: CustomCalendarCell.identifier, cellType: CustomCalendarCell.self)) { [weak self] index, dayOfMonthString, cell in
        guard let self = self else { return }
        let dayOfMonth = self.totalSquaresRelay.value[index]
        
        let calendar = Calendar.current
        let todayYear = calendar.component(.year, from: .now)
        let todayMonth = calendar.component(.month, from: .now)
        let todayDay = calendar.component(.day, from: .now)
        let currentYear = calendar.component(.year, from: self.nextDate)
        let currentMonth = calendar.component(.month, from: self.nextDate)
        
        if self.type == .set {
          if let selectedDate = self.selectedDate {
            let selectedYear = calendar.component(.year, from: selectedDate)
            let selectedMonth = calendar.component(.month, from: selectedDate)
            let selectedDay = calendar.component(.day, from: selectedDate)
            if currentYear == selectedYear, currentMonth == selectedMonth, index == selectedDay + ( self.currentWeekDay ) {
              cell.configureUI(dayOfMonth: dayOfMonth, type: [.set])
            } else {
              cell.configureUI(dayOfMonth: dayOfMonth, type: [.none])
            }
          } else {
            if currentYear == todayYear, currentMonth == todayMonth, index == todayDay + ( self.currentWeekDay - 1 ) {
              cell.configureUI(dayOfMonth: dayOfMonth, type: [.set])
            } else {
              cell.configureUI(dayOfMonth: dayOfMonth, type: [.none])
            }
          }
        } else {
          if index < self.currentWeekDay {
            cell.configureUI(dayOfMonth: dayOfMonth, type: [.none])
          }
          
          if currentYear == todayYear, currentMonth == todayMonth, index == todayDay + ( self.currentWeekDay - 1 ){
            cell.configureUI(dayOfMonth: dayOfMonth, type: [.today])
          }
          
          if index == 20 {
            cell.configureUI(dayOfMonth: dayOfMonth, type: [.dorm, .personal])
          } else {
            cell.configureUI(dayOfMonth: dayOfMonth, type: [.none])
          }
        }
      }
      .disposed(by: disposeBag)
    
    /// 캘린더 특정 날짜 선택할 때
    if type == .set {
      calendarGrid.rx.itemSelected
        .bind(onNext: { [weak self] indexPath in
          guard let self = self else { return }
          if self.totalSquaresRelay.value[indexPath.row] != "" {
            let selectedCell = self.calendarGrid.cellForItem(at: indexPath) as! CustomCalendarCell
            let cells = self.calendarGrid.visibleCells as! [CustomCalendarCell]
            cells.forEach { cell in
              cell.squareBackgroundView.isHidden = true
              cell.dayOfMonthLabel.textColor = .idorm_gray_400
            }
            selectedCell.squareBackgroundView.isHidden = false
            selectedCell.dayOfMonthLabel.textColor = .white
            
            let calendar = Calendar.current
            let timezone = TimeZone(secondsFromGMT: 0)!

            var dateComponents = DateComponents()
            dateComponents.timeZone = timezone
            dateComponents.year = calendar.component(.year, from: self.nextDate)
            dateComponents.month = calendar.component(.month, from: self.nextDate)
            dateComponents.day = indexPath.row - ( self.currentWeekDay ) + 1
            self.selectedDate = calendar.date(from: dateComponents)!
            self.selectedDateSubject.onNext(self.selectedDate ?? Date.now)
          } else {
            return
          }
        })
        .disposed(by: disposeBag)
    } else {
      
    }
  }
  
  // MARK: - Helpers
  func configureUI() {
    [ weekdayHeaderView, calendarGrid ]
      .forEach { addSubview($0) }
    
    if type == .set {
      weekdayHeaderView.backgroundColor = .white
    }
    
    weekdayHeaderView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
    }
    
    calendarGrid.snp.makeConstraints { make in
      make.top.equalTo(weekdayHeaderView.snp.bottom)
      make.leading.trailing.equalToSuperview().inset(24)
      make.height.equalTo(200)
      make.bottom.equalToSuperview()
    }
  }
  
  private func setMonthValue() {
    totalSquaresRelay.accept([])
    let daysInMonth = CalendarUtilities().daysInMonth(date: nextDate)
    let firstDayOfMonth = CalendarUtilities().firstOfMonth(date: nextDate)
    let startingSpaces = CalendarUtilities().weekDay(date: firstDayOfMonth)
    self.currentWeekDay = startingSpaces
    
    var count: Int = 1
    
    while(count <= 42) {
      if count <= startingSpaces {
        totalSquaresRelay.accept(totalSquaresRelay.value + [""])
      } else if count - startingSpaces > daysInMonth {
        break
      } else {
        totalSquaresRelay.accept(totalSquaresRelay.value + [String(count - startingSpaces)])
      }
      count += 1
    }
    weekdayHeaderView.monthLabel.text = CalendarUtilities().monthString(date: nextDate)
    calendarGrid.reloadData()
  }
  
  private func moveCurrentPage(moveUp: Bool) {
    nextDate = moveUp ? CalendarUtilities().plusMonth(date: nextDate) : CalendarUtilities().minusMonth(date: nextDate)
    setMonthValue()
    calendarGrid.snp.updateConstraints { make in
      make.height.equalTo(calendarGrid.collectionViewLayout.collectionViewContentSize.height)
    }
  }
  
  //  private func datesRange(from: Date, to: Date) -> [Date] {
  //    if from > to { return [Date]() }
  //    var tempDate = from
  //    var array = [tempDate]
  //
  //    while tempDate > to {
  //      tempDate = Calendar.current.date(byAdding: .day, value: 1, to: tempDate)!
  //      array.append(tempDate)
  //    }
  //
  //    return array
  //  }
}

extension CalendarView: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return totalSquaresRelay.value.count
  }
  
  /// Grid ItemSize
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = collectionView.frame.width / 7
    let height = width * ( 39 / 46 )
    return CGSize(width: width, height: height)
  }
  
  /// InteritemSpacing
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let calendarPostView = UINavigationController(rootViewController: CalendarPostViewController())
  }
}
