//
//  MatchingMateResponseDTO.swift
//  idorm
//
//  Created by 김응철 on 9/23/23.
//

import Foundation

struct MatchingMateResponseDTO: Decodable {
  let memberId: Int
  let matchingInfoId: Int
  let dormCategory: Dormitory
  let joinPeriod: JoinPeriod
  let gender: Gender
  let age: Int
  let isSnoring: Bool
  let isGrinding: Bool
  let isSmoking: Bool
  let isAllowedFood: Bool
  let isWearEarphones: Bool
  let wakeUpTime: String
  let cleanUpStatus: String
  let showerTime: String
  let openKakaoLink: String
  let mbti: String
  let wishText: String
  let isMatchingInfoPublic: Bool
}
