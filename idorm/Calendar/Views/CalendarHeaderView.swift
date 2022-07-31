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

class CalendarHeaderView: UICollectionReusableView {
  lazy var calendarHeaderView: CustomCalendarHeaderView = {
    let view = CustomCalendarHeaderView()
    view.configureUI(date: Date.now)
    
    return view
  }()
  
  lazy var calendarGrid: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    let grid = UICollectionView(frame: .zero, collectionViewLayout: layout)
    grid.backgroundColor = .white
    grid.register(CustomCalendarCell.self, forCellWithReuseIdentifier: CustomCalendarCell.identifier)
    grid.isScrollEnabled = false
    grid.delegate = self
    grid.dataSource = self
    
    return grid
  }()
  
  static let identifier = "CalendarHeaderView"
  let disposeBag = DisposeBag()
  var totalSquares = [String]()
  var selectedDate = Date()
  
  // MARK: - LifeCycle
  override init(frame: CGRect) {
    super.init(frame: frame)
    bind()
    setMonthValue()
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
    [ calendarHeaderView, calendarGrid ]
      .forEach { addSubview($0) }
    
    calendarHeaderView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
    }
    
    calendarGrid.snp.makeConstraints { make in
      make.top.equalTo(calendarHeaderView.snp.bottom)
      make.leading.trailing.equalToSuperview().inset(24)
      make.bottom.equalToSuperview()
    }
  }
  
  private func setMonthValue() {
    totalSquares.removeAll()
    let daysInMonth = CalendarUtilities().daysInMonth(date: selectedDate)
    let firstDayOfMonth = CalendarUtilities().firstOfMonth(date: selectedDate)
    let startingSpaces = CalendarUtilities().weekDay(date: firstDayOfMonth)
    
    var count: Int = 1
    
    while(count <= 42) {
      if (count <= startingSpaces || count - startingSpaces > daysInMonth) {
        totalSquares.append("")
      } else {
        totalSquares.append(String(count - startingSpaces))
      }
      count += 1
    }
    calendarHeaderView.monthLabel.text = CalendarUtilities().monthString(date: selectedDate)
    calendarGrid.reloadData()
  }
  
  private func moveCurrentPage(moveUp: Bool) {
    selectedDate = moveUp ? CalendarUtilities().plusMonth(date: selectedDate) : CalendarUtilities().minusMonth(date: selectedDate)
    setMonthValue()
  }
  
  private func datesRange(from: Date, to: Date) -> [Date] {
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

extension CalendarHeaderView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return totalSquares.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCalendarCell.identifier, for: indexPath) as! CustomCalendarCell
    cell.configureUI(dayOfMonth: totalSquares[indexPath.row])
    return cell
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
}
