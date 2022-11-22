import RxSwift
import RxCocoa
import RxMoya

final class WithdrawalViewModel: ViewModel {
  
  // MARK: -  Properties
  
  struct Input {
    // Interaction
    let skipButtonDidTap = PublishSubject<Void>()
    let withdrawalButtonDidTap = PublishSubject<Void>()
  }
  
  struct Output {
    // Presentation
    let popVC = PublishSubject<Void>()
    let presentLoginVC = PublishSubject<Void>()
  }
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  // MARK: -  Bind
  
  init() {
    
    // 다시 생각해볼게요 버튼 클릭 -> POPVC
    input.skipButtonDidTap
      .bind(to: output.popVC)
      .disposed(by: disposeBag)
    
    // 탈퇴 버튼 클릭 -> 로그인 VC로 이동
    input.withdrawalButtonDidTap
      .debug()
      .flatMap { APIService.memberProvider.rx.request(.withdrawal) }
      .filterSuccessfulStatusCodes()
      .map { _ in Void() }
      .bind(to: output.presentLoginVC)
      .disposed(by: disposeBag)
  }
}
