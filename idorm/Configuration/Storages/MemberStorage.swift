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
  
  private(set) var matchingInfo: MatchingInfoDTO.Retrieve? {
    didSet {
      guard let isPublic = matchingInfo?.isMatchingInfoPublic else { return }
      didChangePublicState.onNext(isPublic)
    }
  }
  
  private(set) var member: MemberDTO.Retrieve?

  private(set) var didChangePublicState = PublishSubject<Bool>()
  var hasMatchingInfo: Bool { matchingInfo != nil ? true : false }
  var isPublicMatchingInfo: Bool { matchingInfo?.isMatchingInfoPublic ?? false }
  
  func saveMatchingInfo(_ matchingInfo: MatchingInfoDTO.Retrieve) {
    self.matchingInfo = matchingInfo
  }
  
  func saveMember(_ member: MemberDTO.Retrieve) {
    self.member = member
  }
}
