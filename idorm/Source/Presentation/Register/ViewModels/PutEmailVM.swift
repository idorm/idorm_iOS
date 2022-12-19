import RxSwift
import RxCocoa
import RxMoya

final class PutEmailViewModel: ViewModel {
  struct Input {
    let confirmButtonDidTap = PublishSubject<Void>()
    let textFieldDidChange = PublishSubject<String>()
  }
  
  struct Output {
    let presentAuthVC = PublishSubject<Void>()
    let presentPopupVC = PublishSubject<String>()
    let isLoading = PublishSubject<Bool>()
  }
  
  // MARK: - Properties
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  let currentEmail = BehaviorRelay<String>(value: "")
  
  let requestAuthenticationMail = PublishSubject<String>()
  
  // MARK: - Bind
  
  init(_ vcType: RegisterVCTypes.PutEmailVCType) {
    
    // 확인 버튼 -> API 요청
    input.confirmButtonDidTap
      .withUnretained(self)
      .map { ($0.0, $0.0.currentEmail.value) }
      .subscribe { $0.requestAuthenticationMail.onNext($1) }
      .disposed(by: disposeBag)
    
    // 텍스트 필드 변경 -> 프로퍼티로 저장
    input.textFieldDidChange
      .bind(to: currentEmail)
      .disposed(by: disposeBag)
    
    // 현재 작성된 이메일 -> Logger에 저장
    currentEmail
      .bind { Logger.shared.saveEmail($0) }
      .disposed(by: disposeBag)
    
    // 최초 접속 시 Logger에 인증 방식 저장
    switch vcType {
    case .signUp:
      Observable.empty()
        .map { AuthenticationType.signUp }
        .bind { Logger.shared.saveAuthenticationType($0) }
        .disposed(by: disposeBag)
      
      // 메일 인증 요청 API
      requestAuthenticationMail
        .withUnretained(self)
        .do { $0.0.output.isLoading.onNext(true) }
        .flatMap {
          APIService.emailProvider.rx.request(.emailAuthentication(email: $1))
            .asObservable()
            .materialize()
        }
        .withUnretained(self)
        .subscribe { owner, event in
          owner.output.isLoading.onNext(false)
          switch event {
          case .next(let response):
            if response.statusCode == 200 {
              owner.output.presentAuthVC.onNext(Void())
            } else {
              let error = APIService.decode(ErrorResponseModel.self, data: response.data)
              owner.output.presentPopupVC.onNext(error.message)
            }
          case .error:
            owner.output.presentPopupVC.onNext("네트워크를 확인해주세요.")
          default: break
          }
        }
        .disposed(by: disposeBag)
      
    case .findPW, .updatePW:
      Observable.empty()
        .map { AuthenticationType.password }
        .bind { Logger.shared.saveAuthenticationType($0) }
        .disposed(by: disposeBag)
      
      // 메일 인증 요청 API
      requestAuthenticationMail
        .withUnretained(self)
        .do { $0.0.output.isLoading.onNext(true) }
        .flatMap {
          APIService.emailProvider.rx.request(.pwAuthentication(email: $1))
            .asObservable()
            .materialize()
        }
        .withUnretained(self)
        .subscribe { owner, event in
          owner.output.isLoading.onNext(false)
          switch event {
          case .next(let response):
            if response.statusCode == 200 {
              owner.output.presentAuthVC.onNext(Void())
            } else {
              let error = APIService.decode(ErrorResponseModel.self, data: response.data)
              owner.output.presentPopupVC.onNext(error.message)
            }
          case .error:
            owner.output.presentPopupVC.onNext("네트워크를 확인해주세요.")
          default: break
          }
        }
        .disposed(by: disposeBag)
    }
  }
}
