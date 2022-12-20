//
//  MatchingDTO.swift
//  idorm
//
//  Created by 김응철 on 2022/12/19.
//

import Foundation

struct MatchingDTO: Codable {}

extension MatchingDTO {
  struct Filter: Codable {
    var dormNum: Dormitory = .no1
    var isAllowedFood: Bool = false
    var isGrinding: Bool = false
    var isSmoking: Bool = false
    var isSnoring: Bool = false
    var isWearEarphones: Bool = false
    var joinPeriod: JoinPeriod = .period_16
    var minAge: Int = 20
    var maxAge: Int = 30
  }
  
  struct Retrieve: Codable {
    var memberId: Int
    var matchingInfoId: Int
    var dormNum: Dormitory
    var joinPeriod: JoinPeriod
    var gender: Gender
    var age: Int
    var isSnoring: Bool
    var isGrinding: Bool
    var isSmoking: Bool
    var isAllowedFood: Bool
    var isWearEarphones: Bool
    var wakeUpTime: String
    var cleanUpStatus: String
    var showerTime: String
    var openKakaoLink: String
    var mbti: String
    var wishText: String
    var addedAt: String?
  }
}
