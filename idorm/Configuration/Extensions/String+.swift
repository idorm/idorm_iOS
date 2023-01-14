//
//  String+Extensions.swift
//  idorm
//
//  Created by 김응철 on 2022/11/24.
//

import Foundation

extension String {
  func isValidEmailCondition() -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: self)
  }
  
  func isValidCompoundCondition() -> Bool {
    let passwordRegEx = "^(?=.*[a-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{0,}"
    let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
    return passwordTest.evaluate(with: self)
  }
  
  var isValidPasswordCondition: Bool {
    let passwordRegEx = "^(?=.*[a-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,20}"
    let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
    return passwordTest.evaluate(with: self)
  }
  
  static var version: String {
    return "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)"
  }
  
  var isValidNickname: Bool {
    // String -> Array
    let arr = Array(self)
    // 정규식 pattern. 한글, 영어, 숫자, 밑줄(_)만 있어야함
    let pattern = "^[가-힣ㄱ-ㅎㅏ-ㅣa-zA-Z0-9_]$"
    if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
      var index = 0
      while index < arr.count { // string 내 각 문자 하나하나 마다 정규식 체크 후 충족하지 못한것은 제거.
        let results = regex.matches(in: String(arr[index]), options: [], range: NSRange(location: 0, length: 1))
        if results.count == 0 {
          return false
        } else {
          index += 1
        }
      }
    }
    return true
  }
  
  var isValidKakaoLink: Bool {
    return self.contains("https://open.kakao.com/")
  }
  
  var checkForUrls: [URL] {
    let types: NSTextCheckingResult.CheckingType = .link
    
    do {
      let detector = try NSDataDetector(types: types.rawValue)
      
      let matches = detector.matches(in: self, options: .reportCompletion, range: NSMakeRange(0, self.count))
      
      return matches.compactMap({$0.url})
    } catch let error {
      debugPrint(error.localizedDescription)
    }
    
    return []
  }
}
