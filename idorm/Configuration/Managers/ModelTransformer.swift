final class ModelTransformer {
  static let instance = ModelTransformer()
  private init() {}
}

extension ModelTransformer {
  func toMemberModel(from myOnboarding: OnboardingModel.RequestModel) -> MatchingModel.Member {
    return MatchingModel.Member(memberId: 0, matchingInfoId: 0, dormNum: myOnboarding.dormNum, joinPeriod: myOnboarding.joinPeriod, gender: myOnboarding.gender, age: Int(myOnboarding.age) ?? 10, isSnoring: myOnboarding.isSnoring, isGrinding: myOnboarding.isGrinding, isSmoking: myOnboarding.isSmoking, isAllowedFood: myOnboarding.isAllowedFood, isWearEarphones: myOnboarding.isWearEarphones, wakeUpTime: myOnboarding.wakeupTime, cleanUpStatus: myOnboarding.cleanUpStatus, showerTime: myOnboarding.showerTime, openKakaoLink: myOnboarding.openKakaoLink, mbti: myOnboarding.mbti ?? "", wishText: myOnboarding.wishText ?? "", isMatchingInfoPublic: false, memberEmail: "")

  }
  
  func toOnboardingRequestModel(from member: MatchingModel.Member) -> OnboardingModel.RequestModel {
    return OnboardingModel.RequestModel(dormNum: member.dormNum, joinPeriod: member.joinPeriod, gender: member.gender, age: String(member.age), isSnoring: member.isSnoring, isGrinding: member.isGrinding, isSmoking: member.isSmoking, isAllowedFood: member.isAllowedFood, isWearEarphones: member.isWearEarphones, wakeupTime: member.wakeUpTime, cleanUpStatus: member.cleanUpStatus, showerTime: member.showerTime, openKakaoLink: member.openKakaoLink)
  }
}
