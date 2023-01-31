import Foundation

import Moya

enum MatchingAPI {
  case retrieve
  case retrieveLiked
  case retrieveDisliked
  case retrieveFiltered(filter: MatchingRequestModel.Filter)
  
  case addLiked(Int)
  case addDisliked(Int)
  
  case deleteLiked(Int)
  case deleteDisliked(Int)
}

extension MatchingAPI: TargetType, BaseAPI {
  static let provider = MoyaProvider<MatchingAPI>()
  
  var baseURL: URL { getBaseURL() }
  var path: String { getPath() }
  var method: Moya.Method { getMethod() }
  var task: Moya.Task { getTask() }
  var headers: [String : String]? { getJsonHeader() }
}
