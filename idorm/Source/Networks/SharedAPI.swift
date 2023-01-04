//
//  SharedAPI.swift
//  idorm
//
//  Created by 김응철 on 2022/12/20.
//

import RxMoya
import RxSwift

final class SharedAPI {
  
  static func retrieveMatchingInfo() {
    _ = APIService.onboardingProvider.rx.request(.retrieve)
      .asObservable()
      .retry()
      .filterSuccessfulStatusCodes()
      .map(ResponseModel<MatchingInfoDTO.Retrieve>.self)
      .bind { MemberStorage.shared.saveMatchingInfo($0.data) }
  }
  
  static func retrieveMemberInfo() {
    _ = APIService.memberProvider.rx.request(.retrieveMember)
      .asObservable()
      .retry()
      .filterSuccessfulStatusCodes()
      .map(ResponseModel<MemberDTO.Retrieve>.self)
      .bind { MemberStorage.shared.saveMember($0.data) }
  }
}
