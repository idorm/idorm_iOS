//
//  MatchingMateFilterRequestDTO.swift
//  idorm
//
//  Created by 김응철 on 9/23/23.
//

import Foundation

struct MatchingMateFilterRequestDTO: Encodable {
  let dormCategory: Dormitory
  let joinPeriod: JoinPeriod
  let minAge: Int
  let maxAge: Int
  let isSnoring: Bool
  let isGrinding: Bool
  let isSmoking: Bool
  let isAllowedFood: Bool
  let isWearEarphones: Bool
}
