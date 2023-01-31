//
//  MemberStorage.swift
//  idorm
//
//  Created by 김응철 on 2022/12/20.
//

import Foundation

import RxSwift
import RxCocoa

final class MemberStorage {
  
  static let shared = MemberStorage()
  private init() {}
  
  private(set) var matchingInfo: MatchingInfoResponseModel.MatchingInfo? {
    didSet {
      guard let isPublic = matchingInfo?.isMatchingInfoPublic else { return }
      didChangePublicState.onNext(isPublic)
    }
  }
  
  private(set) var member: MemberResponseModel.Member?
  
  private(set) var didChangePublicState = PublishSubject<Bool>()
  var hasMatchingInfo: Bool { matchingInfo != nil ? true : false }
  var isPublicMatchingInfo: Bool { matchingInfo?.isMatchingInfoPublic ?? false }
  
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
