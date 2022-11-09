import RxSwift
import RxCocoa

final class MatchingFilterStorage {
  static let shared = MatchingFilterStorage()
  private init() {}
  
  let matchingFilterObserver = BehaviorRelay<MatchingFilter>(value: MatchingFilter.initialValue())
  let isExistedFilter = BehaviorRelay<Bool>(value: false)
}
