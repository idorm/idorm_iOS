/// 자신의 매칭 멤버를 조회하는 모델입니다.
struct MatchingInfo_Lookup: Codable {
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
  
  static func toMatchingMemberModel(_ from: MatchingInfo_Lookup) -> MatchingMember {
    return MatchingMember(
      memberId: from.id,
      matchingInfoId: 0,
      dormNum: from.dormNum,
      joinPeriod: from.joinPeriod,
      gender: from.gender,
      age: from.age,
      isSnoring: from.isSnoring,
      isGrinding: from.isGrinding,
      isSmoking: from.isSmoking,
      isAllowedFood: from.isAllowedFood,
      isWearEarphones: from.isWearEarphones,
      wakeUpTime: from.wakeUpTime,
      cleanUpStatus: from.cleanUpStatus,
      showerTime: from.showerTime,
      openKakaoLink: from.openKakaoLink,
      mbti: from.mbti ?? "",
      wishText: from.wishText ?? "",
      isMatchingInfoPublic: from.isMatchingInfoPublic,
      memberEmail: from.memberEmail
    )
  }
}
