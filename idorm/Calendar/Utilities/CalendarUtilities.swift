//
//  CalendarUtilities.swift
//  idorm
//
//  Created by 김응철 on 2022/08/01.
//

import UIKit

class CalendarUtilities {
  let calendar = Calendar.current

  func plusMonth(date: Date) -> Date {
    return calendar.date(byAdding: .month, value: 1, to: date)!
  }

  func minusMonth(date: Date) -> Date {
    return calendar.date(byAdding: .month, value: -1, to: date)!
  }

  func monthString(date: Date) -> String {
    let dateformatter = DateFormatter()
    dateformatter.dateFormat = "M월"
    return dateformatter.string(from: date)
  }
  
  func daysInMonth(date: Date) -> Int {
    let range = calendar.range(of: .day, in: .month, for: date)!
    return range.count
  }
  
  func firstOfMonth(date: Date) -> Date {
    let components = calendar.dateComponents([.year, .month], from: date)
    return calendar.date(from: components)!
  }
  
  func weekDay(date: Date) -> Int {
    let components = calendar.dateComponents([.weekday], from: date)
    return components.weekday! - 1
  }
}

final class CustomCollectionView: UICollectionView {
//  override var intrinsicContentSize: CGSize {
//    return contentSize
//  }
//
//  override func layoutSubviews() {
//    super.layoutSubviews()
//    if !__CGSizeEqualToSize(bounds.size, self.intrinsicContentSize) {
//      self.invalidateIntrinsicContentSize()
//    }
//  }

  override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
    super.init(frame: frame, collectionViewLayout: layout)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
