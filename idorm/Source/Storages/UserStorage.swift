//
//  UserStorage.swift
//  idorm
//
//  Created by 김응철 on 2022/12/15.
//

import Foundation

import RxSwift

/// 이메일, 비밀번호, 토큰을 보관하는 영구적으로 보관하는 싱글톤 객체입니다.
/// 하지만 매칭 정보와 멤버 정보는 앱이 종료되면 저장되지 않고 초기화됩니다.
final class UserStorage {
  
  // MARK: - PROPERTIES
  
  static let shared = UserStorage()
  
  @UserDefaultsWrapper<String>(key: "EMAIL", defaultValue: "")
  private(set) var email: String
  
  @UserDefaultsWrapper<String>(key: "PASSWORD", defaultValue: "")
  private(set) var password: String
  
  @UserDefaultsWrapper<String>(key: "TOKEN", defaultValue: "")
  private(set) var token: String
  
  private(set) var matchingInfo: MatchingInfoResponseModel.MatchingInfo?
  private(set) var member: MemberResponseModel.Member?
  
  // MARK: - COMPUTED PROPERTIES
  
  var hasMatchingInfo: Bool {
    self.matchingInfo != nil ? true : false
  }
  
  var isPublicMatchingInfo: Bool {
    self.matchingInfo?.isMatchingInfoPublic ?? false
  }
  
  // MARK: - INITIALIZER
  
  private init() {}
  
  // MARK: - HELPERS
  
  /// 이메일을 영구적으로 저장합니다.
  func saveEmail(_ email: String) {
    self.email = email
  }
  
  /// 비밀번호를 영구적으로 저장합니다.
  func savePassword(_ password: String) {
    self.password = password
  }
  
  /// 토큰을 영구적으로 저장합니다.
  func saveToken(_ token: String?) {
    self.token = token ?? ""
  }
  
  /// 멤버 매칭 정보를 저장합니다.
  func saveMatchingInfo(_ matchingInfo: MatchingInfoResponseModel.MatchingInfo) {
    self.matchingInfo = matchingInfo
  }
  
  /// 멤버 정보를 저장합니다.
  func saveMember(_ member: MemberResponseModel.Member) {
    self.member = member
  }
  
  /// UserDefaults에 저장된 프로퍼티를 제외한 모든 프로퍼티를 nil로 할당합니다.
  func reset() {
    self.matchingInfo = nil
    self.member = nil
  }
  
  /// 토큰을 초기화 시킵니다.
  func resetToken() {
    self.token = ""
  }
}
