import RxSwift
import RxCocoa

final class MyPageViewModel: ViewModel {
  struct Input {
    // UI
    let gearButtonTapped = PublishSubject<Void>()
    let shareButtonTapped = PublishSubject<Bool>()
    let manageButtonTapped = PublishSubject<Void>()
    
    // LifeCycle
    let viewWillAppearObserver = PublishSubject<Void>()
  }
  
  struct Output {
    // Presentation
    let pushManageMyInfoVC = PublishSubject<Void>()
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
      .bind(to: output.pushManageMyInfoVC)
      .disposed(by: disposeBag)
    
    // 공유 버튼 클릭 -> 매칭 공개 여부 수정 API 요청
    input.shareButtonTapped
      .subscribe(onNext: { [weak self] in
        self?.requestUpdateMatchingPublicInfoAPI($0)
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - Network

extension MyPageViewModel {
  
  /// 매칭 공개 여부 수정 API 요청
  func requestUpdateMatchingPublicInfoAPI(_ isPublic: Bool) {
    OnboardingService.shared.matchingInfoAPI_Patch(isPublic)
      .subscribe(onNext: { response in
        guard let statusCode = response.response?.statusCode else { return }
        print(statusCode)
        switch statusCode {
        case 200:
          break
        default:
          fatalError()
        }
      })
      .disposed(by: disposeBag)
  }
}
