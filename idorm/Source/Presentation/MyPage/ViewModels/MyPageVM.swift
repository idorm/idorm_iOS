import RxSwift
import RxCocoa

final class MyPageViewModel: ViewModel {
  struct Input {
    // UI
    let gearButtonTapped = PublishSubject<Void>()
    let shareButtonTapped = PublishSubject<Bool>()
    let manageButtonTapped = PublishSubject<Void>()
    let roommateButtonTapped = PublishSubject<MyRoommateVCType>()
    
    // LifeCycle
    let viewWillAppearObserver = PublishSubject<Void>()
  }
  
  struct Output {
    // Presentation
    let pushToManageMyInfoVC = PublishSubject<Void>()
    let pushToMyRoommateVC = PublishSubject<MyRoommateVCType>()
    let pushToOnboardingVC = PublishSubject<Void>()
    
    // UI
    let indicatorState = PublishSubject<Bool>()
  }
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  init() {
    bind()
  }
  
  func bind() {
    
    // 설정 버튼 클릭 -> 내 정보 관리 페이지로 이동
    input.gearButtonTapped
      .bind(to: output.pushToManageMyInfoVC)
      .disposed(by: disposeBag)
    
    // 공유 버튼 클릭 -> 매칭 공개 여부 수정 API 요청
    input.shareButtonTapped
      .subscribe(onNext: { [weak self] in
        self?.requestUpdateMatchingPublicInfoAPI($0)
      })
      .disposed(by: disposeBag)
    
    // 좋아요한 룸메 & 싫어요한 룸메 버튼 클릭 -> 룸메이트 관리 페이지 이동
    input.roommateButtonTapped
      .bind(to: output.pushToMyRoommateVC)
      .disposed(by: disposeBag)
    
    // 마이페이지 버튼 클릭 -> 온보딩 수정 페이지로 이동
    input.manageButtonTapped
      .bind(to: output.pushToOnboardingVC)
      .disposed(by: disposeBag)
  }
}

// MARK: - Network

extension MyPageViewModel {
  
  /// 매칭 공개 여부 수정 API 요청
  func requestUpdateMatchingPublicInfoAPI(_ isPublic: Bool) {
    output.indicatorState.onNext(true)
    OnboardingService.shared.matchingInfoAPI_Patch(isPublic)
      .subscribe(onNext: { [weak self] response in
        guard let statusCode = response.response?.statusCode else { return }
        switch statusCode {
        case 200:
          struct ResponseModel: Codable {
            let data: MatchingInfo_Lookup
          }
          guard let data = response.data else { return }
          let newInfo = APIService.decode(ResponseModel.self, data: data).data
          MemberInfoStorage.instance.myOnboarding.accept(newInfo)
        default:
          fatalError()
        }
        self?.output.indicatorState.onNext(false)
      })
      .disposed(by: disposeBag)
  }
}
