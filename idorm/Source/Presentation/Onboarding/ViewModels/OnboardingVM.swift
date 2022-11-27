import RxSwift
import RxCocoa
import RxOptional

final class OnboardingViewModel: ViewModel {
  
  struct Input {
    let viewDidLoad = PublishSubject<Void>()
    let dormButtonDidTap = PublishSubject<Dormitory>()
    let genderButtonDidTap = PublishSubject<Gender>()
    let joinPeriodButtonDidTap = PublishSubject<JoinPeriod>()
    let isSnoringButtonDidTap = PublishSubject<Bool>()
    let isGrindingButtonDidTap = PublishSubject<Bool>()
    let isSmokingButtonDidTap = PublishSubject<Bool>()
    let isAllowedFoodButtonDidTap = PublishSubject<Bool>()
    let isAllowedEarphoneButtonDidTap = PublishSubject<Bool>()
    let ageTextFieldDidChange = PublishSubject<String>()
    let wakeUpTextFieldDidChange = PublishSubject<String>()
    let cleanUpTextFieldDidChange = PublishSubject<String>()
    let showerTimeTextFieldDidChange = PublishSubject<String>()
    let kakaoLinkTextFieldDidChange = PublishSubject<String>()
    let mbtiTextFieldDidChange = PublishSubject<String>()
    let wishTextViewDidChange = PublishSubject<String>()
    let scrollViewDidTap = PublishSubject<Void>()
    let leftButtonDidTap = PublishSubject<Void>()
    let rightButtonDidTap = PublishSubject<Void>()
  }
  
  struct Output {
    let toggleDormButton = PublishSubject<Dormitory>()
    let toggleGenderButton = PublishSubject<Gender>()
    let toggleJoinPeriodButton = PublishSubject<JoinPeriod>()
    let toggleIsSnoringButton = PublishSubject<Bool>()
    let toggleIsGrindingButton = PublishSubject<Bool>()
    let toggleIsSmokingButton = PublishSubject<Bool>()
    let toggleIsAllowedFoodButton = PublishSubject<Bool>()
    let toggleIsAllowedEarphoneButton = PublishSubject<Bool>()
    let isEnabledConfirmButton = PublishSubject<Bool>()
    let currentTextViewLength = PublishSubject<Int>()
    let endEditing = PublishSubject<Void>()
    let isLoading = PublishSubject<Bool>()
    let setupUI = PublishSubject<OnboardingModel.MyOnboarding>()
    let reset = PublishSubject<Void>()
    let pushToOnboardingDetailVC = PublishSubject<MatchingModel.Member>()
    let presentMainVC = PublishSubject<Void>()
    let popToRootVC = PublishSubject<Void>()
  }
  
  // MARK: - Properties
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  private let vcType: OnboardingVCTypes.OnboardingVCType
  private let currentOnboarding = BehaviorRelay<OnboardingModel.RequestModel>(value: .initialValue())
  private let driver = OnboardingDriver()
  
  // MARK: - Bind
  
