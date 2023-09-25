//
//  OnboardingAPI.swift
//  idorm
//
//  Created by 김응철 on 2022/12/25.
//

import Foundation

import Moya

enum MatchingInfoAPI {
  /**
   온보딩 정보 단건 조회
   */
  case getMatchingInfo
  
  /**
   온보딩 정보 수정
   */
  case updateMatchingInfo(MatchingInfoRequestDTO)
  
  /**
   온보딩 정보 생성
   
   - 최초로 온보딩 정보를 저장할 경우만 사용 가능합니다.
   */
  case createMatchingInfo(MatchingInfoRequestDTO)
  
  /**
   온보딩 정보 공개 여부 수정
   */
  case updateMatchingInfoForPublic(Bool)
}

extension MatchingInfoAPI: BaseTargetType {
  func getHeader() -> NetworkHeaderType {
    return .normalJson
  }
  
  static let provider = MoyaProvider<MatchingInfoAPI>()
  
  var baseURL: URL { getBaseURL() }
  var path: String { getPath() }
  var method: Moya.Method { getMethod() }
  var task: Moya.Task { getTask() }
  var headers: [String : String]? { self.getHeader().header }
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
