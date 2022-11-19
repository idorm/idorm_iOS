struct OnboardingModel: Codable {
  
  /// 나의 온보딩 정보입니다.
  struct MyOnboarding: Codable {
    let id: Int
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
  
  /// 온보딩을 저장할 RequestModel입니다.
  struct RequestModel: Codable {
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
    
    static func initialValue() -> RequestModel {
      return RequestModel(dormNumber: .no1, period: .period_16, gender: .female, age: "10", snoring: false, grinding: false, smoke: false, allowedFood: false, earphone: false, wakeupTime: "", cleanUpStatus: "", showerTime: "", chatLink: "")
    }
  }
}

// MARK: - ResponseModel

extension OnboardingModel {
  
  /// MyOnboarding 단건 조회 ResponseModel입니다.
  struct LookupOnboardingResponseModel: Codable {
    let data: MyOnboarding
  }
}
