struct MemberModel: Codable {
  
  /// 매칭 단건 조회의 ResponseModel 입니다.
  struct MyInformation: Codable {
    let id: Int
    let email: String
    var nickname: String
    var profilePhotoFileName: String?
    var profilePhotoUrl: String?
    let matchingInfoId: Int?
    let loginToken: String?
  }
}

// MARK: - ResponseModel

extension MemberModel {
  
  /// 로그인 API의 Response Model 입니다.
  struct LoginResponseModel: Codable {
    let data: MyInformation
  }
  
  /// 멤버 단건 조회 API의 Response Model입니다.
  struct RetrieveMemberResponseModel: Codable {
    let data: MyInformation
  }
}
