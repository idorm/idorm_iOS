//
//  MatchingRequestModel.swift
//  idorm
//
//  Created by 김응철 on 2023/01/27.
//

import Foundation

enum MatchingRequestModel {}

extension MatchingRequestModel {
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
