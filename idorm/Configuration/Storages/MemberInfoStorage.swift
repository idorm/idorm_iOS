import RxSwift
import RxCocoa

/// 자신의  조회 속성을 저장하는 싱글톤 객체입니다.
final class MemberInfoStorage {
  static let shared = MemberInfoStorage()
  let disposeBag = DisposeBag()
  private init() {
    bind()
  }
  
  /// 닉네임, 이매일이 포함되어 있는 모델입니다.
  let memberInfo = BehaviorRelay<MemberInfo>(value: MemberInfo.initialValue())
  
  /// 온보딩 조회 모델입니다.
  let matchingInfo = BehaviorRelay<MatchingInfo_Lookup?>(value: nil)
  
  /// 현재의 매칭 공개 여부를 조회할 수 있는 Relay입니다.
  let isPublicMatchingInfoObserver = BehaviorRelay<Bool?>(value: nil)
  
  func bind() {
    matchingInfo
      .map { $0?.isMatchingInfoPublic }
      .bind(to: isPublicMatchingInfoObserver)
      .disposed(by: disposeBag)
  }
}

extension MemberInfoStorage {
  /// 매칭 카드를 생성할 수 있는 프로퍼티입니다.
  var toMatchingMemberModel: MatchingMember {
    return MatchingInfo_Lookup.toMatchingMemberModel(matchingInfo.value!)
  }
    
  /// 현재 자신의 매칭 공개 여부를 조회합니다.
  var isPublicMatchingInfo: Bool {
    guard let matchingInfo = matchingInfo.value else { return false }
    if matchingInfo.isMatchingInfoPublic {
      return true
    } else {
      return false
    }
  }
  
  /// 현재 자신의 매칭 정보 유무를 조회합니다.
  var hasMatchingInfo: Bool {
    guard matchingInfo.value == nil else { return true }
    return false
  }
}
