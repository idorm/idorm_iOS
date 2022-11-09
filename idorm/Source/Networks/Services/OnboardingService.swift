import UIKit

import RxSwift
import Alamofire

final class OnboardingService {
  
  static let shared = OnboardingService()
  private init() {}
  
  /// 매칭 정보 최초 저장 API
  func matchingInfoAPI_Post(myinfo: MatchingInfo) -> Observable<AFDataResponse<Data>> {
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
      "openKakaoLink": myinfo.chatLink,
      "showerTime": myinfo.showerTime,
      "wakeupTime": myinfo.wakeupTime,
      "wishText": myinfo.wishText ?? ""
    ]
    
    let url = OnboardingServerConstants.mathcingInfoURL
    return APIService.load(url, httpMethod: .post, body: body, encoding: .json)
  }
  
  /// 매칭 정보 단건 조회
  func matchingInfoAPI_Get() -> Observable<AFDataResponse<Data>> {
    let url = OnboardingServerConstants.mathcingInfoURL
    return APIService.load(url, httpMethod: .get, body: nil, encoding: .json)
  }
  
  /// 매칭 공개 여부 수정
  func matchingInfoAPI_Patch(_ isMatchingInfoPublic: Bool) -> Observable<AFDataResponse<Data>> {
    let url = OnboardingServerConstants.mathcingInfoURL
    let body: Parameters = [
      "isMatchingInfoPublic": isMatchingInfoPublic
    ]
    return APIService.load(url, httpMethod: .patch, body: body, encoding: .query)
  }
}
