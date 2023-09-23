//
//  MatchingInfoSingleReseponeDTO.swift
//  idorm
//
//  Created by 김응철 on 9/1/23.
//

import Foundation

struct MatchingInfoResponseDTO: Decodable {
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
  let memberEmail: String
}
