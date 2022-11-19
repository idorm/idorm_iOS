import Foundation

import Moya

enum MatchingAPI {
  case retrieve
  case retrieveLiked
  case retrieveDisliked
  case retrieveFiltered(filter: MatchingFilter)
  
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
    case .retrieveLiked, .addLiked, .deleteLiked:
      return "/member/matching/like"
    case .retrieveDisliked, .addDisliked, .deleteDisliked:
      return "/member/matching/dislike"
    case .retrieveFiltered:
      return "/member/matching/filter"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .retrieve, .retrieveLiked, .retrieveDisliked, .retrieveFiltered:
      return .get
    case .addLiked, .addDisliked:
      return .post
    case .deleteLiked, .deleteDisliked:
      return .delete
    }
  }
  
  var task: Moya.Task {
    switch self {
    case .retrieve, .retrieveLiked, .retrieveDisliked:
      return .requestPlain
      
    case .retrieveFiltered(let filter):
      let param = filter.toDictionary!
      return .requestParameters(
        parameters: param,
        encoding: URLEncoding.queryString
      )
      
    case .deleteDisliked(let id), .deleteLiked(let id), .addLiked(let id), .addDisliked(let id):
      return .requestParameters(parameters: [
        "selectedMemberId": id
      ], encoding: URLEncoding.queryString)
    }
  }
  
  var headers: [String : String]? {
    APIService.basicHeader()
  }
}
