import Foundation

import RxSwift
import RxCocoa

final class ConfirmPasswordViewModel: ViewModel {
  struct Input {
    // Interaction
    let confirmButtonTapped = PublishSubject<Void>()
    let passwordText = BehaviorRelay<String>(value: "")
    let passwordText_2 = BehaviorRelay<String>(value: "")
    let passwordTextFieldDidEnd = PublishSubject<Void>()
    let passwordTextFieldDidEnd_2 = PublishSubject<Void>()
    let passwordTextFieldDidBegin = PublishSubject<Void>()
    let passwordTextFieldDidBegin_2 = PublishSubject<Void>()
  }
  
  struct Output {
    // UI
    let countState = BehaviorRelay<Bool>(value: false)
    let combineState = BehaviorRelay<Bool>(value: false)
    let didBeginState = PublishSubject<Void>()
    let didBeginState_2 = PublishSubject<Void>()
    let didEndState = PublishSubject<Void>()
    let didEndState_2 = PublishSubject<Void>()
    
    // Presentation
    let showErrorPopupVC = PublishSubject<String>()
    let showCompleteVC = PublishSubject<Void>()
    let showLoginVC = PublishSubject<Void>()
  }
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  var passwordText: String { return input.passwordText.value }
  var passwordText2: String { return input.passwordText_2.value }
  
  init() {
    bind()
  }
  
  func bind() {
    input.passwordText
      .bind(onNext: { [weak self] password in
        if password.count >= 8 {
          self?.output.countState.accept(true)
        } else {
          self?.output.countState.accept(false)
        }
      })
      .disposed(by: disposeBag)
    
    input.passwordText
      .bind(onNext: { [weak self] password in
        guard let self = self else { return }
        if self.isValidPassword(pwd: password) {
          self.output.combineState.accept(true)
        } else {
          self.output.combineState.accept(false)
        }
      })
      .disposed(by: disposeBag)
    
    input.passwordTextFieldDidBegin
      .bind(to: output.didBeginState)
      .disposed(by: disposeBag)
    
    input.passwordTextFieldDidEnd
      .bind(to: output.didEndState)
      .disposed(by: disposeBag)
    
    input.passwordTextFieldDidBegin_2
      .bind(to: output.didBeginState_2)
      .disposed(by: disposeBag)
    
    input.passwordTextFieldDidEnd_2
      .bind(to: output.didEndState_2)
      .disposed(by: disposeBag)
    
    input.confirmButtonTapped
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        if self.isValidPasswordFinal(pwd: self.passwordText),
           self.isValidPasswordFinal(pwd: self.passwordText2),
           self.passwordText == self.passwordText2 {
          
          if RegisterInfomation.shared.registerType == .signUp {
            self.registerAPI()
          } else {
            // TODO: [] 멤버 비밀번호 바꾸기 API 삽입
            self.changePasswordAPI()
          }
        } else {
          self.output.showErrorPopupVC.onNext("조건을 다시 확인해 주세요.")
        }
      })
      .disposed(by: disposeBag)
  }
  
  func registerAPI() {
    guard let email = RegisterInfomation.shared.email else { return }
    
    MemberService.registerAPI(email: email, password: passwordText)
      .subscribe(onNext: { [weak self] response in
        guard let statusCode = response.response?.statusCode else { return }
        switch statusCode {
        case 200:
          RegisterInfomation.shared.password = self?.passwordText
          self?.output.showCompleteVC.onNext(Void())
        default:
          self?.output.showErrorPopupVC.onNext("등록되지 않은 이메일입니다.")
        }
      })
      .disposed(by: disposeBag)
  }
  
  func changePasswordAPI() {
    guard let email = RegisterInfomation.shared.email else { return }
    
    MemberService.changePasswordAPI(email: email, password: passwordText)
      .subscribe(onNext: { [weak self] response in
        guard let statusCode = response.response?.statusCode else { return }
        switch statusCode {
        case 200:
          self?.output.showErrorPopupVC.onNext("비밀번호가 변경 되었습니다.")
          self?.output.showLoginVC.onNext(Void())
        case 400:
          self?.output.showErrorPopupVC.onNext("입력은 필수입니다.")
        case 401:
          self?.output.showErrorPopupVC.onNext("등록되지 않은 이메일입니다.")
        case 404:
          self?.output.showErrorPopupVC.onNext("비밀번호를 변경할 멤버를 찾을 수 없습니다.")
        case 500:
          self?.output.showErrorPopupVC.onNext("Member 비밀번호 변경 중 서버 에러 발생")
        default:
          fatalError()
        }
      })
      .disposed(by: disposeBag)
  }
  
  func isValidPasswordFinal(pwd: String) -> Bool {
    let passwordRegEx = "^(?=.*[a-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,20}"
    let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
    return passwordTest.evaluate(with: pwd)
  }

  func isValidPassword(pwd: String) -> Bool {
      let passwordRegEx = "^(?=.*[a-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{0,}"
      let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
      return passwordTest.evaluate(with: pwd)
  }
}
