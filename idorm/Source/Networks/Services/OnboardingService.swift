//
//  OnboardingService.swift
//  idorm
//
//  Created by 김응철 on 2022/09/07.
//

import Foundation
import RxSwift
import Alamofire

final class OnboardingService {
  
  /// 매칭 정보 최초 저장 API
  static func matchingInfoAPI_Post(myinfo: MatchingInfo) -> Observable<AFDataResponse<Data>> {
    let body: Parameters = [
      "age": myinfo.age,
      "cleanUpStatus": myinfo.cleanUpStatus,
      "dormNum": myinfo.dormNumber.parsingString,
      "gender": myinfo.gender.parsingString,
      "isAllowedFood": myinfo.allowedFood,
      "isGrinding": myinfo.grinding,
      "isSmoking": myinfo.smoke,
      "isSnoring": myinfo.snoring,
      "isWearEarphones": myinfo.earphone,
      "joinPeriod": myinfo.period.parsingString,
      "mbti": myinfo.mbti ?? "",
      "openKakaoLink": myinfo.chatLink ?? "",
      "showerTime": myinfo.showerTime,
      "wakeupTime": myinfo.wakeupTime,
      "wishText": myinfo.wishText ?? ""
    ]
    
    let url = OnboardingServerConstants.mathcingInfoURL
    return APIService.load(url, httpMethod: .post, body: body)
  }
  
  /// 매칭 정보 단건 조회
  static func matchingInfoAPI_Get() -> Observable<AFDataResponse<Data>> {
    let url = OnboardingServerConstants.mathcingInfoURL
    return APIService.load(url, httpMethod: .get, body: nil)
  }
}
