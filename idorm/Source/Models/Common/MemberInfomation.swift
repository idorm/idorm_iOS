struct MemberInfomation: Codable {
  let id: Int
  let email: String
  let nickname: String?
  let profilePhotoFileName: String?
  let profilePhotoUrl: String?
  let matchingInfoId: Int
  let loginToken: String?
  
  static func initialValue() -> MemberInfomation {
    return MemberInfomation(id: 1, email: "", nickname: nil, profilePhotoFileName: nil, profilePhotoUrl: nil, matchingInfoId: 1, loginToken: nil)
  }
}
