import RxSwift
import RxCocoa

final class MyPageViewModel: ViewModel {
  
  // MARK: - Properties
  
  struct Input {
    // UI
    let gearButtonDidTap = PublishSubject<Void>()
    let shareButtonDidTap = PublishSubject<Bool>()
    let manageButtonDidTap = PublishSubject<Void>()
    let roommateButtonDidTap = PublishSubject<MyPageVCTypes.MyRoommateVCType>()
    
    // LifeCycle
    let viewWillAppearObserver = PublishSubject<Void>()
  }
  
  struct Output {
    // Presentation
    let pushToManageMyInfoVC = PublishSubject<Void>()
    let pushToMyRoommateVC = PublishSubject<MyPageVCTypes.MyRoommateVCType>()
    let pushToOnboardingVC = PublishSubject<Void>()
    
    // UI
    let indicatorState = PublishSubject<Bool>()
    let toggleShareButton = PublishSubject<Void>()
  }
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  // MARK: - Bind
  
  init() {
    
    // 설정 버튼 클릭 -> 내 정보 관리 페이지로 이동
    input.gearButtonDidTap
      .bind(to: output.pushToManageMyInfoVC)
      .disposed(by: disposeBag)
    
    // 공유 버튼 클릭 -> 매칭 공개 여부 수정 API 요청
    input.shareButtonDidTap
      .do(onNext: { [weak self] _ in self?.output.indicatorState.onNext(true) })
      .flatMap { return APIService.onboardingProvider.rx.request(.modifyPublic($0)) }
      .map(OnboardingModel.LookupOnboardingResponseModel.self)
      .subscribe(onNext: { [weak self] response in
        MemberInfoStorage.instance.myOnboarding.accept(response.data)
        self?.output.toggleShareButton.onNext(Void())
        self?.output.indicatorState.onNext(false)
      })
      .disposed(by: disposeBag)
    
    // 좋아요한 룸메 & 싫어요한 룸메 버튼 클릭 -> 룸메이트 관리 페이지 이동
    input.roommateButtonDidTap
      .bind(to: output.pushToMyRoommateVC)
      .disposed(by: disposeBag)
    
    // 마이페이지 버튼 클릭 -> 온보딩 수정 페이지로 이동
    input.manageButtonDidTap
      .bind(to: output.pushToOnboardingVC)
      .disposed(by: disposeBag)
  }
}
