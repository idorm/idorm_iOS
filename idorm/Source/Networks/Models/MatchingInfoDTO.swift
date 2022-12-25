//
//  MatchingInfoDTO.swift
//  idorm
//
//  Created by 김응철 on 2022/12/19.
//

import Foundation

struct MatchingInfoDTO: Codable {}

extension MatchingInfoDTO {
  struct Save: Codable {
    var dormNum: Dormitory = .no1
    var joinPeriod: JoinPeriod = .period_16
    var gender: Gender = .female
    var age: String = ""
    var isSnoring: Bool = false
    var isGrinding: Bool = false
    var isSmoking: Bool = false
    var isAllowedFood: Bool = false
    var isWearEarphones: Bool = false
    var wakeupTime: String = ""
    var cleanUpStatus: String = ""
    var showerTime: String = ""
    var mbti: String?
    var wishText: String?
    var openKakaoLink: String = ""
  }
  
  struct Retrieve: Codable {
    var id: Int?
    var dormNum: Dormitory = .no1
    var joinPeriod: JoinPeriod = .period_16
    var gender: Gender = .female
    var age: Int = 0
    var isSnoring: Bool = false
    var isGrinding: Bool = false
    var isSmoking: Bool = false
    var isAllowedFood: Bool = false
    var isWearEarphones: Bool = false
    var wakeUpTime: String = ""
    var cleanUpStatus: String = ""
    var showerTime: String = ""
    var openKakaoLink: String = ""
    var mbti: String?
    var wishText: String?
    var isMatchingInfoPublic: Bool = false
    var memberEmail: String = ""
  }
}
