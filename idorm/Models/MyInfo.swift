//
//  Onboarding.swift
//  idorm
//
//  Created by 김응철 on 2022/07/23.
//

import Foundation

struct MyInfo {
  var dormNumber: Dormitory
  var period: JoinPeriod
  var gender: Gender
  var age: String
  var snoring: Bool
  var grinding: Bool
  var smoke: Bool
  var allowedFood: Bool
  var earphone: Bool
  var wakeupTime: String
  var cleanUpStatus: String
  var showerTime: String
  var mbti: String?
  var wishText: String?
  var chatLink: String?
}

enum Dormitory {
  case no1
  case no2
  case no3
  
  var getString: String {
    switch self {
    case .no1:
      return "1 기숙사"
    case .no2:
      return "2 기숙사"
    case .no3:
      return "3 기숙사"
    }
  }
}

enum JoinPeriod {
  case period_16
  case period_24
  
  var getString: String {
    switch self {
    case .period_16:
      return "16 주"
    case .period_24:
      return "24 주"
    }
  }
}

enum Gender {
  case male
  case female
  
  var getString: String {
    switch self {
    case .male:
      return "남성"
    case .female:
      return "여성"
    }
  }
}
