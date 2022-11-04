import UIKit

import Alamofire
import RxSwift

final class MatchingService {
  
  /// 매칭 멤버 조회
  static func matchingAPI() -> Observable<AFDataResponse<Data>> {
    let url = MatchingConstants.matchingURL
    return APIService.load(url, httpMethod: .get, body: nil)
  }
  
  /// 매칭 싫어요한 매칭 멤버 조회
  static func matchingDislikedMembers_GET() -> Observable<AFDataResponse<Data>> {
    let url = MatchingConstants.matchingDislikeMembersURL
    return APIService.load(url, httpMethod: .get, body: nil)
  }
  
  /// 매칭 좋아요한 매칭멤버 조회
  static func matchingLikedMembers_GET() -> Observable<AFDataResponse<Data>> {
    let url = MatchingConstants.matchingLikedMembersURL
    return APIService.load(url, httpMethod: .get, body: nil)
  }
  
  /// 매칭 좋아요한 매칭멤버 추가
  static func matchingLikedMembers_Post(_ memberId: Int) -> Observable<AFDataResponse<Data>> {
    let url = MatchingConstants.matchingLikedMembersURL + "/\(memberId)"
    return APIService.load(url, httpMethod: .post, body: nil)
  }
}
