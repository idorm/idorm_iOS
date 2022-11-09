/// 자신의 정보를 단건 조회 할 때 필요한 모델입니다.
struct MemberInfo: Codable {
  var id: Int
  var email: String
  var nickname: String?
  var profilePhotoFileName: String?
  var profilePhotoUrl: String?
  var matchingInfoId: Int
  var loginToken: String?
  
  static func initialValue() -> MemberInfo {
    return MemberInfo(id: 1, email: "", nickname: nil, profilePhotoFileName: nil, profilePhotoUrl: nil, matchingInfoId: 1, loginToken: nil)
  }
}
