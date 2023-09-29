//
//  MatchingInfoRequestModel.swift
//  idorm
//
//  Created by 김응철 on 2023/01/27.
//

import Foundation

enum MatchingInfoRequestModel {}

extension MatchingInfoRequestModel {
  struct MatchingInfo: Codable {
    var dormCategory: Dormitory = .no1
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
}
