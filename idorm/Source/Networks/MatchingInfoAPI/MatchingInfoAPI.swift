//
//  OnboardingAPI.swift
//  idorm
//
//  Created by 김응철 on 2022/12/25.
//

import Foundation

import Moya

enum MatchingInfoAPI {
  case retrieve
  case modify(MatchingInfoRequestModel.MatchingInfo)
  case save(MatchingInfoRequestModel.MatchingInfo)
  case modifyPublic(Bool)
}

extension MatchingInfoAPI: TargetType, BaseAPI {
  static let provider = MoyaProvider<MatchingInfoAPI>()
  
  var baseURL: URL { getBaseURL() }
  var path: String { getPath() }
  var method: Moya.Method { getMethod() }
  var task: Moya.Task { getTask() }
  var headers: [String : String]? { getJsonHeader() }
}

extension MatchingInfoAPI {
  static func retrieveProcess(_ respose: Response) {
    let matchingInfo = MatchingInfoAPI.decode(
      ResponseDTO<MatchingInfoResponseModel.MatchingInfo>.self,
      data: respose.data
    ).data
    
    MemberStorage.shared.saveMatchingInfo(matchingInfo)
  }
}
