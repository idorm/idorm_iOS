import RxSwift
import RxCocoa

/// 자신의  조회 속성을 저장하는 싱글톤 객체입니다.
final class MemberInfoStorage {
  static let shared = MemberInfoStorage()
  private init() {}
  
  /// 닉네임, 이매일이 포함되어 있는 모델입니다.
  let memberInfo = BehaviorRelay<MemberInfo>(value: MemberInfo.initialValue())
  
  /// 온보딩 모델입니다.
  let matchingInfo = BehaviorRelay<MatchingInfo_Lookup?>(value: nil)
  
  var isPublicMatchingInfo: Bool {
    guard let matchingInfo = matchingInfo.value else { return false }
    if matchingInfo.isMatchingInfoPublic {
      return true
    } else {
      return false
    }
  }
  
  var hasMatchingInfo: Bool {
    guard matchingInfo.value == nil else { return true }
    return false
  }
}