  init(_ vcType: OnboardingVCTypes.OnboardingVCType) {
    self.vcType = vcType
    mutate()
    
    // 기숙사 버튼 클릭 -> 토글
    input.dormButtonDidTap
      .bind(to: output.toggleDormButton)
      .disposed(by: disposeBag)
    
    // 성별 버튼 클릭 -> 토글
    input.genderButtonDidTap
      .bind(to: output.toggleGenderButton)
      .disposed(by: disposeBag)
    
    // 입사기간 버튼 클릭 -> 토글
    input.joinPeriodButtonDidTap
      .bind(to: output.toggleJoinPeriodButton)
      .disposed(by: disposeBag)
    
    // 코골이 버튼 클릭 -> 토글
    input.isSnoringButtonDidTap
      .bind(to: output.toggleIsSnoringButton)
      .disposed(by: disposeBag)
    
    // 이갈이 버튼 클릭 -> 토글
    input.isGrindingButtonDidTap
      .bind(to: output.toggleIsGrindingButton)
      .disposed(by: disposeBag)
    
    // 흡연 버튼 클릭 -> 토글
    input.isSmokingButtonDidTap
      .bind(to: output.toggleIsSmokingButton)
      .disposed(by: disposeBag)
    
    // 음식 버튼 클릭 -> 토글
    input.isAllowedFoodButtonDidTap
      .bind(to: output.toggleIsAllowedFoodButton)
      .disposed(by: disposeBag)
    
    // 이어폰 버튼 클릭 -> 토글
    input.isAllowedEarphoneButtonDidTap
      .bind(to: output.toggleIsAllowedEarphoneButton)
      .disposed(by: disposeBag)
    
    // 드라이버 조건 -> 완료 버튼 활성화
    driver.isEnabled
      .bind(to: output.isEnabledConfirmButton)
      .disposed(by: disposeBag)
    
    // 텍스트 뷰 반응 -> 글자 수
    input.wishTextViewDidChange
      .map { $0.count }
      .bind(to: output.currentTextViewLength)
      .disposed(by: disposeBag)
    
    // 입력 초기화 버튼 -> 리셋
    input.leftButtonDidTap
      .bind(to: output.reset)
      .disposed(by: disposeBag)
    
    // 스크롤 뷰 터치 -> 에디팅 강제 종료
    input.scrollViewDidTap
      .bind(to: output.endEditing)
      .disposed(by: disposeBag)
    
    switch vcType {
    case .initial:
      
      // 정보 입력 건너 뛰기 버튼 -> 메인페이지
      input.leftButtonDidTap
        .bind(to: output.presentMainVC)
        .disposed(by: disposeBag)
      
      // 완료 버튼 -> OnboardingDetailVC
      input.rightButtonDidTap
        .withUnretained(self)
        .map { $0.0 }
        .map { ModelTransformer.instance.toMemberModel(from: $0.currentOnboarding.value) }
        .bind(to: output.pushToOnboardingDetailVC)
        .disposed(by: disposeBag)
      
    case .initial2:
      
      // 입력 초기화 버튼 -> 초기화
      input.leftButtonDidTap
        .bind(to: output.reset)
        .disposed(by: disposeBag)
      
      // 완료 버튼 -> OnboardingDetailVC
      input.rightButtonDidTap
        .withUnretained(self)
        .map { $0.0 }
        .map { ModelTransformer.instance.toMemberModel(from: $0.currentOnboarding.value) }
        .bind(to: output.pushToOnboardingDetailVC)
        .disposed(by: disposeBag)
      
    case .update:
      
      // 입력 초기화 버튼 -> 초기화
      input.leftButtonDidTap
        .bind(to: output.reset)
        .disposed(by: disposeBag)
      
      // 완료 버튼 -> 매칭 정보 수정 API 요청
      input.rightButtonDidTap
        .withUnretained(self)
        .map { $0.0 }
        .do(onNext: { $0.output.isLoading.onNext(true) })
        .map { $0.currentOnboarding.value }
        .flatMap { APIService.onboardingProvider.rx.request(.modify($0)) }
        .map(OnboardingModel.LookupOnboardingResponseModel.self)
        .withUnretained(self)
        .subscribe(onNext: { owner, response in
          MemberInfoStorage.instance.myOnboarding.accept(response.data)
          owner.output.isLoading.onNext(false)
          owner.output.popToRootVC.onNext(Void())
        })
        .disposed(by: disposeBag)
      
      // 화면 최초 접속 -> 저장되어있는 온보딩 정보 셋업
      input.viewDidLoad
        .map { MemberInfoStorage.instance.myOnboarding.value }
        .filterNil()
        .bind(to: output.setupUI)
        .disposed(by: disposeBag)
    }
  }
  
  // MARK: - Mutate
  
