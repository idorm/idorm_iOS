import Foundation

import Moya

enum MatchingMateAPI {
  /**
   매칭 회원 다건 조회
   */
  case getMembers
  
  /**
   좋아요한 회원 다건 조회
   */
  case getLikedMembers
  
  /**
   싫어요한 회원 다건 조회
   */
  case getDislikedMembers
  
  /**
   필터링 매칭 회원 다건 조회
   */
  case getFilteredMembers(MatchingMateFilterRequestDTO)
  
  /**
   매칭 좋아요 혹은 싫어요한 회원 추가
   
   -matchingType true는 좋아요한 회원, false는 싫어요한 회원을 의미합니다.
   - 본인 혹은 선택한 매칭 회원이 매칭 정보가 공개 상태가 아니라면 400(ILLEGAL_STATEMENT_MATCHINGINFO_NON_PUBLIC)를 던집니다.
   */
  case createMatchingMate(isLiked: Bool, identifier: Int)
  
  /**
   매칭 좋아요 혹은 싫어요한 회원 삭제
   
   - matchingType true는 좋아요한 회원, false는 싫어요한 회원을 의미합니다.
   */
  case deleteMatchingMate(isLiked: Bool, identifier: Int)
}

extension MatchingMateAPI: BaseTargetType {
  func getHeader() -> NetworkHeaderType {
    return .normalJson
  }
  
  static let provider = MoyaProvider<MatchingMateAPI>()
  
  var baseURL: URL { getBaseURL() }
  var path: String { getPath() }
  var method: Moya.Method { getMethod() }
  var task: Moya.Task { getTask() }
  var headers: [String : String]? { self.getHeader().header }
}
