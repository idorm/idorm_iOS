//
//  ModelTransformationManager.swift
//  idorm
//
//  Created by 김응철 on 2022/12/25.
//

import Foundation

final class TransformUtils {
  
  static func transfer(
    _ from: MatchingInfoRequestModel.MatchingInfo
  ) -> MatchingResponseModel.Member {
    var newOne = MatchingResponseModel.Member()
    
    newOne.dormCategory = from.dormCategory
    newOne.gender = from.gender
    newOne.joinPeriod = from.joinPeriod
    newOne.isSmoking = from.isSmoking
    newOne.isSnoring = from.isSnoring
    newOne.isGrinding = from.isGrinding
    newOne.isAllowedFood = from.isAllowedFood
    newOne.isWearEarphones = from.isWearEarphones
    newOne.wakeUpTime = from.wakeupTime
    newOne.showerTime = from.showerTime
    newOne.cleanUpStatus = from.cleanUpStatus
    newOne.age = Int(from.age) ?? 0
    newOne.mbti = from.mbti
    newOne.openKakaoLink = from.openKakaoLink
    newOne.wishText = from.wishText
    
    return newOne
  }
  
  static func transfer(
    _ from: MatchingInfoResponseModel.MatchingInfo
  ) -> MatchingResponseModel.Member {
    var newOne = MatchingResponseModel.Member()
    
    newOne.dormCategory = from.dormCategory
    newOne.gender = from.gender
    newOne.joinPeriod = from.joinPeriod
    newOne.isSmoking = from.isSmoking
    newOne.isSnoring = from.isSnoring
    newOne.isGrinding = from.isGrinding
    newOne.isAllowedFood = from.isAllowedFood
    newOne.isWearEarphones = from.isWearEarphones
    newOne.wakeUpTime = from.wakeUpTime
    newOne.showerTime = from.showerTime
    newOne.cleanUpStatus = from.cleanUpStatus
    newOne.age = from.age
    newOne.mbti = from.mbti
    newOne.openKakaoLink = from.openKakaoLink
    newOne.wishText = from.wishText
    
    return newOne
  }
  
  static func transfer(
    _ from: MatchingResponseModel.Member
  ) -> MatchingInfoRequestModel.MatchingInfo {
    var newOne = MatchingInfoRequestModel.MatchingInfo()
    
    newOne.dormCategory = from.dormCategory
    newOne.gender = from.gender
    newOne.joinPeriod = from.joinPeriod
    newOne.isSmoking = from.isSmoking
    newOne.isSnoring = from.isSnoring
    newOne.isGrinding = from.isGrinding
    newOne.isAllowedFood = from.isAllowedFood
    newOne.isWearEarphones = from.isWearEarphones
    newOne.wakeupTime = from.wakeUpTime
    newOne.showerTime = from.showerTime
    newOne.cleanUpStatus = from.cleanUpStatus
    newOne.age = String(from.age)
    newOne.mbti = from.mbti
    newOne.openKakaoLink = from.openKakaoLink
    newOne.wishText = from.wishText
    
    return newOne
  }
}
