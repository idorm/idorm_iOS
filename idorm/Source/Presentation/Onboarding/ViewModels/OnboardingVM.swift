import Moya
import RxMoya
import RxSwift
import RxCocoa

final class OnboardingViewModel: ViewModel {
  
  struct Input {
    // Interaction
    let isSelectedDormButton = PublishSubject<Dormitory>()
    let isSelectedGenderButton = PublishSubject<Gender>()
    let isSelectedPeriodButton = PublishSubject<JoinPeriod>()
    let isSelectedHabitButton = PublishSubject<Habit>()
    let onChangedQueryText = PublishSubject<(OnboardingQueryList, String)>()
    let didTapSkipButton = PublishSubject<Void>()
    let didTapConfirmButton = PublishSubject<Void>()
  }
  
  struct Output {
    // State
    let myOnboarding = BehaviorRelay<OnboardingModel.RequestModel>(value: .initialValue())
    
    // UI
    let isEnableConfirmButton = PublishSubject<Bool>()
    let indicatorState = PublishSubject<Bool>()
    let resetData = PublishSubject<Void>()
    
    // Presentation
    let pushToOnboardingDetailVC = PublishSubject<MatchingModel.Member>()
    let showTabBarVC = PublishSubject<Void>()
    let pushToRootVC = PublishSubject<Void>()
  }
  
  struct State {
    let confirmVerifierObserver = BehaviorRelay<OnboardingConfirmVerifier>(value: OnboardingConfirmVerifier.initialValue())
  }
  
  var state = State()
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  private let vcType: OnboardingVCTypes.OnboardingVCType
  
  var currentOnboarding: OnboardingModel.RequestModel { return output.myOnboarding.value }
  var currentConfirmVerifier: OnboardingConfirmVerifier { return state.confirmVerifierObserver.value }
  
  init(_ vcType: OnboardingVCTypes.OnboardingVCType) {
    self.vcType = vcType
    mutate()
    bind()
  }
  
  // MARK: - Bind
  
  func mutate() {
    
    // 완료 버튼 활성&비활성화 -> Bool Stream 전달
    state.confirmVerifierObserver
      .map {
        $0.dorm && $0.period && $0.age && $0.cleanup && $0.gender && $0.showerTime && $0.wakeup && $0.chatLink ? true : false
      }
      .bind(to: output.isEnableConfirmButton)
      .disposed(by: disposeBag)
    
    // 기숙사 버튼 반응 -> (완료 버튼 활성/비활성 & 매칭 정보 전달)
    input.isSelectedDormButton
      .bind(onNext: { [unowned self] dorm in
        var newValue = self.output.myOnboarding.value
        var newVerifier = self.currentConfirmVerifier
        newValue.dormNum = dorm
        self.output.myOnboarding.accept(newValue)
        newVerifier.dorm = true
        self.state.confirmVerifierObserver.accept(newVerifier)
      })
      .disposed(by: disposeBag)
    
    // 성별 버튼 반응 -> (완료 버튼 활성/비활성 & 매칭 정보 전달)
    input.isSelectedGenderButton
      .bind(onNext: { [unowned self] gender in
        var newValue = self.currentOnboarding
        var newVerifier = self.currentConfirmVerifier
        newValue.gender = gender
        self.output.myOnboarding.accept(newValue)
        newVerifier.gender = true
        self.state.confirmVerifierObserver.accept(newVerifier)
      })
      .disposed(by: disposeBag)
    
    // 기간 버튼 반응 -> (완료 버튼 활성/비활성 & 매칭 정보 전달)
    input.isSelectedPeriodButton
      .bind(onNext: { [unowned self] period in
        var newValue = self.currentOnboarding
        var newVerifier = self.currentConfirmVerifier
        newValue.joinPeriod = period
        self.output.myOnboarding.accept(newValue)
        newVerifier.period = true
        self.state.confirmVerifierObserver.accept(newVerifier)
      })
      .disposed(by: disposeBag)
    
    // 습관 버튼 클릭 -> 매칭 정보 전달
    input.isSelectedHabitButton
      .bind(onNext: { [unowned self] habit in
        var newValue = self.currentOnboarding
        switch habit {
        case .snoring:
          newValue.isSnoring.toggle()
        case .grinding:
          newValue.isGrinding.toggle()
        case .smoking:
          newValue.isSmoking.toggle()
        case .allowedFood:
          newValue.isAllowedFood.toggle()
        case .allowedEarphone:
          newValue.isWearEarphones.toggle()
        }
        self.output.myOnboarding.accept(newValue)
      })
      .disposed(by: disposeBag)
    
    // 질의 응답 반응 -> (완료 버튼 활성/비활성 & 매칭 정보 전달)
    input.onChangedQueryText
      .bind(onNext: { [unowned self] (queryList, contents) in
        var newValue = self.currentOnboarding
        var newVerifier = self.currentConfirmVerifier
        switch queryList {
        case .age:
          newValue.age = contents
          if contents == "" {
            newVerifier.age = false
          } else {
            newVerifier.age = true
          }
        case .wakeUp:
          newValue.wakeupTime = contents
          if contents == "" {
            newVerifier.wakeup = false
          } else {
            newVerifier.wakeup = true
          }
        case .cleanUp:
          newValue.cleanUpStatus = contents
          if contents == "" {
            newVerifier.cleanup = false
          } else {
            newVerifier.cleanup = true
          }
        case .chatLink:
          newValue.openKakaoLink = contents
          if contents == "" {
            newVerifier.chatLink = false
          } else {
            newVerifier.chatLink = true
          }
        case .mbti:
          newValue.mbti = contents
        case .shower:
          newValue.showerTime = contents
          if contents == "" {
            newVerifier.showerTime = false
          } else {
            newVerifier.showerTime = true
          }
        case .wishText:
          newValue.wishText = contents
        }
        self.state.confirmVerifierObserver.accept(newVerifier)
        self.output.myOnboarding.accept(newValue)
      })
      .disposed(by: disposeBag)
  }
  
