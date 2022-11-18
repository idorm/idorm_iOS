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
  }
  
  func bind() {
    
    // 기숙사 버튼 반응 -> (완료 버튼 활성/비활성 & 매칭 정보 전달)
    input.isSelectedDormButton
      .bind(onNext: { [unowned self] dorm in
        var newValue = self.output.myOnboarding.value
        var newVerifier = self.currentConfirmVerifier
        newValue.dormNumber = dorm
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
        newValue.period = period
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
          newValue.snoring.toggle()
        case .grinding:
          newValue.grinding.toggle()
        case .smoking:
          newValue.smoke.toggle()
        case .allowedFood:
          newValue.allowedFood.toggle()
        case .allowedEarphone:
          newValue.earphone.toggle()
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
          newValue.chatLink = contents
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
    
    // OnboardingVCType 별 이벤트 분기처리
    switch vcType {
    case .update:
      // 완료 버튼 클릭 -> 온보딩 현재 정보 수정하기
      input.didTapConfirmButton
        .bind(onNext: { [unowned self] in
//          self.requestModifyMatchingInfo(self.currentMatchingInfo)
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
        .map { [weak self] in
          guard let self = self else { return }
          return OnboardingModel.RequestModel.toMemberModel(from: self.currentOnboarding)
        }
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
        .map { [weak self] in
          guard let self = self else { return }
          return OnboardingModel.RequestModel.toMemberModel(from: self.currentOnboarding)
        }
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

// MARK: - Network

extension OnboardingViewModel {
//
//  /// 현재 매칭 정보를 수정하는 API입니다.
//  func requestModifyMatchingInfo(_ from: MatchingInfo) {
//    output.indicatorState.onNext(true)
//    OnboardingService.shared.matchingInfoAPI_Put(from)
//      .subscribe(onNext: { [weak self] response in
//        struct ResponseModel: Codable {
//          let data: MatchingInfo_Lookup
//        }
//        guard let statusCode = response.response?.statusCode else { return }
//        switch statusCode {
//        case 200:
//          guard let data = response.data else { return }
//          let newInfo = APIService.decode(ResponseModel.self, data: data).data
//          MemberInfoStorage.instance.myOnboarding.accept(newInfo)
//          self?.output.pushToRootVC.onNext(Void())
//        default:
//          fatalError()
//        }
//        self?.output.indicatorState.onNext(false)
//      })
//      .disposed(by: disposeBag)
//  }
}
