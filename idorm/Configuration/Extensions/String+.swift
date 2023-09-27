//
//  String+Extensions.swift
//  idorm
//
//  Created by 김응철 on 2022/11/24.
//

import Foundation
import OSLog

// MARK: - Validation

extension String {
//  func isValidEmailCondition() -> Bool {
//    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
//    let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
//    return emailTest.evaluate(with: self)
//  }
//  
//  func isValidCompoundCondition() -> Bool {
//    let passwordRegEx = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]).{0,}"
//    let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
//    return passwordTest.evaluate(with: self)
//  }
//  
//  var isValidPasswordCondition: Bool {
//    let passwordRegEx = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]).{8,15}"
//    let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
//    return passwordTest.evaluate(with: self)
//  }
//  
//  static var version: String {
//    return "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)"
//  }
//  
//  var isValidNickname: Bool {
//    // String -> Array
//    let arr = Array(self)
//    // 정규식 pattern. 한글, 영어, 숫자, 밑줄(_)만 있어야함
//    let pattern = "^[가-힣ㄱ-ㅎㅏ-ㅣa-zA-Z0-9_]$"
//    if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
//      var index = 0
//      while index < arr.count { // string 내 각 문자 하나하나 마다 정규식 체크 후 충족하지 못한것은 제거.
//        let results = regex.matches(in: String(arr[index]), options: [], range: NSRange(location: 0, length: 1))
//        if results.count == 0 {
//          return false
//        } else {
//          index += 1
//        }
//      }
//    }
//    return true
//  }
//  
//  var isValidKakaoLink: Bool {
//    return self.contains("https://open.kakao.com/")
//  }
//  
//  var checkForUrls: [URL] {
//    let types: NSTextCheckingResult.CheckingType = .link
//    
//    do {
//      let detector = try NSDataDetector(types: types.rawValue)
//      
//      let matches = detector.matches(in: self, options: .reportCompletion, range: NSMakeRange(0, self.count))
//      
//      return matches.compactMap({$0.url})
//    } catch let error {
//      debugPrint(error.localizedDescription)
//    }
//    
//    return []
//  }
}

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
