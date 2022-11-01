import RxSwift
import RxCocoa

class OnboardingViewModel: ViewModel {
  
  struct OnboardingVerifyConfirmList {
    var dorm: Bool
    var gender: Bool
    var period: Bool
    var age: Bool
    var wakeup: Bool
    var cleanup: Bool
    var showerTime: Bool
  }
  
  struct Input {
    let dorm1ButtonTapped = BehaviorRelay<Bool>(value: false)
    let dorm2ButtonTapped = BehaviorRelay<Bool>(value: false)
    let dorm3ButtonTapped = BehaviorRelay<Bool>(value: false)
    
    let maleButtonTapped = BehaviorRelay<Bool>(value: false)
    let femaleButtonTapped = BehaviorRelay<Bool>(value: false)
    
    let period16ButtonTapped = BehaviorRelay<Bool>(value: false)
    let period24ButtonTapped = BehaviorRelay<Bool>(value: false)
    
    let snoringButtonTapped = BehaviorRelay<Bool>(value: false)
    let grindingButtonTapped = BehaviorRelay<Bool>(value: false)
    let smokingButtonTapped = BehaviorRelay<Bool>(value: false)
    let allowedFoodButtonTapped = BehaviorRelay<Bool>(value: false)
    let allowedEarphoneButtonTapped = BehaviorRelay<Bool>(value: false)
    
    let ageTextFieldChanged = BehaviorRelay<String>(value: "")
    
    let wakeUpTimeTextFieldChanged = BehaviorRelay<String>(value: "")
    let cleanUpTimeTextFieldChanged = BehaviorRelay<String>(value: "")
    let showerTimeTextFieldChanged = BehaviorRelay<String>(value: "")
    let mbtiTextFieldChanged = BehaviorRelay<String>(value: "")
    let chatLinkTextFieldChanged = BehaviorRelay<String>(value: "")
    let wishTextTextFieldChanged = BehaviorRelay<String>(value: "")
    
    let didTapSkipButton = PublishSubject<Void>()
    let didTapConfirmButton = PublishSubject<Void>()
  }
  
  struct Output {
    let matchingInfo = BehaviorRelay<MatchingInfo?>(value: nil)
    let showOnboardingDetailVC = PublishSubject<MatchingInfo>()
    let showTabBarVC = PublishSubject<Void>()
    let resetData = PublishSubject<Void>()
    
    let enableConfirmButton = PublishSubject<Bool>()
  }
  
  /// output.myInfo 주입 객체
  var matchingInfo: MatchingInfo!
  /// ConfirmButton 활성/비활성화 Stream
  var isValidConfirmButton: BehaviorRelay<OnboardingVerifyConfirmList>!
  /// isValidConfirmButton 주입 객체
  var verifyConfirmButton: OnboardingVerifyConfirmList!
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  var numberOfRowsInSection: Int {
    return OnboardingListType.allCases.count
  }
  
  func getQuestionText(index: Int) -> String {
    return OnboardingListType.allCases[index].query
  }
  
  init() {
    inititalTask()
    bind()
  }
  
  func inititalTask() {
    self.matchingInfo = MatchingInfo(
      dormNumber: .no1,
      period: .period_24,
      gender: .female,
      age: "",
      snoring: false,
      grinding: false,
      smoke: false,
      allowedFood: false,
      earphone: false,
      wakeupTime: "",
      cleanUpStatus: "",
      showerTime: "",
      mbti: "",
      wishText: "",
      chatLink: ""
    )
    
    self.verifyConfirmButton = OnboardingVerifyConfirmList(
      dorm: false,
      gender: false,
      period: false,
      age: false,
      wakeup: false,
      cleanup: false,
      showerTime: false
    )
    
    self.isValidConfirmButton = BehaviorRelay<OnboardingVerifyConfirmList>(value: self.verifyConfirmButton)
  }
  
  // MARK: - Bind
  
