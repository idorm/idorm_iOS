import Foundation

import Moya

enum MatchingMateAPI {
  case lookupMembers
  case lookupLikeMembers
  case lookupDislikeMembers
  case lookupFilterMembers(filter: MatchingRequestModel.Filter)
  case addMember(Bool, Int)
  case deleteMember(Bool, Int)
}

extension MatchingMateAPI: BaseTargetType {
  static let provider = MoyaProvider<MatchingMateAPI>()
  
  var baseURL: URL { getBaseURL() }
  var path: String { getPath() }
  var method: Moya.Method { getMethod() }
  var task: Moya.Task { getTask() }
  var headers: [String : String]? { getJsonHeader() }
}
