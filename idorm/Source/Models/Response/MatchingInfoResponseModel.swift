//
//  MatchingInfoResponseModel.swift
//  idorm
//
//  Created by 김응철 on 2023/01/27.
//

import Foundation

enum MatchingInfoResponseModel {}

extension MatchingInfoResponseModel {
  struct MatchingInfo: Codable {
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
