import Moya
import RxMoya
import RxSwift
import RxCocoa

final class ConfirmNicknameViewModel: ViewModel {
  struct Input {
    // Interaction
    let textFieldDidChange = PublishSubject<String>()
    let confirmButtonDidTap = PublishSubject<String>()
  }
  
  struct Output {
    // UI
    let currentLength = PublishSubject<Int>()
    let indicatorState = PublishSubject<Bool>()
    
    // Presentation
    let pushToCompleteSignUpVC = PublishSubject<Void>()
  }
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  init() {
    bind()
  }
  
  func bind() {
    
    // 텍스트 변화 감지 -> 현재 텍스트 길이 계산
    input.textFieldDidChange
      .map { $0.count }
      .bind(to: output.currentLength)
      .disposed(by: disposeBag)
    
    // 가입완료 버튼 클릭 -> 회원가입API 요청
    input.confirmButtonDidTap
      .map { [weak self] in
        self?.output.indicatorState.onNext(true)
        let email = Logger.instance.email!
        let password = Logger.instance.password!
        return (email, password, $0)
      }
      .flatMap { APIService.memberProvider.rx.request(.register(id: $0.0, pw: $0.1, nickname: $0.2)) }
      .filterSuccessfulStatusCodes()
      .subscribe(onNext: { [weak self] _ in
        self?.output.indicatorState.onNext(false)
        self?.output.pushToCompleteSignUpVC.onNext(Void())
      })
      .disposed(by: disposeBag)
  }
}
