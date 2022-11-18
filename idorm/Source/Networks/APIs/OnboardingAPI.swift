import Foundation

import Moya

enum OnboardingAPI {
  case retrieve
  case modify(OnboardingModel.RequestModel)
  case save(OnboardingModel.RequestModel)
  case modifyPublic(Bool)
}

extension OnboardingAPI: TargetType {
  var baseURL: URL {
    return URL(string: APIService.baseURL)!
  }
  
  var path: String {
    return "/member/matchinginfo"
  }
  
  var method: Moya.Method {
    switch self {
    case .retrieve: return .get
    case .modify: return .put
    case .save: return .post
    case .modifyPublic: return .patch
    }
  }
  
  var task: Moya.Task {
    switch self {
    case .retrieve: return .requestPlain
      
    case .save(let request), .modify(let request):
      return .requestJSONEncodable(request)
      
    case .modifyPublic(let isPublic):
      return .requestParameters(parameters: [
        "isMatchingInfoPublic": isPublic
      ], encoding: URLEncoding.queryString)
    }
  }
  
  var headers: [String : String]? {
    return APIService.basicHeader()
  }
}
