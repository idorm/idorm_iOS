import RxSwift
import RxCocoa

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
  private let vcType: RegisterVCTypes.PutEmailVCType
  
  let currentEmail = BehaviorRelay<String>(value: "")
  
  init(_ vcType: RegisterVCTypes.PutEmailVCType) {
    self.vcType = vcType
    mutate()
    
    // 확인 버튼 -> API 요청
    input.confirmButtonDidTap
      .withUnretained(self)
      .map { ($0.0, $0.0.currentEmail.value) }
      .subscribe { $0.0.requestAuthenticationMail($0.1) }
      .disposed(by: disposeBag)
  }

  private func mutate() {
    
    // 텍스트 필드 변경 -> 프로퍼티로 저장
    input.textFieldDidChange
      .bind(to: currentEmail)
      .disposed(by: disposeBag)
    
    // 현재 작성된 이메일 -> Logger에 저장
    currentEmail
      .bind(to: Logger.instance.currentEmail)
      .disposed(by: disposeBag)
    
    // 최초 접속 시 Logger에 인증 방식 저장
    switch vcType {
    case .signUp:
      Observable.empty()
        .map { AuthenticationType.signUp }
        .bind(to: Logger.instance.authenticationType)
        .disposed(by: disposeBag)
      
    case .findPW, .updatePW:
      Observable.empty()
        .map { AuthenticationType.password }
        .bind(to: Logger.instance.authenticationType)
        .disposed(by: disposeBag)
    }
  }
}

// MARK: - Network

extension PutEmailViewModel {
  func requestAuthenticationMail(_ email: String) {
    output.isLoading.onNext(true)
    
    switch vcType {
    case .signUp:
      APIService.emailProvider.rx.request(.emailAuthentication(email: email))
        .asObservable()
        .materialize()
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
      APIService.emailProvider.rx.request(.pwAuthentication(email: email))
        .asObservable()
        .materialize()
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
