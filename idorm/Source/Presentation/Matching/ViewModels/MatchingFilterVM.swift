import RxSwift
import RxCocoa

final class MatchingFilterViewModel: ViewModel {
  struct Input {
    // UI
    let skipButtonTapped = PublishSubject<Void>()
    let confirmButtonTapped = PublishSubject<Void>()
    let isSelectedDormButton = PublishSubject<Dormitory>()
    let isSelectedPeriodButton = PublishSubject<JoinPeriod>()
    let isSelectedHabitButton = PublishSubject<Habit>()
    let onChangedAgeSlider = PublishSubject<(minAge: Int, maxAge: Int)>()
  }
  
  struct Output {
    let popVC = PublishSubject<Void>()
    let isEnableConfirmButton = PublishSubject<Bool>()
    let requestCards = PublishSubject<Void>()
    let requestFilteredCards = PublishSubject<Void>()
  }
  
  struct State {
    let confirmVerifierObserver = BehaviorRelay<FilteringConfirmVerifier>(value: FilteringConfirmVerifier.initialValue())
  }
  
  let matchingFilterShared = MatchingFilterStates.shared
  var input = Input()
  var output = Output()
  var state = State()
  var disposeBag = DisposeBag()
    
  /// 현재 필터링 완료 버튼 활성화 정도
  var currentFilterConfirmVerifier: FilteringConfirmVerifier { return state.confirmVerifierObserver.value }
  /// 현재 매칭 필터 정보
  var currentMatchingFilter: MatchingFilter? { return matchingFilterShared.matchingFilterObserver.value }
  
  init() {
    bind()
    mutate()
  }
  
  func mutate() {
    
    // 필터링 완료 버튼 드라이버 -> Bool Stream 전달
    state.confirmVerifierObserver
      .map {
        if $0.dorm && $0.period {
          return true
        } else {
          return false
        }
      }
      .bind(to: output.isEnableConfirmButton)
      .disposed(by: disposeBag)
    
    input.skipButtonTapped
      .bind(to: output.requestCards)
      .disposed(by: disposeBag)
  }
  
  func bind() {
    
    // 선택 초기화 버튼 -> 뒤로 가기 & 매칭 필터 정보 초기화
    input.skipButtonTapped
      .bind(onNext: { [unowned self] in
        self.matchingFilterShared.matchingFilterObserver.accept(nil)
        self.output.requestCards.onNext(Void())
        self.output.popVC.onNext(Void())
      })
      .disposed(by: disposeBag)
    
    // 필터링 완료 버튼 이벤트 -> 뒤로가기 & 필터 매칭 카드 요청
    input.confirmButtonTapped
      .bind(onNext: { [unowned self] in
        self.output.popVC.onNext(Void())
        self.output.requestFilteredCards.onNext(Void())
      })
      .disposed(by: disposeBag)

    // 기숙사 버튼 이벤트 -> 매칭필터 정보 전달 & 필터링 버튼 드라이버 전달
    input.isSelectedDormButton
      .bind(onNext: { [unowned self] dorm in
        var newVerifier = self.currentFilterConfirmVerifier
        var newFilter = self.currentMatchingFilter
        newVerifier.dorm = true
        switch dorm {
        case .no1:
          newFilter?.dormNum = .no1
        case .no2:
          newFilter?.dormNum = .no2
        case .no3:
          newFilter?.dormNum = .no3
        }
        self.matchingFilterShared.matchingFilterObserver.accept(newFilter)
        self.state.confirmVerifierObserver.accept(newVerifier)
      })
      .disposed(by: disposeBag)
    
    // 기간 버튼 이벤트 -> 매칭필터 정보 전달 & 필터링 버튼 드라이버 전달
    input.isSelectedPeriodButton
      .bind(onNext: { [unowned self] period in
        var newVerifier = self.currentFilterConfirmVerifier
        var newFilter = self.currentMatchingFilter
        newVerifier.period = true
        switch period {
        case .period_16:
          newFilter?.period = .period_16
        case .period_24:
          newFilter?.period = .period_24
        }
        self.matchingFilterShared.matchingFilterObserver.accept(newFilter)
        self.state.confirmVerifierObserver.accept(newVerifier)
      })
      .disposed(by: disposeBag)
    
    // 습관 버튼 이벤트 -> 매칭 필터 정보 전달
    input.isSelectedHabitButton
      .bind(onNext: { [unowned self] habit in
        var newFilter = self.currentMatchingFilter
        switch habit {
        case .snoring:
          newFilter?.isSnoring.toggle()
        case .smoking:
          newFilter?.isSmoking.toggle()
        case .grinding:
          newFilter?.isGrinding.toggle()
        case .allowedFood:
          newFilter?.isAllowedFood.toggle()
        case .allowedEarphone:
          newFilter?.isWearEarphones.toggle()
        }
        self.matchingFilterShared.matchingFilterObserver.accept(newFilter)
      })
      .disposed(by: disposeBag)
    
    // 나이 슬라이더 이벤트 -> 매칭 필터 정보 전달
    input.onChangedAgeSlider
      .bind(onNext: { [unowned self] (minValue: Int, maxValue: Int) in
        var newFilter = self.currentMatchingFilter
        newFilter?.minAge = minValue
        newFilter?.maxAge = maxValue
        self.matchingFilterShared.matchingFilterObserver.accept(newFilter)
      })
      .disposed(by: disposeBag)
  }
}
