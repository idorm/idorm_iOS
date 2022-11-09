/// 타인의 매칭 멤버 모델입니다.
struct MatchingMember: Codable {
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
