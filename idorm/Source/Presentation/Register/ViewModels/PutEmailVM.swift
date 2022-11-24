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
    
    switch vcType {
    case .signUp:
      // 인증번호 받기 -> 회원가입 인증 API호출
      input.confirmButtonDidTap
        .map { [weak self] in self?.currentEmail.value ?? "" }
        .do(onNext: { [weak self] _ in self?.output.isLoading.onNext(true) })
        .flatMap { APIService.emailProvider.rx.request(.emailAuthentication(email: $0)) }
        .do(onNext: { [weak self] _ in self?.output.isLoading.onNext(false) })
        .subscribe(onNext: { [weak self] response in
          switch response.statusCode {
          case 200:
            self?.output.presentAuthVC.onNext(Void())
          case 400:
            self?.output.presentPopupVC.onNext("이메일을 입력해주세요.")
          case 401:
            self?.output.presentPopupVC.onNext("올바른 이메일 형식이 아닙니다.")
          case 409:
            self?.output.presentPopupVC.onNext("이미 가입된 이메일입니다.")
          default:
            self?.output.presentPopupVC.onNext("이메일을 다시 한번 확인해주세요.")
          }
        })
        .disposed(by: disposeBag)
      
    case .findPW, .updatePW:
      // 인증번호 받기 -> 비밀번호 인증 API호출
      input.confirmButtonDidTap
        .map { [weak self] in self?.currentEmail.value ?? "" }
        .do(onNext: { [weak self] _ in self?.output.isLoading.onNext(true) })
        .flatMap { APIService.emailProvider.rx.request(.pwAuthentication(email: $0)) }
        .do(onNext: { [weak self] _ in self?.output.isLoading.onNext(false) })
        .subscribe(onNext: { [weak self] response in
          switch response.statusCode {
          case 200:
            self?.output.presentAuthVC.onNext(Void())
          case 400:
            self?.output.presentPopupVC.onNext("이메일을 입력해주세요.")
          case 401:
            self?.output.presentPopupVC.onNext("올바른 이메일 형식이 아닙니다.")
          case 409:
            self?.output.presentPopupVC.onNext("이미 가입된 이메일입니다.")
          default:
            self?.output.presentPopupVC.onNext("이메일을 다시 한번 확인해주세요.")
          }
        })
        .disposed(by: disposeBag)
    }
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
