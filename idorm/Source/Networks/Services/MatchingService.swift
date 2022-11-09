import UIKit

import Alamofire
import RxSwift

final class MatchingService {
  
  /// 매칭 멤버 조회
  static func matchingAPI() -> Observable<AFDataResponse<Data>> {
    let url = MatchingConstants.matchingURL
    return APIService.load(url, httpMethod: .get, body: nil, encoding: .json)
  }
  
  /// 필터링된 매칭 멤버 조회
  static func filteredMatchingAPI(_ filter: MatchingFilter) -> Observable<AFDataResponse<Data>> {
    let url = MatchingConstants.matchingFilteredURL
    let body: Parameters = [
      "dormNum": filter.dormNum.rawValue,
      "joinPeriod": filter.period.rawValue,
      "isAllowedFood": filter.isAllowedFood,
      "isGrinding": filter.isGrinding,
      "isSmoking": filter.isSmoking,
      "isSnoring": filter.isSnoring,
      "isWearEarphones": filter.isWearEarphones,
      "minAge": filter.minAge,
      "maxAge": filter.maxAge
    ]
    return APIService.load(url, httpMethod: .get, body: body, encoding: .query)
  }
  
  /// 매칭 싫어요 매칭 멤버 조회
  static func matchingDislikedMembers_GET() -> Observable<AFDataResponse<Data>> {
    let url = MatchingConstants.matchingDislikeMembersURL
    return APIService.load(url, httpMethod: .get, body: nil, encoding: .query)
  }
  
  /// 매칭 좋아요 매칭멤버 조회
  static func matchingLikedMembers_GET() -> Observable<AFDataResponse<Data>> {
    let url = MatchingConstants.matchingLikedMembersURL
    return APIService.load(url, httpMethod: .get, body: nil, encoding: .query)
  }
  
  /// 매칭 좋아요 매칭멤버 추가
  static func matchingLikedMembers_Post(_ memberId: Int) -> Observable<AFDataResponse<Data>> {
    let url = MatchingConstants.matchingLikedMembersURL + "?selectedMemberId=\(memberId)"
    return APIService.load(url, httpMethod: .post, body: nil, encoding: .query)
  }
  
  /// 매칭 싫어요 매칭멤버 추가
  static func matchingDislikedMembers_Post(_ memberId: Int) -> Observable<AFDataResponse<Data>> {
    let url = MatchingConstants.matchingDislikeMembersURL + "?selectedMemberId=\(memberId)"
    return APIService.load(url, httpMethod: .post, body: nil, encoding: .query)
  }
  
  /// 매칭 좋아요 매칭멤버 삭제
  static func matchingLikedMembers_Delete(_ memberId: Int) -> Observable<AFDataResponse<Data>> {
    let url = MatchingConstants.matchingLikedMembersURL
    let body: Parameters = [
      "selectedMemberId": memberId
    ]
    
    return APIService.load(url, httpMethod: .delete, body: body, encoding: .query)
  }
  
  /// 매칭 싫어요 매칭멤버 삭제
  static func matchingDislikedMembers_Delete(_ memberId: Int) -> Observable<AFDataResponse<Data>> {
    let url = MatchingConstants.matchingDislikeMembersURL
    let body: Parameters = [
      "selectedMemberId": memberId
    ]
    
    return APIService.load(url, httpMethod: .delete, body: body, encoding: .query)
  }
}
