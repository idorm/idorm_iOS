//
//  ValidationManager.swift
//  idorm
//
//  Created by 김응철 on 9/10/23.
//

import Foundation

enum ValidationType {
  case email
  case password
  case passwordOnlyCompoundCondition
  case nickname
  
  var expression: String {
    switch self {
    case .email:
      return "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    case .password:
      return "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,15}$"
    case .passwordOnlyCompoundCondition:
      return "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{0,}$"
    case .nickname:
      return "^[a-zA-Z0-9가-힣_]+$"
    }
  }
}

/// 특정 String을 정규식 표현에 맞게 되었는지 판단해주는 매니저 객체입니다.
final class ValidationManager {
  
  /// 특정 String값이 `Validation`이 잘 되었는지 판단하는 메서드입니다.
  static func validate(_ target: String, validationType: ValidationType) -> Bool {
    let expression = validationType.expression
    let emailPredicate = NSPredicate(format:"SELF MATCHES %@", expression)
    return emailPredicate.evaluate(with: target)
  }
}
