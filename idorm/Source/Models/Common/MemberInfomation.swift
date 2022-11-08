struct MemberInfomation: Codable {
  var id: Int
  var email: String
  var nickname: String?
  var profilePhotoFileName: String?
  var profilePhotoUrl: String?
  var matchingInfoId: Int
  var loginToken: String?
  
  static func initialValue() -> MemberInfomation {
    return MemberInfomation(id: 1, email: "", nickname: nil, profilePhotoFileName: nil, profilePhotoUrl: nil, matchingInfoId: 1, loginToken: nil)
  }
}
