import RxSwift
import RxCocoa

/// 자신의 조회 속성을 저장하는 싱글톤 객체입니다.
final class MemberInfoStorage {
  
  // MARK: - Properties
  
  static let instance = MemberInfoStorage()
  let disposeBag = DisposeBag()
  private init() {
    bind()
  }
  
  /// 닉네임, 이매일이 포함되어 있는 모델입니다.
  let myInformation = BehaviorRelay<MemberModel.MyInformation?>(value: nil)
  
  /// 온보딩 조회 모델입니다.
  let myOnboarding = BehaviorRelay<OnboardingModel.MyOnboarding?>(value: nil)
  
  /// 현재의 매칭 공개 여부를 조회할 수 있는 Relay입니다.
  let isPublicMatchingInfoObserver = BehaviorRelay<Bool?>(value: nil)
  
  // MARK: - Bind
  
  func bind() {
    myOnboarding
      .map { $0?.isMatchingInfoPublic }
      .bind(to: isPublicMatchingInfoObserver)
      .disposed(by: disposeBag)
  }
}

// MARK: - Stored Properties

extension MemberInfoStorage {
  /// 매칭 카드를 생성할 수 있는 프로퍼티입니다.
//  var toMatchingMemberModel: MatchingMember {
//    return MatchingInfo_Lookup.toMatchingMemberModel(myOnboarding.value!)
//  }
    
  /// 현재 자신의 매칭 공개 여부를 조회합니다.
  var isPublicMatchingInfo: Bool {
    guard let matchingInfo = myOnboarding.value else { return false }
    if matchingInfo.isMatchingInfoPublic {
      return true
    } else {
      return false
    }
  }
  
  /// 현재 자신의 매칭 정보 유무를 조회합니다.
  var hasMatchingInfo: Bool {
    guard myOnboarding.value == nil else { return true }
    return false
  }
}

// MARK: - Transformation

extension MemberInfoStorage {
  func onboardingToMatchingMember() -> MatchingModel.Member {
    guard let myOnboarding = myOnboarding.value else { fatalError() }
    return MatchingModel.Member(memberId: 0, matchingInfoId: 0, dormNum: myOnboarding.dormNum, joinPeriod: myOnboarding.joinPeriod, gender: myOnboarding.gender, age: myOnboarding.age, isSnoring: myOnboarding.isSnoring, isGrinding: myOnboarding.isGrinding, isSmoking: myOnboarding.isSmoking, isAllowedFood: myOnboarding.isAllowedFood, isWearEarphones: myOnboarding.isWearEarphones, wakeUpTime: myOnboarding.wakeUpTime, cleanUpStatus: myOnboarding.cleanUpStatus, showerTime: myOnboarding.showerTime, openKakaoLink: myOnboarding.openKakaoLink, mbti: myOnboarding.mbti ?? "", wishText: myOnboarding.wishText ?? "", isMatchingInfoPublic: myOnboarding.isMatchingInfoPublic, memberEmail: myOnboarding.memberEmail)
  }
}
