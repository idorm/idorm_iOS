import RxSwift
import RxCocoa

final class PutEmailViewModel: ViewModel {
  struct Input {
    // Interaction
    let emailText = BehaviorRelay<String>(value: "")
    let confirmButtonTapped = PublishSubject<Void>()
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
  
  var email: String { return input.emailText.value }
  
  init() {
    bind()
  }
  
  func bind() {
    
    // 완료 버튼 클릭 -> 오류 및 이동
    input.confirmButtonTapped
      .bind(onNext: { [unowned self] in
        Logger.instance.email = self.email
        
        switch Logger.instance.authenticationType {
        case .password:
          self.passwordEmailAPI()
        case .signUp:
          self.registerEmailAPI()
        }
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - Network

extension PutEmailViewModel {
  
  // 비밀번호 변경 인증 메일 요청 API
  func passwordEmailAPI() {
    output.animationState.onNext(true)
    EmailService.passwordEmailAPI(email: self.email)
      .subscribe(onNext: { [weak self] response in
        guard let statusCode = response.response?.statusCode else { return }
        switch statusCode {
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
  
  // 회원가입 인증 메일 요청 API
  func registerEmailAPI() {
    EmailService.registerEmailAPI(email: self.email)
      .subscribe(onNext: { [weak self] response in
        guard let statusCode = response.response?.statusCode else { return }
        switch statusCode {
        case 200:
          self?.output.showAuthVC.onNext(Void())
        case 400:
          self?.output.showErrorPopupVC.onNext("이메일을 입력해 주세요.")
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
  }
}
