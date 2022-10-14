//
//  Onboarding.swift
//  idorm
//
//  Created by 김응철 on 2022/07/23.
//

import Foundation

struct MatchingInfo {
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

enum Dormitory: String {
  case no1 = "1 기숙사"
  case no2 = "2 기숙사"
  case no3 = "3 기숙사"
  
  var getString: String {
    switch self {
    case .no1:
      return "DORM1"
    case .no2:
      return "DORM2"
    case .no3:
      return "DORM3"
    }
  }
}

enum JoinPeriod: String {
  case period_16 = "16 주"
  case period_24 = "24 주"
  
  var getString: String {
    switch self {
    case .period_16:
      return "WEEK16"
    case .period_24:
      return "WEEK24"
    }
  }
}

enum Gender: String {
  case male = "남자"
  case female = "여자"
  
  var getString: String {
    switch self {
    case .male:
      return "MALE"
    case .female:
      return "FEMALE"
    }
  }
}
