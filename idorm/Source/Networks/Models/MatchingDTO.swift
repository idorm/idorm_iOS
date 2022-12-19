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
    let dormNum: Dormitory
    let isAllowedFood: Bool
    let isGrinding: Bool
    let isSmoking: Bool
    let isSnoring: Bool
    let isWearEarphones: Bool
    let joinPeriod: JoinPeriod
    let minAge: Int
    let maxAge: Int
  }
}
