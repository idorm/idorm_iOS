final class ModelTransformer {
  static let instance = ModelTransformer()
  private init() {}
}

extension ModelTransformer {
  func toMemberModel(from myOnboarding: OnboardingModel.RequestModel) -> MatchingModel.Member {
    return MatchingModel.Member(memberId: 0, matchingInfoId: 0, dormNum: myOnboarding.dormNumber, joinPeriod: myOnboarding.period, gender: myOnboarding.gender, age: Int(myOnboarding.age) ?? 10, isSnoring: myOnboarding.snoring, isGrinding: myOnboarding.grinding, isSmoking: myOnboarding.smoke, isAllowedFood: myOnboarding.allowedFood, isWearEarphones: myOnboarding.earphone, wakeUpTime: myOnboarding.wakeupTime, cleanUpStatus: myOnboarding.cleanUpStatus, showerTime: myOnboarding.showerTime, openKakaoLink: myOnboarding.chatLink, mbti: myOnboarding.mbti ?? "", wishText: myOnboarding.wishText ?? "", isMatchingInfoPublic: false, memberEmail: "")

  }
  
  func toOnboardingRequestModel(from member: MatchingModel.Member) -> OnboardingModel.RequestModel {
    return OnboardingModel.RequestModel(dormNumber: member.dormNum, period: member.joinPeriod, gender: member.gender, age: String(member.age), snoring: member.isSnoring, grinding: member.isGrinding, smoke: member.isSmoking, allowedFood: member.isAllowedFood, earphone: member.isWearEarphones, wakeupTime: member.wakeUpTime, cleanUpStatus: member.cleanUpStatus, showerTime: member.showerTime, chatLink: member.openKakaoLink)
  }
}
