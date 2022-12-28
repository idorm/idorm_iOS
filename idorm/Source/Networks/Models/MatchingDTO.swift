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
  
  struct Retrieve: Codable, Equatable {
    var memberId: Int = 0
    var matchingInfoId: Int = 0
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
    var addedAt: String?
  }
}
