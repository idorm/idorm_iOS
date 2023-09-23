//
//  MatchingInfoRequestDTO.swift
//  idorm
//
//  Created by 김응철 on 9/20/23.
//

import Foundation

struct MatchingInfoRequestDTO: Encodable {
  let dormCategory: Dormitory
  let joinPeriod: JoinPeriod
  let gender: Gender
  let age: Int
  let isSnoring: Bool
  let isGrinding: Bool
  let isSmoking: Bool
  let isAllowedFood: Bool
  let isWearEarphones: Bool
  let wakeupTime: String
  let cleanUpStatus: String
  let showerTime: String
  let openKakaoLink: String
  let mbti: String
  let wishText: String
  
  init(_ matchingInfo: MatchingInfo) {
    self.dormCategory = matchingInfo.dormCategory
    self.joinPeriod = matchingInfo.joinPeriod
    self.gender = matchingInfo.gender
    self.age = Int(matchingInfo.age) ?? 0
    self.isSnoring = matchingInfo.isSnoring
    self.isGrinding = matchingInfo.isGrinding
    self.isSmoking = matchingInfo.isSmoking
    self.isAllowedFood = matchingInfo.isAllowedFood
    self.isWearEarphones = matchingInfo.isWearEarphones
    self.wakeupTime = matchingInfo.wakeUpTime
    self.cleanUpStatus = matchingInfo.cleanUpStatus
    self.showerTime = matchingInfo.showerTime
    self.openKakaoLink = matchingInfo.openKakaoLink
    self.mbti = matchingInfo.mbti
    self.wishText = matchingInfo.wishText
  }
}
