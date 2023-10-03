//
//  UserStorage.swift
//  idorm
//
//  Created by 김응철 on 2022/12/15.
//

import Foundation

import RxSwift
import RxCocoa

/// 이메일, 비밀번호, 토큰을 보관하는 영구적으로 보관하는 싱글톤 객체입니다.
final class UserStorage {
  
  // MARK: - Properties
  
  static let shared = UserStorage()
  
  @UserDefaultsWrapper<String?>(key: "EMAIL", defaultValue: nil)
  var email: String?
  
  @UserDefaultsWrapper<String>(key: "PASSWORD", defaultValue: "")
  var password: String
  
  @UserDefaultsWrapper<String>(key: "TOKEN", defaultValue: "")
  var token: String
  
  @UserDefaultsWrapper<Bool>(key: "ISLAUNCHED", defaultValue: false)
  var isLaunched: Bool
  
  @UserDefaultsWrapper<Member?>(key: "MEMBER", defaultValue: nil)
  var member: Member?
  
  @UserDefaultsWrapper<MatchingInfo?>(key: "MATCHINGINFO", defaultValue: nil)
  var matchingInfo: MatchingInfo?
  
  var matchingMateFilter = BehaviorRelay<MatchingInfoFilter?>(value: nil)
  
  // MARK: - Initializer
  
  private init() {}
  
  // MARK: - Functions
  
  /// 현재 `MatchingInfo`의 존재여부
  var hasMatchingInfo: Bool {
    self.matchingInfo != nil ? true : false
  }
  
  /// 현재 `MatchingInfo`의 공개여부
  var isPublicMatchingInfo: Bool {
    self.matchingInfo?.isMatchingInfoPublic ?? false
  }
  
  /// 프로필 이미지 존재여부
  var hasProfileImage: Bool {
    return ((self.member?.profilePhotoURL != nil)) ? true : false
  }

  var dormCategory: Dormitory {
    self.matchingInfo?.dormCategory ?? .no1
  }
  
  var joinPeriod: JoinPeriod {
    self.matchingInfo?.joinPeriod ?? .period_16
  }
  
  /// UserDefaults에 저장된 프로퍼티를 제외한 모든 프로퍼티를 nil로 할당합니다.
  func reset() {
    self.matchingInfo = nil
    self.member = nil
  }
}
