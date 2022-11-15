struct MatchingModel: Codable {
  struct Someone: Codable {
    var memberId: Int
    var matchingInfoId: Int
    var dormNum: Dormitory
    var joinPeriod: JoinPeriod
    var gender: Gender
    var age: Int
    var isSnoring: Bool
    var isGrinding: Bool
    var isSmoking: Bool
    var isAllowedFood: Bool
    var isWearEarphones: Bool
    var wakeUpTime: String
    var cleanUpStatus: String
    var showerTime: String
    var openKakaoLink: String
    var mbti: String
    var wishText: String
    var isMatchingInfoPublic: Bool
    var memberEmail: String
  }
}
