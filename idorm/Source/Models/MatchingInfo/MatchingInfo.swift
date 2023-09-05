//
//  MatchingInfo.swift
//  idorm
//
//  Created by 김응철 on 9/5/23.
//

import Foundation

struct MatchingInfo {
  /// 이 매칭 정보의 식별자
  let identifier: Int
  /// 나이
  let age: Int
  /// 청결 상태
  let cleanUpStatus: String
  /// 기숙사 종류
  let dormCategory: Dormitory
  /// 성별
  let gender: Gender
  /// 음식 허용 여부
  let isAllowedFood: Bool
  /// 이갈이 여부
  let isGrinding: Bool
  /// 매칭 정보 공개 여부
  let isMatchingInfoPublic: Bool
  /// 흡연 여부
  let isSmoking: Bool
  /// 코골이 여부
  let isSnoring: Bool
  /// 이어폰 여부
  let isWearEarphones: Bool
  /// 입사 기간
  let joinPeriod: JoinPeriod
  /// MBTI
  let mbti: String?
  /// 멤버의 이메일 주소
  let memberEmail: String
  /// 오픈 카카오톡 링크
  let openKakaoLink: String
  /// 샤워 시간
  let showerTime: String
  /// 기상 시간
  let wakeUpTime: String
  /// 하고 싶은 말
  let wishText: String
  
  /// `MatchingInfoSingleReseponeDTO` -> `MatchingInfo`
  init(_ responseDTO: MatchingInfoSingleReseponeDTO) {
    self.identifier = responseDTO.matchingInfoId
    self.age = responseDTO.age
    self.cleanUpStatus = responseDTO.cleanUpStatus
    self.dormCategory = responseDTO.dormCategory
    self.gender = responseDTO.gender
    self.isAllowedFood = responseDTO.isAllowedFood
    self.isGrinding = responseDTO.isGrinding
    self.isMatchingInfoPublic = responseDTO.isMatchingInfoPublic
    self.isSmoking = responseDTO.isSmoking
    self.isSnoring = responseDTO.isSnoring
    self.isWearEarphones = responseDTO.isWearEarphones
    self.joinPeriod = responseDTO.joinPeriod
    self.mbti = responseDTO.mbti
    self.memberEmail = responseDTO.memberEmail
    self.openKakaoLink = responseDTO.openKakaoLink
    self.showerTime = responseDTO.showerTime
    self.wakeUpTime = responseDTO.wakeUpTime
    self.wishText = responseDTO.wishText
  }
}
