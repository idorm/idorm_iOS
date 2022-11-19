import Foundation

import RxSwift
import RxCocoa

final class OnboardingDetailViewModel: ViewModel {
  
  struct Input {
    // Interaction
    let backButtonDidTap = PublishSubject<Void>()
    let correctionButtonDidTap = PublishSubject<Void>()
    let confirmButtonDidTap = PublishSubject<MatchingModel.Member>()
  }
  
  struct Output {
    // Presentation
    let popVC = PublishSubject<Void>()
    let showPopupVC = PublishSubject<String>()
    let showTabBarVC = PublishSubject<Void>()
    let showOnboardingVC = PublishSubject<Void>()
    
    // UI
    let indicatorState = PublishSubject<Bool>()
  }
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  private let vcType: OnboardingVCTypes.OnboardingDetailVCType
  
  init(_ vcType: OnboardingVCTypes.OnboardingDetailVCType) {
    self.vcType = vcType
    bind()
  }
  
  // MARK: - Bind
  
  func bind() {
    
    // 뒤로가기 -> 이전 화면 돌아가기
    input.backButtonDidTap
      .bind(to: output.popVC)
      .disposed(by: disposeBag)
    
    // 정보 수정 버튼 클릭 -> 온보딩 페이지 이동
    input.correctionButtonDidTap
      .bind(to: output.showOnboardingVC)
      .disposed(by: disposeBag)
    
    switch vcType {
    case .initilize:
      // 완료 버튼 이벤트 -> 온보딩 최초 저장API 호출
      input.confirmButtonDidTap
        .do(onNext: { [weak self] _ in
          self?.output.indicatorState.onNext(true)
        })
        .map { ModelTransformer.instance.toOnboardingRequestModel(from: $0) }
        .flatMap {
          return APIService.onboardingProvider.rx.request(.save($0))
        }
        .map(OnboardingModel.LookupOnboardingResponseModel.self)
        .subscribe(onNext: { [weak self] response in
          self?.output.indicatorState.onNext(false)
          MemberInfoStorage.instance.myOnboarding.accept(response.data)
          self?.output.showTabBarVC.onNext(Void())
        })
        .disposed(by: disposeBag)
      
    case .update:
      // 완료 버튼 이벤트 -> 뒤로가기
      input.confirmButtonDidTap
        .map { _ in Void() }
        .bind(to: output.popVC)
        .disposed(by: disposeBag)
    }
  }
}
