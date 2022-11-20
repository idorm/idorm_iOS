import Foundation

import RxSwift
import RxCocoa

final class AuthNumberViewModel: ViewModel {
  struct Input {
    // Interaction
    let authButtonDidTap = PublishSubject<Void>()
    let confirmButtonDidTap = PublishSubject<String>()
  }
  
  struct Output {
    // Presentation
    let dismissVC = PublishSubject<Void>()
    let showPopupVC = PublishSubject<String>()
    
    // UI
    let indicatorState = PublishSubject<Bool>()
    let resetTimer = PublishSubject<Void>()
    let isEnableAuthButton = PublishSubject<Bool>()
  }
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  init() {
    bind()
  }
  
  func bind() {
    
    // 인증번호 재 요청 버튼 클릭 -> 인증번호 API 요청
    input.authButtonDidTap
      .subscribe(onNext: { [weak self] in
        self?.output.indicatorState.onNext(true)
        self?.requestAuthenticationAPI()
      })
      .disposed(by: disposeBag)
    
    // 완료 버튼 클릭 -> 이메일 검증API 요청
    input.confirmButtonDidTap
      .bind(onNext: { [weak self] in
        self?.output.indicatorState.onNext(true)
        self?.requestVerificationAPI($0)
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - Network

extension AuthNumberViewModel {
  
  func requestVerificationAPI(_ code: String) {
    let logger = Logger.instance
    let emailProvider = APIService.emailProvider
    guard let email = logger.email else {
      fatalError("Email was not saved!")
    }
    switch logger.authenticationType {
    case .signUp:
      emailProvider.rx.request(.emailVerification(email: email, code: code))
        .asObservable()
        .subscribe(onNext: { [weak self] response in
          switch response.statusCode {
          case 200:
            self?.output.dismissVC.onNext(Void())
          case 400:
            self?.output.showPopupVC.onNext("잘못된 인증번호입니다.")
          case 401:
            self?.output.showPopupVC.onNext("등록되지 않은 이메일입니다.")
          default:
            self?.output.showPopupVC.onNext("인증번호를 다시 한번 확인해주세요.")
          }
          self?.output.indicatorState.onNext(false)
        })
        .disposed(by: disposeBag)
    case .password:
      emailProvider.rx.request(.pwVerification(email: email, code: code))
        .asObservable()
        .subscribe(onNext: { [weak self] response in
          switch response.statusCode {
          case 200:
            self?.output.dismissVC.onNext(Void())
          case 400:
            self?.output.showPopupVC.onNext("잘못된 인증번호입니다.")
          case 401:
            self?.output.showPopupVC.onNext("등록되지 않은 이메일입니다.")
          default:
            self?.output.showPopupVC.onNext("인증번호를 다시 한번 확인해주세요.")
          }
          self?.output.indicatorState.onNext(false)
        })
        .disposed(by: disposeBag)
    }
  }
  
  func requestAuthenticationAPI() {
    let logger = Logger.instance
    let mailProvider = APIService.emailProvider
    guard let email = logger.email else {
      fatalError("Email was not saved!")
    }
    switch logger.authenticationType {
    case .password:
      mailProvider.rx.request(.pwAuthentication(email: email))
        .asObservable()
        .subscribe(onNext: { [weak self] response in
          if response.statusCode == 200 {
            self?.output.showPopupVC.onNext("인증번호가 재전송 되었습니다.")
            self?.output.isEnableAuthButton.onNext(false)
            self?.output.resetTimer.onNext(Void())
          } else {
            fatalError("email is missing")
          }
          self?.output.indicatorState.onNext(false)
        })
        .disposed(by: disposeBag)
    case .signUp:
      mailProvider.rx.request(.emailAuthentication(email: email))
        .asObservable()
        .subscribe(onNext: { [weak self] response in
          if response.statusCode == 200 {
            self?.output.showPopupVC.onNext("인증번호가 재전송 되었습니다.")
            self?.output.isEnableAuthButton.onNext(false)
            self?.output.resetTimer.onNext(Void())
          } else {
            fatalError("email is missing")
          }
          self?.output.indicatorState.onNext(false)
        })
        .disposed(by: disposeBag)
    }
  }
}
