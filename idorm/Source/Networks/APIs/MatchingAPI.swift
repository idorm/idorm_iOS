import Foundation

import Moya

enum MatchingAPI {
  case retrieve
  case retrieveLiked
  case retrieveDisliked
  case retrieveFiltered(filter: MatchingDTO.Filter)
  
  case addLiked(Int)
  case addDisliked(Int)
  
  case deleteLiked(Int)
  case deleteDisliked(Int)
}

extension MatchingAPI: TargetType {
  var baseURL: URL {
    return URL(string: APIService.baseURL)!
  }
  
  var path: String {
    switch self {
    case .retrieve:
      return "/member/matching"
    case .retrieveLiked:
      return "/member/matching/like"
    case .addLiked(let id), .deleteLiked(let id):
      return "/member/matching/like/\(id)"
    case .addDisliked(let id), .deleteDisliked(let id):
      return "/member/matching/dislike/\(id)"
    case .retrieveDisliked:
      return "/member/matching/dislike"
    case .retrieveFiltered:
      return "/member/matching/filter"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .retrieve, .retrieveLiked, .retrieveDisliked:
      return .get
    case .addLiked, .addDisliked, .retrieveFiltered:
      return .post
    case .deleteLiked, .deleteDisliked:
      return .delete
    }
  }
  
  var task: Moya.Task {
    switch self {
    case .retrieveFiltered(let filter):
      return .requestJSONEncodable(filter)
      
    default:
      return .requestPlain
    }
  }
  
  var headers: [String : String]? {
    APIService.basicHeader()
  }
}
