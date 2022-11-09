import RxSwift
import RxCocoa

/// 자신의  조회 속성을 저장하는 싱글톤 객체입니다.
final class MemberInfoStorage {
  static let shared = MemberInfoStorage()
  private init() {}
  
  let memberInfo = BehaviorRelay<MemberInfo>(value: MemberInfo.initialValue())
  let matchingInfo = BehaviorRelay<MatchingInfo_Lookup?>(value: nil)
  
  var hasMatchingInfo: Bool {
    if matchingInfo.value == nil {
      return false
    } else {
      return true
    }
  }
}
