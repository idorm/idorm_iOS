//
//  AuthNumberViewModel.swift
//  idorm
//
//  Created by 김응철 on 2022/08/17.
//

import Foundation
import RxSwift
import RxCocoa

class AuthNumberViewModel {
  struct Input {
    let requestAgainButtonTapped = PublishSubject<Void>()
    let confirmButtonTapped = PublishSubject<Void>()
    let viewWillAppear = PublishSubject<Void>()
    let codeString = BehaviorRelay<String>(value: "")
  }
  
  struct Output {
    let requestTimer = PublishSubject<Void>()
    let dismissVC = PublishSubject<Void>()
    let showPopupVC = PublishSubject<String>()
    let buttonState = BehaviorRelay<Bool>(value: true)
  }
  
  let input = Input()
  let output = Output()
  let disposeBag = DisposeBag()
  
  init() {
    bind()
  }
  
  func bind() {
    input.requestAgainButtonTapped
      .map { [weak self] in
        self?.requestAgainAPI()
      }
      .bind(to: output.requestTimer)
      .disposed(by: disposeBag)
    
    input.confirmButtonTapped
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        guard self.output.buttonState.value == true else { return }
        self.output.buttonState.accept(false)
        self.verifyCode()
      })
      .disposed(by: disposeBag)
  }
  
  func requestAgainAPI() {
    guard let currentEmail = LoginStates.currentEmail else { return }
    AuthNumberService.authenticateEmail(email: currentEmail, type: LoginStates.currentLoginType)
      .bind(onNext: { [weak self] response in
        let statusCode = response.response.statusCode
        if statusCode == 200 {
          self?.output.showPopupVC.onNext("인증번호가 재전송 되었습니다.")
        } else {
          self?.output.showPopupVC.onNext("치명적인 오류가 발생했습니다.")
        }
      })
      .disposed(by: disposeBag)
  }
  
  func verifyCode() {
    guard let currentEmail = LoginStates.currentEmail else { return }
    print(currentEmail)
    let code = input.codeString.value
    AuthNumberService.verifyEmailCode(email: currentEmail, code: code, type: LoginStates.currentLoginType)
      .bind(onNext: { [weak self] result in
        let statusCode = result.response.statusCode
        if statusCode == 200 {
          self?.output.dismissVC.onNext(Void())
        } else {
          self?.output.showPopupVC.onNext("인증번호를 다시 확인해 주세요.")
        }
        self?.output.buttonState.accept(true)
      })
      .disposed(by: disposeBag)
  }
}
