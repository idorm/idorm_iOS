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

class MainCalendarCollectionHeaderView: UICollectionReusableView {
  lazy var calendar: FSCalendar = {
    let calendar = FSCalendar()
    calendar.scope = .month
    calendar.locale = Locale(identifier: "ko_KR")
    
    calendar.appearance.headerTitleFont = .init(name: Font.medium.rawValue, size: 16)
    calendar.appearance.headerTitleColor = .black
    calendar.appearance.headerDateFormat = "M월"
    
    calendar.appearance.weekdayFont = .init(name: Font.regular.rawValue, size: 12)
    calendar.appearance.weekdayTextColor = .idorm_gray_400
    
    calendar.appearance.titleFont = .init(name: Font.regular.rawValue, size: 12)
    
    calendar.scrollDirection = .horizontal
    calendar.scrollEnabled = true
    
    return calendar
  }()
  
  static let identifier = "MainCalendarCollectionHeaderView"
  
  // MARK: - LifeCycle
  
  // MARK: - Helpers
  func configureUI() {
    addSubview(calendar)
    
    calendar.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalToSuperview()
      make.height.equalTo(300)
    }
  }
}
