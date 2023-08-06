//
//  Date+.swift
//  idorm
//
//  Created by 김응철 on 7/25/23.
//

import Foundation

extension Date {
  /// 원하는 `Format`의 `String`으로 변환하는 메서드입니다.
  ///
  /// - Parameters:
  ///  - format: 원하는 `DateFormat`
  ///
  /// - Returns:
  /// `format`에 맞는 `String`
  func toString(_ format: String) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = format
    return formatter.string(from: self)
  }
}