  private func mutate() {
    
    // 기숙사 버튼 -> Driver 업데이트
    input.dormButtonDidTap
      .map { _ in true }
      .bind(to: driver.dormConditon)
      .disposed(by: disposeBag)
    
    // 성별 버튼 -> Driver 업데이트
    input.genderButtonDidTap
      .map { _ in true }
      .bind(to: driver.genderCondition)
      .disposed(by: disposeBag)
    
    // 입사 기간 버튼 -> Driver 업데이트
    input.joinPeriodButtonDidTap
      .map { _ in true }
      .bind(to: driver.joinPeriodCondition)
      .disposed(by: disposeBag)
    
    // 나이 텍스트필드 반응 -> Driver 업데이트
    input.ageTextFieldDidChange
      .map { $0 != "" }
      .bind(to: driver.ageCondition)
      .disposed(by: disposeBag)
    
    // 기상시간 텍스트필드 반응 -> Driver 업데이트
    input.wakeUpTextFieldDidChange
      .map { $0 != "" }
      .bind(to: driver.wakeUpCondition)
      .disposed(by: disposeBag)
    
    // 정리정돈 텍스트필드 반응 -> Driver 업데이트
    input.cleanUpTextFieldDidChange
      .map { $0 != "" }
      .bind(to: driver.cleanupCondition)
      .disposed(by: disposeBag)
    
    // 샤워시간 텍스트필드 반응 -> Driver 업데이트
    input.showerTimeTextFieldDidChange
      .map { $0 != "" }
      .bind(to: driver.showerTimeCondition)
      .disposed(by: disposeBag)
    
    // 오픈채팅 텍스트필드 반응 -> Driver 업데이트
    input.kakaoLinkTextFieldDidChange
      .map { $0 != "" }
      .bind(to: driver.chatLinkCondition)
      .disposed(by: disposeBag)
    
    // 기숙사 버튼 반응 -> 온보딩 저장
    input.dormButtonDidTap
      .withUnretained(self)
      .map {
        var newValue = $0.currentOnboarding.value
        newValue.dormNum = $1
        return newValue
      }
      .bind(to: currentOnboarding)
      .disposed(by: disposeBag)
    
    // 성별 버튼 반응 -> 온보딩 저장
    input.genderButtonDidTap
      .withUnretained(self)
      .map {
        var newValue = $0.currentOnboarding.value
        newValue.gender = $1
        return newValue
      }
      .bind(to: currentOnboarding)
      .disposed(by: disposeBag)
    
    // 입사기간 버튼 반응 -> 온보딩 저장
    input.joinPeriodButtonDidTap
      .withUnretained(self)
      .map {
        var newValue = $0.currentOnboarding.value
        newValue.joinPeriod = $1
        return newValue
      }
      .bind(to: currentOnboarding)
      .disposed(by: disposeBag)
    
    // 코골이 버튼 반응 -> 온보딩 저장
    input.isSnoringButtonDidTap
      .withUnretained(self)
      .map {
        var newValue = $0.currentOnboarding.value
        newValue.isSnoring = $1
        return newValue
      }
      .bind(to: currentOnboarding)
      .disposed(by: disposeBag)
    
    // 이갈이 버튼 반응 -> 온보딩 저장
    input.isGrindingButtonDidTap
      .withUnretained(self)
      .map {
        var newValue = $0.currentOnboarding.value
        newValue.isGrinding = $1
        return newValue
      }
      .bind(to: currentOnboarding)
      .disposed(by: disposeBag)
    
    // 흡연 버튼 반응 -> 온보딩 저장
    input.isSmokingButtonDidTap
      .withUnretained(self)
      .map {
        var newValue = $0.currentOnboarding.value
        newValue.isSmoking = $1
        return newValue
      }
      .bind(to: currentOnboarding)
      .disposed(by: disposeBag)
    
    // 실내 음식 섭취 버튼 반응 -> 온보딩 저장
    input.isAllowedFoodButtonDidTap
      .withUnretained(self)
      .map {
        var newValue = $0.currentOnboarding.value
        newValue.isAllowedFood = $1
        return newValue
      }
      .bind(to: currentOnboarding)
      .disposed(by: disposeBag)
    
    // 이어폰 착용 버튼 반응 -> 온보딩 저장
    input.isAllowedEarphoneButtonDidTap
      .withUnretained(self)
      .map {
        var newValue = $0.currentOnboarding.value
        newValue.isWearEarphones = $1
        return newValue
      }
      .bind(to: currentOnboarding)
      .disposed(by: disposeBag)
    
    // 나이 텍스트필드 반응 -> 온보딩 저장
    input.ageTextFieldDidChange
      .withUnretained(self)
      .map {
        var newValue = $0.currentOnboarding.value
        newValue.age = $1
        return newValue
      }
      .bind(to: currentOnboarding)
      .disposed(by: disposeBag)
    
    // 기상시간 텍스트필드 반응 -> 온보딩 저장
    input.wakeUpTextFieldDidChange
      .withUnretained(self)
      .map {
        var newValue = $0.currentOnboarding.value
        newValue.wakeupTime = $1
        return newValue
      }
      .bind(to: currentOnboarding)
      .disposed(by: disposeBag)
    
    // 정리정돈 텍스트필드 반응 -> 온보딩 저장
    input.cleanUpTextFieldDidChange
      .withUnretained(self)
      .map {
        var newValue = $0.currentOnboarding.value
        newValue.cleanUpStatus = $1
        return newValue
      }
      .bind(to: currentOnboarding)
      .disposed(by: disposeBag)
    
    // 샤워시간 텍스트필드 반응 -> 온보딩 저장
    input.showerTimeTextFieldDidChange
      .withUnretained(self)
      .map {
        var newValue = $0.currentOnboarding.value
        newValue.showerTime = $1
        return newValue
      }
      .bind(to: currentOnboarding)
      .disposed(by: disposeBag)
    
    // 오픈채팅 텍스트필드 반응 -> 온보딩 저장
    input.kakaoLinkTextFieldDidChange
      .withUnretained(self)
      .map {
        var newValue = $0.currentOnboarding.value
        newValue.openKakaoLink = $1
        return newValue
      }
      .bind(to: currentOnboarding)
      .disposed(by: disposeBag)
    
    // mbti 텍스트필드 반응 -> 온보딩 저장
    input.mbtiTextFieldDidChange
      .withUnretained(self)
      .map {
        var newValue = $0.currentOnboarding.value
        newValue.mbti = $1
        return newValue
      }
      .bind(to: currentOnboarding)
      .disposed(by: disposeBag)
    
    // 하고싶은말 텍스트뷰 반응 -> 온보딩 저장
    input.wishTextViewDidChange
      .withUnretained(self)
      .map {
        var newValue = $0.currentOnboarding.value
        newValue.wishText = $1
        return newValue
      }
      .bind(to: currentOnboarding)
      .disposed(by: disposeBag)
    
    // 입력 초기화 버튼 -> 온보딩 초기화
    input.leftButtonDidTap
      .map { OnboardingModel.RequestModel.initialValue() }
      .bind(to: currentOnboarding)
      .disposed(by: disposeBag)
    
    if vcType == .update {
      
      // 화면 최초 접속 -> 온보딩 주입
      input.viewDidLoad
        .map { MemberInfoStorage.instance.myOnboarding.value }
        .filterNil()
        .map { ModelTransformer.instance.toOnboardingRequestModel(from: $0) }
        .bind(to: currentOnboarding)
        .disposed(by: disposeBag)
      
      // 화면 최초 접속 -> Driver 주입
      input.viewDidLoad
        .withUnretained(self)
        .subscribe(onNext: { owner, _ in
          owner.driver.convertConditionToAll()
        })
        .disposed(by: disposeBag)
    }
  }
}
