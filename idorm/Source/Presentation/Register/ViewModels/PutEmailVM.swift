import RxSwift
import RxCocoa

final class PutEmailViewModel: ViewModel {
  struct Input {
    // Interaction
    let confirmButtonTapped = PublishSubject<String>()
    
    // LifeCycle
    let viewDidLoad = PublishSubject<RegisterVCTypes.PutEmailVCType>()
  }
  
  struct Output {
    // Presentation
    let showAuthVC = PublishSubject<Void>()
    let showErrorPopupVC = PublishSubject<String>()
    
    // UI
    let animationState = PublishSubject<Bool>()
  }
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  init() {
    bind()
  }
  
  func bind() {
    
    // 완료 버튼 클릭 -> API 호출
    input.confirmButtonTapped
      .subscribe(onNext: { [weak self] in
        self?.output.animationState.onNext(true)
        self?.requestAuthenticationAPI($0)
      })
      .disposed(by: disposeBag)
    
    // 화면 최초 접속 -> Logger의 AuthenticationType 저장
    input.viewDidLoad
      .subscribe(onNext: {
        switch $0 {
        case .signUp:
          Logger.instance.authenticationType = .signUp
        case .findPW, .updatePW:
          Logger.instance.authenticationType = .password
        }
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - Network

extension PutEmailViewModel {
  
  func requestAuthenticationAPI(_ email: String) {
    Logger.instance.email = email
    let provider = APIService.emailProvider
    switch Logger.instance.authenticationType {
    case .signUp:
      provider.rx.request(.emailAuthentication(email: email))
        .asObservable()
        .subscribe(onNext: { [weak self] response in
          switch response.statusCode {
          case 200:
            self?.output.showAuthVC.onNext(Void())
          case 400:
            self?.output.showErrorPopupVC.onNext("이메일을 입력해주세요.")
          case 401:
            self?.output.showErrorPopupVC.onNext("올바른 이메일 형식이 아닙니다.")
          case 409:
            self?.output.showErrorPopupVC.onNext("이미 가입된 이메일입니다.")
          default:
            self?.output.showErrorPopupVC.onNext("이메일을 다시 한번 확인해주세요.")
          }
          self?.output.animationState.onNext(false)
        })
        .disposed(by: disposeBag)
    case .password:
      provider.rx.request(.pwAuthentication(email: email))
        .asObservable()
        .subscribe(onNext: { [weak self] response in
          switch response.statusCode {
          case 200:
            self?.output.showAuthVC.onNext(Void())
          case 401:
            self?.output.showErrorPopupVC.onNext("이메일을 찾을 수 없습니다.")
          case 409:
            self?.output.showErrorPopupVC.onNext("가입되지 않은 이메일입니다.")
          default:
            self?.output.showErrorPopupVC.onNext("이메일을 다시 한번 확인해주세요.")
          }
          self?.output.animationState.onNext(false)
        })
        .disposed(by: disposeBag)
    }
  }
}