  /// 데이터 변경 바인딩
  func bindData() {
    input.dorm1ButtonTapped
      .subscribe(onNext: { [unowned self] isSelected in
        if isSelected {
          self.matchingInfo.dormNumber = .no1
          self.output.matchingInfo.accept(self.matchingInfo)
          self.verifyConfirmButton.dorm = true
          self.isValidConfirmButton.accept(self.verifyConfirmButton)
        }
      })
      .disposed(by: disposeBag)
    
    input.dorm2ButtonTapped
      .subscribe(onNext: { [unowned self] isSelected in
        if isSelected {
          self.matchingInfo.dormNumber = .no2
          self.output.matchingInfo.accept(self.matchingInfo)
          self.verifyConfirmButton.dorm = true
          self.isValidConfirmButton.accept(self.verifyConfirmButton)
        }
      })
      .disposed(by: disposeBag)

    input.dorm3ButtonTapped
      .subscribe(onNext: { [unowned self] isSelected in
        if isSelected {
          self.matchingInfo.dormNumber = .no3
          self.output.matchingInfo.accept(self.matchingInfo)
          self.verifyConfirmButton.dorm = true
          self.isValidConfirmButton.accept(self.verifyConfirmButton)
        }
      })
      .disposed(by: disposeBag)

    input.maleButtonTapped
      .subscribe(onNext: { [unowned self] isSelected in
        if isSelected {
          self.matchingInfo.gender = .male
          self.output.matchingInfo.accept(self.matchingInfo)
          self.verifyConfirmButton.gender = true
          self.isValidConfirmButton.accept(self.verifyConfirmButton)
        }
      })
      .disposed(by: disposeBag)
    
    input.femaleButtonTapped
      .subscribe(onNext: { [unowned self] isSelected in
        if isSelected {
          self.matchingInfo.gender = .female
          self.output.matchingInfo.accept(self.matchingInfo)
          self.verifyConfirmButton.gender = true
          self.isValidConfirmButton.accept(self.verifyConfirmButton)
        }
      })
      .disposed(by: disposeBag)

    input.period16ButtonTapped
      .subscribe(onNext: { [unowned self] isSelected in
        if isSelected {
          self.matchingInfo.period = .period_16
          self.output.matchingInfo.accept(self.matchingInfo)
          self.verifyConfirmButton.period = true
          self.isValidConfirmButton.accept(self.verifyConfirmButton)
        }
      })
      .disposed(by: disposeBag)
    
    input.period24ButtonTapped
      .subscribe(onNext: { [unowned self] isSelected in
        if isSelected {
          self.matchingInfo.period = .period_24
          self.output.matchingInfo.accept(self.matchingInfo)
          self.verifyConfirmButton.period = true
          self.isValidConfirmButton.accept(self.verifyConfirmButton)
        }
      })
      .disposed(by: disposeBag)
    
    input.snoringButtonTapped
      .subscribe(onNext: { [unowned self] isSelected in
        self.matchingInfo.snoring = isSelected
        self.output.matchingInfo.accept(self.matchingInfo)
      })
      .disposed(by: disposeBag)

    input.grindingButtonTapped
      .subscribe(onNext: { [unowned self] isSelected in
        self.matchingInfo.grinding = isSelected
        self.output.matchingInfo.accept(self.matchingInfo)
      })
      .disposed(by: disposeBag)

    input.smokingButtonTapped
      .subscribe(onNext: { [unowned self] isSelected in
        self.matchingInfo.smoke = isSelected
        self.output.matchingInfo.accept(self.matchingInfo)
      })
      .disposed(by: disposeBag)

    input.allowedFoodButtonTapped
      .subscribe(onNext: { [unowned self] isSelected in
        self.matchingInfo.allowedFood = isSelected
        self.output.matchingInfo.accept(self.matchingInfo)
      })
      .disposed(by: disposeBag)

    input.allowedEarphoneButtonTapped
      .subscribe(onNext: { [unowned self] isSelected in
        self.matchingInfo.earphone = isSelected
        self.output.matchingInfo.accept(self.matchingInfo)
      })
      .disposed(by: disposeBag)
    
    input.ageTextFieldChanged
      .subscribe(onNext: { [unowned self] text in
        self.matchingInfo.age = text
        self.output.matchingInfo.accept(self.matchingInfo)
        if text != "" {
          self.verifyConfirmButton.age = true
          self.isValidConfirmButton.accept(self.verifyConfirmButton)
        } else {
          self.verifyConfirmButton.age = false
          self.isValidConfirmButton.accept(self.verifyConfirmButton)
        }
      })
      .disposed(by: disposeBag)
    
    input.wakeUpTimeTextFieldChanged
      .subscribe(onNext: { [unowned self] text in
        self.matchingInfo.wakeupTime = text
        self.output.matchingInfo.accept(self.matchingInfo)
        if text != "" {
          self.verifyConfirmButton.wakeup = true
          self.isValidConfirmButton.accept(self.verifyConfirmButton)
        } else {
          self.verifyConfirmButton.wakeup = false
          self.isValidConfirmButton.accept(self.verifyConfirmButton)
        }
      })
      .disposed(by: disposeBag)
    
    input.cleanUpTimeTextFieldChanged
      .subscribe(onNext: { [unowned self] text in
        self.matchingInfo.cleanUpStatus = text
        self.output.matchingInfo.accept(self.matchingInfo)
        if text != "" {
          self.verifyConfirmButton.cleanup = true
          self.isValidConfirmButton.accept(self.verifyConfirmButton)
        } else {
          self.verifyConfirmButton.cleanup = false
          self.isValidConfirmButton.accept(self.verifyConfirmButton)
        }
      })
      .disposed(by: disposeBag)

    input.showerTimeTextFieldChanged
      .subscribe(onNext: { [unowned self] text in
        self.matchingInfo.showerTime = text
        self.output.matchingInfo.accept(self.matchingInfo)
        if text != "" {
          self.verifyConfirmButton.showerTime = true
          self.isValidConfirmButton.accept(self.verifyConfirmButton)
        } else {
          self.verifyConfirmButton.showerTime = false
          self.isValidConfirmButton.accept(self.verifyConfirmButton)
        }
      })
      .disposed(by: disposeBag)

    input.mbtiTextFieldChanged
      .subscribe(onNext: { [unowned self] text in
        self.matchingInfo.mbti = text
        self.output.matchingInfo.accept(self.matchingInfo)
      })
      .disposed(by: disposeBag)

    input.chatLinkTextFieldChanged
      .subscribe(onNext: { [unowned self] text in
        self.matchingInfo.chatLink = text
        self.output.matchingInfo.accept(self.matchingInfo)
      })
      .disposed(by: disposeBag)

    input.wishTextTextFieldChanged
      .subscribe(onNext: { [unowned self] text in
        self.matchingInfo.wishText = text
        self.output.matchingInfo.accept(self.matchingInfo)
      })
      .disposed(by: disposeBag)
  }
  
  func bind() {
    bindData()
    
    // 완료 버튼 활성화 비활성화
    isValidConfirmButton
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
    
    // 정보 입력 건너 뛰기 버튼 클릭 -> 메인 화면 이동
    input.didTapSkipButton
      .bind(to: output.showTabBarVC)
      .disposed(by: disposeBag)
    
    // 입력 초기화 버튼 클릭 -> 모든 입력 초기화
    input.didTapSkipButton
      .map { [unowned self] in self.resetData() }
      .bind(to: output.resetData)
      .disposed(by: disposeBag)
  }
  
  // MARK: - Helpers
  
  private func resetData() {
    self.matchingInfo = MatchingInfo(
      dormNumber: .no1,
      period: .period_24,
      gender: .female,
      age: "",
      snoring: false,
      grinding: false,
      smoke: false,
      allowedFood: false,
      earphone: false,
      wakeupTime: "",
      cleanUpStatus: "",
      showerTime: "",
      mbti: "",
      wishText: "",
      chatLink: ""
    )
    output.matchingInfo.accept(self.matchingInfo)
  }
}
