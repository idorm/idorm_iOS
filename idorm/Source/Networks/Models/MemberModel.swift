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
