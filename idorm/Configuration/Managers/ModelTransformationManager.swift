//
//  ModelTransformationManager.swift
//  idorm
//
//  Created by 김응철 on 2022/12/25.
//

import Foundation

final class ModelTransformationManager {
  
  static func transformToMatchingDTO_RETRIEVE(_ from: MatchingInfoDTO.Save) -> MatchingDTO.Retrieve {
    var newOne = MatchingDTO.Retrieve()
    
    newOne.dormNum = from.dormNum
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
  
  static func transformToMatchingInfoDTO_SAVE(_ from: MatchingDTO.Retrieve) -> MatchingInfoDTO.Save {
    var newOne = MatchingInfoDTO.Save()
    
    newOne.dormNum = from.dormNum
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
