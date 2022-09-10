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
    let resetTimer = PublishSubject<Void>()
    let dismissVC = PublishSubject<Void>()
    let showPopupVC = PublishSubject<String>()
  }
  
  let input = Input()
  let output = Output()
  let disposeBag = DisposeBag()
  
  init() {
    bind()
  }
  
  func bind() {
    input.requestAgainButtonTapped
      .subscribe(onNext: { [weak self] in
        self?.requestEmailAPI()
      })
      .disposed(by: disposeBag)
    
    input.confirmButtonTapped
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.requestVerifyCodeAPI()
      })
      .disposed(by: disposeBag)
  }
  
  func requestEmailAPI() {
    guard let currentEmail = LoginStates.currentEmail else { return }
    EmailService.emailAPI(email: currentEmail, type: LoginStates.currentLoginType)
      .subscribe(onNext: { [weak self] response in
        print(LoginStates.currentLoginType)
        guard let statusCode = response.response?.statusCode else { return }
        switch statusCode {
        case 200:
          self?.output.showPopupVC.onNext("인증번호가 재전송 되었습니다.")
          self?.output.resetTimer.onNext(Void())
        default:
          self?.output.showPopupVC.onNext("치명적인 오류가 발생했습니다.")
        }
      })
      .disposed(by: disposeBag)
  }
  
  func requestVerifyCodeAPI() {
    guard let currentEmail = LoginStates.currentEmail else { return }
    let code = input.codeString.value
    
    EmailService.verifyCodeAPI(email: currentEmail, code: code, type: LoginStates.currentLoginType)
      .subscribe(onNext: { [weak self] response in
        guard let statusCode = response.response?.statusCode else { return }
        switch statusCode {
        case 200:
          self?.output.dismissVC.onNext(Void())
        case 400:
          self?.output.showPopupVC.onNext("인증번호를 다시 확인해 주세요.")
        default:
          break
        }
      })
      .disposed(by: disposeBag)
  }
}
