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
  case no1 = "기숙사1"
  case no2 = "기숙사2"
  case no3 = "기숙사3"
  
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

enum JoinPeriod: String {
  case period_16 = "WEEK16"
  case period_24 = "WEEK24"
  
  var getString: String {
    switch self {
    case .period_16:
      return "16 주"
    case .period_24:
      return "24 주"
    }
  }
}

enum Gender: String {
  case male = "MALE"
  case female = "FEMALE"
  
  var getString: String {
    switch self {
    case .male:
      return "남성"
    case .female:
      return "여성"
    }
  }
}
