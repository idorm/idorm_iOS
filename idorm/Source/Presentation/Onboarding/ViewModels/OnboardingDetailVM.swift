import Foundation

import RxSwift
import RxCocoa

final class OnboardingDetailViewModel: ViewModel {
  
  struct Input {
    let leftButtonDidTap = PublishSubject<Void>()
    let rightButtonDidTap = PublishSubject<MatchingModel.Member>()
  }
  
  struct Output {
    let popVC = PublishSubject<Void>()
    let presentPopupVC = PublishSubject<String>()
    let presentMainVC = PublishSubject<Void>()
    let pushToOnboardingVC = PublishSubject<Void>()
    let isLoading = PublishSubject<Bool>()
  }
  
  // MARK: - Properties
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  // MARK: - Bind
  
  init(_ vcType: OnboardingVCTypes.OnboardingDetailVCType) {
    
    switch vcType {
    case .initilize:
      
      // 뒤로가기 -> 이전 화면 돌아가기
      input.leftButtonDidTap
        .bind(to: output.popVC)
        .disposed(by: disposeBag)
      
      // 완료 버튼 이벤트 -> 온보딩 최초 저장API 호출
      input.rightButtonDidTap
        .map { ModelTransformer.instance.toOnboardingRequestModel(from: $0) }
        .withUnretained(self)
        .do(onNext: { owner, _ in owner.output.isLoading.onNext(true) })
        .flatMap { APIService.onboardingProvider.rx.request(.save($0.1)) }
        .map(OnboardingModel.LookupOnboardingResponseModel.self)
        .withUnretained(self)
        .subscribe(onNext: { owner, response in
          MemberInfoStorage.instance.myOnboarding.accept(response.data)
          owner.output.presentMainVC.onNext(Void())
          owner.output.isLoading.onNext(false)
        })
        .disposed(by: disposeBag)
      
    case .update:
      
      // 정보 수정 버튼 클릭 -> 온보딩 페이지 이동
      input.leftButtonDidTap
        .bind(to: output.pushToOnboardingVC)
        .disposed(by: disposeBag)

      // 완료 버튼 이벤트 -> 뒤로가기
      input.rightButtonDidTap
        .map { _ in Void() }
        .bind(to: output.popVC)
        .disposed(by: disposeBag)
    }
  }
}
