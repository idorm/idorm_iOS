import UIKit

import Alamofire
import RxSwift

final class MatchingService {
  
  /// 매칭 멤버 조회
  static func matchingAPI() -> Observable<AFDataResponse<Data>> {
    let url = MatchingConstants.matchingURL
    return APIService.load(url, httpMethod: .get, body: nil)
  }
}
