import RxSwift
import RxCocoa

final class MatchingFilterStates {
  static let shared = MatchingFilterStates()
  private init() {}
  
  let matchingFilterObserver = BehaviorRelay<MatchingFilter>(value: MatchingFilter.initialValue())
  let isExistedFilter = BehaviorRelay<Bool>(value: false)
}
