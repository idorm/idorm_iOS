import Foundation

import RxSwift
import RxCocoa

final class AuthNumberViewModel: ViewModel {
  struct Input {
    let requestAgainButtonTapped = PublishSubject<Void>()
    let confirmButtonTapped = PublishSubject<Void>()
    let viewWillAppear = PublishSubject<Void>()
    let codeString = BehaviorRelay<String>(value: "")
  }
  
  struct Output {
    let resetTimer = PublishSubject<Void>()
    let dismissVC = PublishSubject<Void>()
    let showPopupVC = PublishSubject<String>()
    
    let startAnimation = PublishSubject<Void>()
    let stopAnimation = PublishSubject<Void>()
  }
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  init() {
    bind()
  }
  
  func bind() {
    
    // 인증번호 재 요청 버튼 클릭 -> 인증번호 API 요청
    input.requestAgainButtonTapped
      .subscribe(onNext: { [weak self] in
        switch Logger.instance.authenticationType {
        case .signUp:
          self?.registerEmailAPI()
        case .password:
          self?.passwordEmailAPI()
        }
      })
      .disposed(by: disposeBag)
    
    // 버튼 클릭 -> 애니메이션 효과
    Observable.merge(
      input.requestAgainButtonTapped,
      input.confirmButtonTapped
    )
    .bind(to: output.startAnimation)
    .disposed(by: disposeBag)
    
    // 완료 버튼 클릭 -> 이메일 검증API 요청
    input.confirmButtonTapped
      .bind(onNext: { [weak self] in
        self?.verifyCodeAPI()
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - Network

extension AuthNumberViewModel {
  func passwordEmailAPI() {
    guard let email = Logger.instance.email else { return }
    EmailService.passwordEmailAPI(email: email)
      .subscribe(onNext: { [weak self] response in
        self?.output.stopAnimation.onNext(Void())
        guard let statusCode = response.response?.statusCode else { return }
        switch statusCode {
        case 200:
          self?.output.resetTimer.onNext(Void())
        case 401:
          self?.output.showPopupVC.onNext("이메일을 찾을 수 없습니다.")
        case 409:
          self?.output.showPopupVC.onNext("가입되지 않은 이메일입니다.")
        default:
          self?.output.showPopupVC.onNext("이메일을 다시 한번 확인해주세요.")
        }
      })
      .disposed(by: disposeBag)
  }
  
  func registerEmailAPI() {
    guard let email = Logger.instance.email else { return }
    EmailService.registerEmailAPI(email: email)
      .subscribe(onNext: { [weak self] response in
        self?.output.stopAnimation.onNext(Void())
        guard let statusCode = response.response?.statusCode else { return }
        switch statusCode {
        case 200:
          self?.output.resetTimer.onNext(Void())
        case 400:
          self?.output.showPopupVC.onNext("이메일을 입력해 주세요.")
        case 401:
          self?.output.showPopupVC.onNext("올바른 이메일 형식이 아닙니다.")
        case 409:
          self?.output.showPopupVC.onNext("이미 가입된 이메일입니다.")
        default:
          self?.output.showPopupVC.onNext("이메일을 다시 한번 확인해주세요.")
        }
      })
      .disposed(by: disposeBag)
  }
  
  func verifyCodeAPI() {
    guard let email = Logger.instance.email else { return }
    let code = input.codeString.value
    
    EmailService.verifyCodeAPI(email: email, code: code, type: Logger.instance.authenticationType)
      .subscribe(onNext: { [weak self] response in
        self?.output.stopAnimation.onNext(Void())
        guard let statusCode = response.response?.statusCode else { return }
        switch statusCode {
        case 200:
          self?.output.dismissVC.onNext(Void())
        case 400:
          self?.output.showPopupVC.onNext("잘못된 인증번호입니다.")
        case 401:
          self?.output.showPopupVC.onNext("등록되지 않은 이메일입니다.")
        default:
          self?.output.showPopupVC.onNext("인증번호를 다시 한번 확인해주세요.")
        }
      })
      .disposed(by: disposeBag)
  }
}
