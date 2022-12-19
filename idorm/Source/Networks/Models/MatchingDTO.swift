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
}
