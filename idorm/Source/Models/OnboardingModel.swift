struct OnboardingModel: Codable {
  struct Request: Codable {
    var dormNumber: Dormitory
    var period: JoinPeriod
    var gender: Gender
    var age: String
    var snoring: Bool
    var grinding: Bool
    var smoke: Bool
    var allowedFood: Bool
    var earphone: Bool
    var wakeupTime: String
    var cleanUpStatus: String
    var showerTime: String
    var mbti: String?
    var wishText: String?
    var chatLink: String
  }
  
  struct Response: Codable {
    let id: Int?
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
    var mbti: String?
    var wishText: String?
    var isMatchingInfoPublic: Bool
    var memberEmail: String
  }
}
