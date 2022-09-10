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
  /// 최초 온보딩 정보 저장 API
  static func matchingInfoAPI_Post(myinfo: MyInfo) -> Observable<AFDataResponse<Data>> {
    let body: Parameters = [
      "age": myinfo.age,
      "cleanUpStatus": myinfo.cleanUpStatus,
      "dormNum": myinfo.dormNumber,
      "isAllowedFood": myinfo.allowedFood,
      "isGrinding": myinfo.grinding,
      "isSmoking": myinfo.smoke,
      "isSnoring": myinfo.snoring,
      "isWearEarphones": myinfo.earphone,
      "joinPeriod": myinfo.period,
      "mbti": myinfo.mbti ?? "",
      "openKakaoLink": myinfo.chatLink ?? "",
      "showerTime": myinfo.showerTime,
      "wakeUpTime": myinfo.wakeupTime,
      "wishText": myinfo.wishText ?? ""
    ]
    
    let headers: HTTPHeaders = [
      "X-AUTH-TOKEN": TokenManager.loadToken()
    ]
    
    let url = OnboardingServerConstants.mathcingInfoURL_Post
    return APIService.load(url, httpMethod: .post, body: body, header: headers)
  }
}
