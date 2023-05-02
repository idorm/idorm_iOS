//
//  MemberStorage.swift
//  idorm
//
//  Created by 김응철 on 2022/12/20.
//

import Foundation

import RxSwift
import RxCocoa

/// 로그인 된 멤버와 관련된 매칭 정보 및 
final class MemberStorage {
    
  // MARK: - PROPERTIES
  
  static let shared = MemberStorage()
  
  private(set) var matchingInfo: MatchingInfoResponseModel.MatchingInfo? {
    didSet {
      guard let isPublic = matchingInfo?.isMatchingInfoPublic else { return }
      publicStateDetector.onNext(isPublic)
    }
  }
  
  private(set) var member: MemberResponseModel.Member?
  var hasMatchingInfo: Bool { matchingInfo != nil ? true : false }
  var isPublicMatchingInfo: Bool { matchingInfo?.isMatchingInfoPublic ?? false }
  
  private(set) var publicStateDetector = PublishSubject<Bool>()
  
  // MARK: - INITIALIZER
  
  private init() {}
  
  // MARK: - HELPERS
  
  func saveMatchingInfo(_ matchingInfo: MatchingInfoResponseModel.MatchingInfo) {
    self.matchingInfo = matchingInfo
  }
  
  func saveMember(_ member: MemberResponseModel.Member) {
    self.member = member
  }
  
  func resetMember() {
    self.matchingInfo = nil
    self.member = nil
  }
}
