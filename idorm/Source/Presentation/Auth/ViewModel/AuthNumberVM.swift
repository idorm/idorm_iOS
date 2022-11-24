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
    
    switch authenticationType {
    case .signUp:
      // 인증번호 재 요청 버튼 클릭 -> 회원가입 인증번호 API 요청
      input.authOnemoreButtonDidTap
        .do(onNext: { [weak self] in self?.output.isLoading.onNext(true) })
        .flatMap { APIService.emailProvider.rx.request(.emailAuthentication(email: email)) }
        .do(onNext: { [weak self] _ in self?.output.isLoading.onNext(false) })
        .subscribe(onNext: { [weak self] response in
          switch response.statusCode {
          case 200:
            self?.output.presentPopupVC.onNext("인증번호가 재전송 되었습니다.")
            self?.output.isEnableAuthButton.onNext(false)
            self?.output.resetTimer.onNext(Void())
          default:
            fatalError("email is missing")
          }
        })
        .disposed(by: disposeBag)
      
      // 완료 버튼 클릭 -> 회원가입 이메일 검증API 요청
      input.confirmButtonDidTap
        .map { [weak self] in (email, self?.currentCode.value ?? "") }
        .do(onNext: { [weak self] _ in self?.output.isLoading.onNext(true) })
        .flatMap { APIService.emailProvider.rx.request(.emailVerification(email: $0.0, code: $0.1)) }
        .do(onNext: { [weak self] _ in self?.output.isLoading.onNext(false) })
        .subscribe(onNext: { [weak self] response in
          switch response.statusCode {
          case 200:
            self?.output.dismissVC.onNext(Void())
          case 400:
            self?.output.presentPopupVC.onNext("잘못된 인증번호입니다.")
          default:
            self?.output.presentPopupVC.onNext("인증번호를 다시 한번 확인해주세요.")
          }
        })
        .disposed(by: disposeBag)
      
    case .password:
      // 인증번호 재 요청 버튼 클릭 -> 비밀번호 인증번호 API 요청
      input.authOnemoreButtonDidTap
        .filter { authenticationType == .password }
        .do(onNext: { [weak self] in self?.output.isLoading.onNext(true) })
        .flatMap { APIService.emailProvider.rx.request(.pwAuthentication(email: email)) }
        .do(onNext: { [weak self] _ in self?.output.isLoading.onNext(false) })
        .subscribe(onNext: { [weak self] response in
          switch response.statusCode {
          case 200:
            self?.output.presentPopupVC.onNext("인증번호가 재전송 되었습니다.")
            self?.output.isEnableAuthButton.onNext(false)
            self?.output.resetTimer.onNext(Void())
          default:
            fatalError("email is missing")
          }
        })
        .disposed(by: disposeBag)
      
      // 완료 버튼 클릭 -> 비밀번호 이메일 검증API 요청
      input.confirmButtonDidTap
        .map { [weak self] in (email, self?.currentCode.value ?? "") }
        .do(onNext: { [weak self] _ in self?.output.isLoading.onNext(true) })
        .flatMap { APIService.emailProvider.rx.request(.pwVerification(email: $0.0, code: $0.1)) }
        .do(onNext: { [weak self] _ in self?.output.isLoading.onNext(false) })
        .subscribe(onNext: { [weak self] response in
          switch response.statusCode {
          case 200:
            self?.output.dismissVC.onNext(Void())
          case 400:
            self?.output.presentPopupVC.onNext("잘못된 인증번호입니다.")
          default:
            self?.output.presentPopupVC.onNext("인증번호를 다시 한번 확인해주세요.")
          }
        })
        .disposed(by: disposeBag)
    }
  }
  
  private func mutate() {
    
    input.textFieldDidChange
      .bind(to: currentCode)
      .disposed(by: disposeBag)
  }
}
