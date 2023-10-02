//
//  String+Extensions.swift
//  idorm
//
//  Created by 김응철 on 2022/11/24.
//

import Foundation
import OSLog

// MARK: - DateString

extension String {
  /// `Post`와 관련된 날짜로 변경합니다.
  ///
  /// - Parameters:
  ///   - isPostList: `PostListVC`인지 아닌지에 대한 판별값
  func toPostFormatString(isPostList: Bool) -> String {
    let format = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    if isPostList {
      let result: String
      let formatter = DateFormatter()
      formatter.dateFormat = format
      formatter.timeZone = .init(abbreviation: "UTC")
      let postDate = formatter.date(from: self)!
      let currentDate = formatter.date(from: Date().ISO8601Format())!
      let interval = Int(currentDate.timeIntervalSince(postDate))
      switch interval {
      case 0..<60:
        result = "방금"
      case 60..<3600:
        result = "\(interval / 60)분 전"
      case 3600..<86400:
        result = "\(interval / 3600)시간 전"
      default:
        formatter.dateFormat = "MM/dd"
        result = formatter.string(from: postDate)
      }
      return result
    } else {
      let formatter = DateFormatter()
      formatter.dateFormat = format
      formatter.timeZone = .init(abbreviation: "UTC")
      var postDate = formatter.date(from: self)!
      postDate.addTimeInterval(32400)
      formatter.dateFormat = "MM'/'dd HH:mm"
      return formatter.string(from: postDate)
    }
  }
  
  /// 날짜 형식의 `String`을 다른 날짜 형식의 `String` 값으로 변환합니다.
  ///
  /// - Parameters:
  ///  - from: 이전, 원래의 `dateFormat`
  ///  - to: 변환 하려는 `dateFormat`
  ///
  /// - returns:
  ///  원하는 형식의 날짜 형식을 가진 `String` 값
  func toDateString(from: String, to: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = from
    formatter.locale = Locale(identifier: "ko_KR")
    guard let date = formatter.date(from: self) else { return "" }
    formatter.dateFormat = to
    return formatter.string(from: date)
  }
  
  /// 날짜 형식의 `String`을 정해진 `format`의 `Date`타입으로 변환합니다.
  ///
  /// - Parameters:
  ///  - format: 원하는 날짜 형식
  ///
  /// - Returns:
  /// 원하는 날짜 형식의 `Date`타입
  func toDate(format: String) -> Date {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    guard let date = formatter.date(from: self) else { return Date() }
    return date
  }
}