  func bind() {
    
    // OnboardingVCType 별 이벤트 분기처리
    switch vcType {
    case .update:
      // 완료 버튼 클릭 -> 온보딩 수정 API 요청
      input.didTapConfirmButton
        .map { [unowned self] in
          return self.currentOnboarding
        }
        .do(onNext: { [weak self] _ in
          self?.output.indicatorState.onNext(true)
        })
        .flatMap {
          return APIService.onboardingProvider.rx.request(.modify($0))
        }
        .map(OnboardingModel.LookupOnboardingResponseModel.self)
        .subscribe(onNext: { [weak self] response in
          self?.output.indicatorState.onNext(false)
          MemberInfoStorage.instance.myOnboarding.accept(response.data)
          self?.output.pushToRootVC.onNext(Void())
        })
        .disposed(by: disposeBag)
      
      // 입력 초기화 버튼 -> 데이터 초기화
      input.didTapSkipButton
        .subscribe(onNext: { [weak self] in
          self?.resetData()
          self?.output.resetData.onNext(Void())
        })
        .disposed(by: disposeBag)
      
    case .mainPage_FirstTime:
      // 완료 버튼 클릭 -> 온보딩 디테일 VC 보여주기
      input.didTapConfirmButton
        .map { [unowned self] in self.currentOnboarding }
        .map { ModelTransformer.instance.toMemberModel(from: $0) }
        .bind(to: output.pushToOnboardingDetailVC)
        .disposed(by: disposeBag)
      
      // 입력 초기화 버튼 -> 데이터 초기화
      input.didTapSkipButton
        .subscribe(onNext: { [weak self] in
          self?.resetData()
          self?.output.resetData.onNext(Void())
        })
        .disposed(by: disposeBag)
      
    case .firstTime:
      // 완료 버튼 클릭 -> 온보딩 디테일 VC 보여주기
      input.didTapConfirmButton
        .map { [unowned self] in self.currentOnboarding }
        .map { ModelTransformer.instance.toMemberModel(from: $0) }
        .bind(to: output.pushToOnboardingDetailVC)
        .disposed(by: disposeBag)
      
      // 정보 입력 건너 뛰기 버튼 -> 메인 페이지로 이동
      input.didTapSkipButton
        .bind(to: output.showTabBarVC)
        .disposed(by: disposeBag)
    }
  }
  
  // MARK: - Helpers
  
  private func resetData() {
    output.myOnboarding.accept(.initialValue())
    state.confirmVerifierObserver.accept(.initialValue())
  }
}
