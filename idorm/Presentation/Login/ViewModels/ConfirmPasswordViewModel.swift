//
//  ConfirmPasswordViewModel.swift
//  idorm
//
//  Created by 김응철 on 2022/08/18.
//

import Foundation
import RxSwift
import RxCocoa

class ConfirmPasswordViewModel {
  struct Input {
    let confirmButtonTapped = PublishSubject<Void>()
    let passwordText = BehaviorRelay<String>(value: "")
    let passwordText_2 = BehaviorRelay<String>(value: "")
    let passwordTextFieldDidEnd = PublishSubject<Void>()
    let passwordTextFieldDidEnd_2 = PublishSubject<Void>()
    let passwordTextFieldDidBegin = PublishSubject<Void>()
    let passwordTextFieldDidBegin_2 = PublishSubject<Void>()
  }
  
  struct Output {
    let countState = BehaviorRelay<Bool>(value: false)
    let combineState = BehaviorRelay<Bool>(value: false)
    let didBeginState = PublishSubject<Void>()
    let didBeginState_2 = PublishSubject<Void>()
    let didEndState = PublishSubject<Void>()
    let didEndState_2 = PublishSubject<Void>()
    let showErrorPopupVC = PublishSubject<String>()
    let showCompleteVC = PublishSubject<Void>()
    let showLoginVC = PublishSubject<Void>()
  }
  
  let input = Input()
  let output = Output()
  let disposeBag = DisposeBag()
  
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
          
          if LoginStates.currentLoginType == .signUp {
            self.requestRegisterAPI()
          } else {
            
          }
        } else {
          self.output.showErrorPopupVC.onNext("조건을 다시 확인해 주세요.")
        }
      })
      .disposed(by: disposeBag)
  }
  
  func requestRegisterAPI() {
    guard let email = LoginStates.currentEmail else { return }
    
    MemberService.registerAPI(email: email, password: passwordText)
      .subscribe(onNext: { [weak self] response in
        print(email)
        print(self?.passwordText)
        guard let statusCode = response.response?.statusCode else { return }
        switch statusCode {
        case 200:
          LoginStates.currentPassword = self?.passwordText
          self?.output.showCompleteVC.onNext(Void())
        default:
          self?.output.showErrorPopupVC.onNext("등록되지 않은 이메일입니다.")
        }
      })
      .disposed(by: disposeBag)
  }
  
  func requestChangePasswordAPI() {
    guard let email = LoginStates.currentEmail else { return }
    
    MemberService.changePasswordAPI(email: email, password: passwordText)
      .subscribe(onNext: { [weak self] response in
        guard let statusCode = response.response?.statusCode else { return }
        switch statusCode {
        case 200:
          self?.output.showErrorPopupVC.onNext("비밀번호가 변경 되었습니다.")
          self?.output.showLoginVC.onNext(Void())
        default:
          // 오류 처리하기
          break
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
