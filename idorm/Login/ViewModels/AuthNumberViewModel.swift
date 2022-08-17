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
    let showErrorPopupVC = PublishSubject<String>()
  }
  
  let input = Input()
  let output = Output()
  let disposeBag = DisposeBag()
  
  init() {
    bind()
  }
  
  func bind() {
    input.viewWillAppear
      .bind(onNext: { [weak self] in
        self?.authenticateEmail()
      })
      .disposed(by: disposeBag)
    
    input.requestAgainButtonTapped
      .map { [weak self] in
        self?.authenticateEmail()
      }
      .bind(to: output.requestTimer)
      .disposed(by: disposeBag)
    
    input.confirmButtonTapped
      .bind(onNext: { [weak self] in
        self?.verifyCode()
      })
      .disposed(by: disposeBag)
  }
  
  func authenticateEmail() {
    guard let currentEmail = LoginStates.currentEmail else { return }
    EmailService.authenticateEmail(email: currentEmail)
      .bind(onNext: { response in
        print(response.response.statusCode)
      })
      .disposed(by: disposeBag)
  }
  
  func verifyCode() {
    guard let currentEmail = LoginStates.currentEmail else { return }
    let code = input.codeString.value
    EmailService.verifyEmailCode(email: currentEmail, code: code)
      .bind(onNext: { [weak self] result in
        let statusCode = result.response.statusCode
        if (200..<300).contains(statusCode) {
          self?.output.dismissVC.onNext(Void())
        } else {
          self?.output.showErrorPopupVC.onNext("인증번호를 다시 확인해 주세요.")
        }
      })
      .disposed(by: disposeBag)
  }
}
