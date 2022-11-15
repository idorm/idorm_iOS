struct MemberModel: Codable {
  struct Response: Codable {
    var id: Int
    var email: String
    var nickname: String?
    var profilePhotoFileName: String?
    var profilePhotoUrl: String?
    var matchingInfoId: Int
    var loginToken: String?
  }
}
