import Foundation

import RxSwift
import RxCocoa

final class AuthNumberViewModel: ViewModel {
  struct Input {
    let authOnemoreButtonDidTap = PublishSubject<Void>()
    let confirmButtonDidTap = PublishSubject<Void>()
    let textFieldDidChange = PublishSubject<String>()
  }
  
  struct Output {
    let dismissVC = PublishSubject<Void>()
    let presentPopupVC = PublishSubject<String>()
    let isLoading = PublishSubject<Bool>()
    let resetTimer = PublishSubject<Void>()
    let isEnableAuthButton = PublishSubject<Bool>()
  }
  
  // MARK: - Properties
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  let currentCode = BehaviorRelay<String>(value: "")
  
  // MARK: - Bind
  
  init() {
    mutate()
    let authenticationType = Logger.instance.authenticationType.value
    let email = Logger.instance.currentEmail.value
    
    // 완료 버튼 클릭 -> 이메일 검증 API 요청
    input.confirmButtonDidTap
      .withUnretained(self)
      .map { ($0.0, $0.0.currentCode.value) }
      .subscribe { $0.0.requestVerificationMail($0.1) }
      .disposed(by: disposeBag)
    
    // 인증번호 재요청 버튼 클릭 -> 인증메일 발송 API 요청
    input.authOnemoreButtonDidTap
      .withUnretained(self)
      .subscribe { $0.0.requestAuthenticationMail() }
      .disposed(by: disposeBag)
  }
  
  private func mutate() {
    
    input.textFieldDidChange
      .bind(to: currentCode)
      .disposed(by: disposeBag)
  }
}

// MARK: - Network

extension AuthNumberViewModel {
  private func requestVerificationMail(_ code: String) {
    let email = Logger.instance.currentEmail.value
    let authType = Logger.instance.authenticationType.value
    
    output.isLoading.onNext(true)
    
    switch authType {
      
    case .signUp:
      APIService.emailProvider.rx.request(.emailVerification(email: email, code: code))
        .asObservable()
        .materialize()
        .withUnretained(self)
        .subscribe { owner, event in
          owner.output.isLoading.onNext(false)
          switch event {
          case .next(let response):
            if response.statusCode == 200 {
              owner.output.dismissVC.onNext(Void())
            } else {
              let error = APIService.decode(ErrorResponseModel.self, data: response.data)
              owner.output.presentPopupVC.onNext(error.message)
            }
          case .error:
            owner.output.presentPopupVC.onNext("네트워크를 다시 확인해주세요.")
          case .completed:
            break
          }
        }
        .disposed(by: disposeBag)
      
    case .password:
      APIService.emailProvider.rx.request(.pwVerification(email: email, code: code))
        .asObservable()
        .materialize()
        .withUnretained(self)
        .subscribe { owner, event in
          owner.output.isLoading.onNext(false)
          switch event {
          case .next(let response):
            if response.statusCode == 200 {
              owner.output.dismissVC.onNext(Void())
            } else {
              let error = APIService.decode(ErrorResponseModel.self, data: response.data)
              owner.output.presentPopupVC.onNext(error.message)
            }
          case .error:
            owner.output.presentPopupVC.onNext("네트워크를 다시 확인해주세요.")
          case .completed:
            break
          }
        }
        .disposed(by: disposeBag)
    }
  }
  
  private func requestAuthenticationMail() {
    let email = Logger.instance.currentEmail.value
    let authType = Logger.instance.authenticationType.value
    
    output.isLoading.onNext(true)
    
    switch authType {
      
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
              owner.output.presentPopupVC.onNext("이메일이 재전송 되었습니다.")
              owner.output.isEnableAuthButton.onNext(false)
              owner.output.resetTimer.onNext(Void())
            } else {
              let error = APIService.decode(ErrorResponseModel.self, data: response.data)
              owner.output.presentPopupVC.onNext(error.message)
            }
          case .error:
            owner.output.presentPopupVC.onNext("네트워크를 다시 확인해주세요.")
          case .completed:
            break
          }
        }
        .disposed(by: disposeBag)
      
    case .password:
      APIService.emailProvider.rx.request(.pwAuthentication(email: email))
        .asObservable()
        .materialize()
        .withUnretained(self)
        .subscribe { owner, event in
          owner.output.isLoading.onNext(false)
          switch event {
          case .next(let response):
            if response.statusCode == 200 {
              owner.output.presentPopupVC.onNext("이메일이 재전송 되었습니다.")
              owner.output.isEnableAuthButton.onNext(false)
              owner.output.resetTimer.onNext(Void())
            } else {
              let error = APIService.decode(ErrorResponseModel.self, data: response.data)
              owner.output.presentPopupVC.onNext(error.message)
            }
          case .error:
            owner.output.presentPopupVC.onNext("네트워크를 다시 확인해주세요.")
          case .completed:
            break
          }
        }
        .disposed(by: disposeBag)
    }
  }
}
