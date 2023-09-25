//
//  MatchingInfo.swift
//  idorm
//
//  Created by 김응철 on 9/5/23.
//

import Foundation

struct MatchingInfo: Codable {
  /// 이 매칭 정보의 식별자
  var identifier: Int
  /// 나이
  var age: String
  /// 청결 상태
  var cleanUpStatus: String
  /// 기숙사 종류
  var dormCategory: Dormitory
  /// 성별
  var gender: Gender
  /// 음식 허용 여부
  var isAllowedFood: Bool
  /// 이갈이 여부
  var isGrinding: Bool
  /// 매칭 정보 공개 여부
  var isMatchingInfoPublic: Bool
  /// 흡연 여부
  var isSmoking: Bool
  /// 코골이 여부
  var isSnoring: Bool
  /// 이어폰 여부
  var isWearEarphones: Bool
  /// 입사 기간
  var joinPeriod: JoinPeriod
  /// MBTI
  var mbti: String
  /// 멤버의 이메일 주소
  var memberEmail: String
  /// 오픈 카카오톡 링크
  var openKakaoLink: String
  /// 샤워 시간
  var showerTime: String
  /// 기상 시간
  var wakeUpTime: String
  /// 하고 싶은 말
  var wishText: String
  
  /// `MatchingInfoResponseDTO` -> `MatchingInfo`
  init(_ responseDTO: MatchingInfoResponseDTO) {
    self.identifier = responseDTO.matchingInfoId
    self.age = String(responseDTO.age)
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
  
  /// `MatchingMateResponseDTO` -> `MatchingInfo`
  init(_ responseDTO: MatchingMateResponseDTO) {
    self.identifier = responseDTO.matchingInfoId
    self.age = String(responseDTO.age)
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
    self.memberEmail = ""
    self.openKakaoLink = responseDTO.openKakaoLink
    self.showerTime = responseDTO.showerTime
    self.wakeUpTime = responseDTO.wakeUpTime
    self.wishText = responseDTO.wishText
  }
  
  /// 빈 데이터를 생성합니다.
  ///
  /// - NOTE: `identifier`의 경우는 -1으로 사용할 수 없는 값이 포함되어 있습니다.
  init() {
    self.identifier = -1
    self.dormCategory = .no1
    self.gender = .male
    self.joinPeriod = .period_16
    self.isSmoking = false
    self.isSnoring = false
    self.isGrinding = false
    self.isAllowedFood = false
    self.isWearEarphones = false
    self.isMatchingInfoPublic = false
    self.openKakaoLink = ""
    self.cleanUpStatus = ""
    self.wakeUpTime = ""
    self.showerTime = ""
    self.mbti = ""
    self.wishText = ""
    self.memberEmail = ""
    self.age = ""
  }
}
