import Foundation

import Moya

enum MatchingAPI {
  case lookupMembers
  case lookupLikeMembers
  case lookupDislikeMembers
  case lookupFilterMembers(filter: MatchingRequestModel.Filter)
  case addMember(Bool, Int)
  case deleteMember(Bool, Int)
}

extension MatchingAPI: TargetType, BaseAPI {
  static let provider = MoyaProvider<MatchingAPI>()
  
  var baseURL: URL { getBaseURL() }
  var path: String { getPath() }
  var method: Moya.Method { getMethod() }
  var task: Moya.Task { getTask() }
  var headers: [String : String]? { getJsonHeader() }
}
