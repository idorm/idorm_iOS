import Foundation

import RxSwift
import RxCocoa
import Alamofire
import Moya

struct ResponseModel<Model: Codable>: Codable {
  let data: Model
}

final class APIService {
  static let baseURL = "https://idorm.inuappcenter.kr"
  
  static let memberProvider = MoyaProvider<MemberAPI>()
  static let onboardingProvider = MoyaProvider<OnboardingAPI>()
  static let emailProvider = MoyaProvider<EmailAPI>()
  static let matchingProvider = MoyaProvider<MatchingAPI>()

  static func decode<T: Codable>(_ t: T.Type, data: Data) -> T {
    let decoder = JSONDecoder()
    guard let json = try? decoder.decode(T.self, from: data) else { fatalError("Decoding Error!") }
    return json
  }
  
  static func basicHeader() -> [String: String] {
    return [
      "Content-Type": "application/json",
      "X-AUTH-TOKEN": TokenStorage.instance.loadToken()
    ]
  }
}
