//
//  MatchingInfoFilter.swift
//  idorm
//
//  Created by 김응철 on 9/25/23.
//

import Foundation

struct MatchingInfoFilter {
  var dormitory: Dormitory
  var joinPeriod: JoinPeriod 
  var isSnoring: Bool = false
  var isGrinding: Bool = false
  var isSmoking: Bool = false
  var isAllowedFood: Bool = false
  var isAllowedEarphones: Bool = false
  var minAge: Int = 20
  var maxAge: Int = 30
}
