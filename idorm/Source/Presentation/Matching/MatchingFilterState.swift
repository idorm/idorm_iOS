import RxSwift
import RxCocoa

final class MatchingFilterStates {
  static let shared = MatchingFilterStates()
  private init() {}
  
  var matchingFilterObserver = BehaviorRelay<MatchingFilter?>(value: nil)
}
