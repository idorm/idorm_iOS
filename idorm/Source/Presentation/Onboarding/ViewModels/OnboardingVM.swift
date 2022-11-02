import RxSwift
import RxCocoa

class OnboardingViewModel: ViewModel {
  
  struct Input {
    let isSelectedDormButton = PublishSubject<Dormitory>()
    let isSelectedGenderButton = PublishSubject<Gender>()
    let isSelectedPeriodButton = PublishSubject<JoinPeriod>()
    let isSelectedHabitButton = PublishSubject<Habit>()
    let onChangedQueryText = PublishSubject<(QueryList, String)>()
    let didTapSkipButton = PublishSubject<FloatyBottomViewType>()
    let didTapConfirmButton = PublishSubject<Void>()
  }
  
  struct Output {
    let matchingInfo = BehaviorRelay<MatchingInfo?>(value: nil)
    let showOnboardingDetailVC = PublishSubject<MatchingInfo>()
    let showTabBarVC = PublishSubject<Void>()
    let resetData = PublishSubject<Void>()
    
    let enableConfirmButton = PublishSubject<Bool>()
  }
  
  /// output.matchinInfo 주입 객체
  var matchingInfo = MatchingInfo.initialValue()
  /// ConfirmButton 활성/비활성화 Stream
  var isEnableConfirmButton: BehaviorRelay<OnboardingVerifyConfirmList>!
  /// isValidConfirmButton 주입 객체
  var verifyConfirmButton = OnboardingVerifyConfirmList.initialValue()
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  init() {
    inititalTask()
    bind()
  }
  
  func inititalTask() {
    self.verifyConfirmButton = OnboardingVerifyConfirmList(
      dorm: false,
      gender: false,
      period: false,
      age: false,
      wakeup: false,
      cleanup: false,
      showerTime: false
    )
    
    self.isEnableConfirmButton = BehaviorRelay<OnboardingVerifyConfirmList>(value: self.verifyConfirmButton)
  }
  
  // MARK: - Bind
  
  func bind() {
    
    // 기숙사 버튼 반응 -> (완료 버튼 활성/비활성 & 매칭 정보 전달)
    input.isSelectedDormButton
      .bind(onNext: { [unowned self] dorm in
        self.matchingInfo.dormNumber = dorm
        self.output.matchingInfo.accept(self.matchingInfo)
        self.verifyConfirmButton.dorm = true
        self.isEnableConfirmButton.accept(self.verifyConfirmButton)
      })
      .disposed(by: disposeBag)
    
    // 성별 버튼 반응 -> (완료 버튼 활성/비활성 & 매칭 정보 전달)
    input.isSelectedGenderButton
      .bind(onNext: { [unowned self] gender in
        self.matchingInfo.gender = gender
        self.output.matchingInfo.accept(self.matchingInfo)
        self.verifyConfirmButton.gender = true
        self.isEnableConfirmButton.accept(self.verifyConfirmButton)
      })
      .disposed(by: disposeBag)
    
    // 기간 버튼 반응 -> (완료 버튼 활성/비활성 & 매칭 정보 전달)
    input.isSelectedPeriodButton
      .bind(onNext: { [unowned self] period in
        self.matchingInfo.period = period
        self.output.matchingInfo.accept(self.matchingInfo)
        self.verifyConfirmButton.period = true
        self.isEnableConfirmButton.accept(self.verifyConfirmButton)
      })
      .disposed(by: disposeBag)
    
    // 습관 버튼 클릭 -> 매칭 정보 전달
    input.isSelectedHabitButton
      .bind(onNext: { [unowned self] habit in
        switch habit {
        case .snoring:
          self.matchingInfo.snoring.toggle()
        case .grinding:
          self.matchingInfo.grinding.toggle()
        case .smoking:
          self.matchingInfo.smoke.toggle()
        case .allowedFood:
          self.matchingInfo.allowedFood.toggle()
        case .allowedEarphone:
          self.matchingInfo.earphone.toggle()
        }
        self.output.matchingInfo.accept(self.matchingInfo)
      })
      .disposed(by: disposeBag)
    
    // 질의 응답 반응 -> (완료 버튼 활성/비활성 & 매칭 정보 전달)
    input.onChangedQueryText
      .bind(onNext: { [unowned self] (queryList, contents) in
        switch queryList {
        case .age:
          self.matchingInfo.age = contents
          if contents == "" {
            self.verifyConfirmButton.age = false
          } else {
            self.verifyConfirmButton.age = true
          }
        case .wakeUp:
          self.matchingInfo.wakeupTime = contents
          if contents == "" {
            self.verifyConfirmButton.wakeup = false
          } else {
            self.verifyConfirmButton.wakeup = true
          }
        case .cleanUp:
          self.matchingInfo.cleanUpStatus = contents
          if contents == "" {
            self.verifyConfirmButton.cleanup = false
          } else {
            self.verifyConfirmButton.cleanup = true
          }
        case .chatLink:
          self.matchingInfo.chatLink = contents
        case .mbti:
          self.matchingInfo.mbti = contents
        case .shower:
          self.matchingInfo.showerTime = contents
          if contents == "" {
            self.verifyConfirmButton.showerTime = false
          } else {
            self.verifyConfirmButton.showerTime = true
          }
        case .wishText:
          self.matchingInfo.wishText = contents
        }
        self.isEnableConfirmButton.accept(self.verifyConfirmButton)
        self.output.matchingInfo.accept(self.matchingInfo)
      })
      .disposed(by: disposeBag)
    
    // 완료 버튼 활성화 비활성화 Stream
    isEnableConfirmButton
      .map {
        if $0.wakeup == true &&
            $0.cleanup == true &&
            $0.showerTime == true &&
            $0.age == true &&
            $0.dorm == true &&
            $0.gender == true &&
            $0.period == true
        {
          return true
        } else {
          return false
        }
      }
      .bind(to: output.enableConfirmButton)
      .disposed(by: disposeBag)
    
    // 완료 버튼 클릭 -> 온보딩 디테일 VC 보여주기
    input.didTapConfirmButton
      .map { [unowned self] in self.matchingInfo }
      .bind(to: output.showOnboardingDetailVC)
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
        case .back, .filter:
          break
        }
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: - Helpers
  
  private func resetData() {
    self.matchingInfo = MatchingInfo.initialValue()
    self.verifyConfirmButton = OnboardingVerifyConfirmList.initialValue()
    self.isEnableConfirmButton.accept(self.verifyConfirmButton)
    output.matchingInfo.accept(self.matchingInfo)
  }
}
