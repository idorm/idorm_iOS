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
    let didTapSkipButton = PublishSubject<FloatyBottomViewType>()
    let didTapConfirmButton = PublishSubject<Void>()
  }
  
  struct Output {
    // State
    let matchingInfo = BehaviorRelay<MatchingInfo>(value: MatchingInfo.initialValue())
    
    // UI
    let isEnableConfirmButton = PublishSubject<Bool>()
    let showOnboardingDetailVC = PublishSubject<MatchingInfo>()
    let indicatorState = PublishSubject<Bool>()
    let resetData = PublishSubject<Void>()
    
    // Presentation
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
  
  private let vcType: OnboardingVCType
  
  var currentMatchingInfo: MatchingInfo { return output.matchingInfo.value }
  var currentConfirmVerifier: OnboardingConfirmVerifier { return state.confirmVerifierObserver.value }
  
  init(_ vcType: OnboardingVCType) {
    self.vcType = vcType
    mutate()
    bind()
  }
  
  // MARK: - Bind
  
  func mutate() {
    
    // 완료 버튼 활성&비활성화 -> Bool Stream 전달
    state.confirmVerifierObserver
      .map {
        if $0.dorm && $0.period && $0.age && $0.cleanup && $0.gender && $0.showerTime && $0.wakeup && $0.chatLink {
          return true
        } else {
          return false
        }
      }
      .bind(to: output.isEnableConfirmButton)
      .disposed(by: disposeBag)
  }
  
  func bind() {
    
    // 기숙사 버튼 반응 -> (완료 버튼 활성/비활성 & 매칭 정보 전달)
    input.isSelectedDormButton
      .bind(onNext: { [unowned self] dorm in
        var newInfo = self.currentMatchingInfo
        var newVerifier = self.currentConfirmVerifier
        newInfo.dormNumber = dorm
        self.output.matchingInfo.accept(newInfo)
        newVerifier.dorm = true
        self.state.confirmVerifierObserver.accept(newVerifier)
      })
      .disposed(by: disposeBag)
    
    // 성별 버튼 반응 -> (완료 버튼 활성/비활성 & 매칭 정보 전달)
    input.isSelectedGenderButton
      .bind(onNext: { [unowned self] gender in
        var newInfo = self.currentMatchingInfo
        var newVerifier = self.currentConfirmVerifier
        newInfo.gender = gender
        self.output.matchingInfo.accept(newInfo)
        newVerifier.gender = true
        self.state.confirmVerifierObserver.accept(newVerifier)
      })
      .disposed(by: disposeBag)
    
    // 기간 버튼 반응 -> (완료 버튼 활성/비활성 & 매칭 정보 전달)
    input.isSelectedPeriodButton
      .bind(onNext: { [unowned self] period in
        var newInfo = self.currentMatchingInfo
        var newVerifier = self.currentConfirmVerifier
        newInfo.period = period
        self.output.matchingInfo.accept(newInfo)
        newVerifier.period = true
        self.state.confirmVerifierObserver.accept(newVerifier)
      })
      .disposed(by: disposeBag)
    
    // 습관 버튼 클릭 -> 매칭 정보 전달
    input.isSelectedHabitButton
      .bind(onNext: { [unowned self] habit in
        var newInfo = self.currentMatchingInfo
        switch habit {
        case .snoring:
          newInfo.snoring.toggle()
        case .grinding:
          newInfo.grinding.toggle()
        case .smoking:
          newInfo.smoke.toggle()
        case .allowedFood:
          newInfo.allowedFood.toggle()
        case .allowedEarphone:
          newInfo.earphone.toggle()
        }
        self.output.matchingInfo.accept(newInfo)
      })
      .disposed(by: disposeBag)
    
    // 질의 응답 반응 -> (완료 버튼 활성/비활성 & 매칭 정보 전달)
    input.onChangedQueryText
      .bind(onNext: { [unowned self] (queryList, contents) in
        var newInfo = self.currentMatchingInfo
        var newVerifier = self.currentConfirmVerifier
        switch queryList {
        case .age:
          newInfo.age = contents
          if contents == "" {
            newVerifier.age = false
          } else {
            newVerifier.age = true
          }
        case .wakeUp:
          newInfo.wakeupTime = contents
          if contents == "" {
            newVerifier.wakeup = false
          } else {
            newVerifier.wakeup = true
          }
        case .cleanUp:
          newInfo.cleanUpStatus = contents
          if contents == "" {
            newVerifier.cleanup = false
          } else {
            newVerifier.cleanup = true
          }
        case .chatLink:
          newInfo.chatLink = contents
          if contents == "" {
            newVerifier.chatLink = false
          } else {
            newVerifier.chatLink = true
          }
        case .mbti:
          newInfo.mbti = contents
        case .shower:
          newInfo.showerTime = contents
          if contents == "" {
            newVerifier.showerTime = false
          } else {
            newVerifier.showerTime = true
          }
        case .wishText:
          newInfo.wishText = contents
        }
        self.state.confirmVerifierObserver.accept(newVerifier)
        self.output.matchingInfo.accept(newInfo)
      })
      .disposed(by: disposeBag)
    
    // 스킵 버튼 클릭 -> 여러 이벤트 방출
    input.didTapSkipButton
      .bind(onNext: { [weak self] skipType in
        switch skipType {
        case .reset:
          self?.resetData()
          self?.output.resetData.onNext(Void())
        case .jump:
          self?.output.showTabBarVC.onNext(Void())
        case .back, .filter, .correction:
          break
        }
      })
      .disposed(by: disposeBag)
    
    switch vcType {
    case .update:
      
      // 완료 버튼 클릭 -> 온보딩 현재 정보 수정하기
      input.didTapConfirmButton
        .bind(onNext: { [unowned self] in
          self.requestModifyMatchingInfo(self.currentMatchingInfo)
        })
        .disposed(by: disposeBag)
    case .firstTime, .mainPage_FirstTime:
      
      // 완료 버튼 클릭 -> 온보딩 디테일 VC 보여주기
      input.didTapConfirmButton
        .map { [unowned self] in self.currentMatchingInfo }
        .bind(to: output.showOnboardingDetailVC)
        .disposed(by: disposeBag)
    }
  }
  
  // MARK: - Helpers
  
  private func resetData() {
    output.matchingInfo.accept(MatchingInfo.initialValue())
    state.confirmVerifierObserver.accept(OnboardingConfirmVerifier.initialValue())
  }
}

// MARK: - Network

extension OnboardingViewModel {
  
  /// 현재 매칭 정보를 수정하는 API입니다.
  func requestModifyMatchingInfo(_ from: MatchingInfo) {
    output.indicatorState.onNext(true)
    OnboardingService.shared.matchingInfoAPI_Put(from)
      .subscribe(onNext: { [weak self] response in
        struct ResponseModel: Codable {
          let data: MatchingInfo_Lookup
        }
        guard let statusCode = response.response?.statusCode else { return }
        switch statusCode {
        case 200:
          guard let data = response.data else { return }
          let newInfo = APIService.decode(ResponseModel.self, data: data).data
          MemberInfoStorage.shared.matchingInfo.accept(newInfo)
          self?.output.pushToRootVC.onNext(Void())
        default:
          fatalError()
        }
        self?.output.indicatorState.onNext(false)
      })
      .disposed(by: disposeBag)
  }
}
