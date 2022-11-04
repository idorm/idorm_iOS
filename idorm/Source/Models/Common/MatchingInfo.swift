struct MatchingInfo {
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
  var chatLink: String?
  
  static func initialValue() -> MatchingInfo {
    return MatchingInfo(
      dormNumber: .no1,
      period: .period_24,
      gender: .female,
      age: "",
      snoring: false,
      grinding: false,
      smoke: false,
      allowedFood: false,
      earphone: false,
      wakeupTime: "",
      cleanUpStatus: "",
      showerTime: "",
      mbti: "",
      wishText: "",
      chatLink: ""
    )
  }
}
