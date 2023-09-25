//
//  SharedAPI.swift
//  idorm
//
//  Created by 김응철 on 2022/12/20.
//

import RxMoya
import RxSwift

final class SharedAPI {
//  
//  static func retrieveMatchingInfo() {
//    _ = MatchingInfoAPI.provider.rx.request(.getMatchingInfo)
//      .asObservable()
//      .retry()
//      .filterSuccessfulStatusCodes()
//      .map(ResponseDTO<MatchingInfoResponseModel.MatchingInfo>.self)
//      .bind { UserStorage.shared.saveMatchingInfo($0.data) }
//  }
//  
//  static func retrieveMemberInfo() {
//    _ = MemberAPI.provider.rx.request(.getUser)
//      .asObservable()
//      .retry()
//      .filterSuccessfulStatusCodes()
//      .map(ResponseDTO<MemberResponseModel.Member>.self)
//      .bind { UserStorage.shared.saveMember($0.data) }
//  }
}
