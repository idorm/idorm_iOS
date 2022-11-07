import RxSwift
import RxCocoa

/// 최근 불러온 멤버 단기 조회를 저장하는 싱글톤 객체입니다.
final class MemberInfomationState {
  static let shared = MemberInfomationState()
  private init() {}
  
  var currentMemberInfomation = BehaviorRelay<MemberInfomation>(value: MemberInfomation.initialValue())
}
