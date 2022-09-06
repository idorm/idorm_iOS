//
//  CompleteSignUpViewModel.swift
//  idorm
//
//  Created by 김응철 on 2022/08/27.
//

import Foundation
import RxSwift
import RxCocoa

class CompleteSignUpViewModel {
  struct Input {
    let continueButtonTapped = PublishSubject<Void>()
  }
  
  struct Output {
    let showOnboardingVC = PublishSubject<Void>()
  }
  
  let input = Input()
  let output = Output()
  let disposeBag = DisposeBag()
  let service = ConfirmPasswordService()
  
  init() {
    bind()
  }
  
  func bind() {
    input.continueButtonTapped
      .bind(onNext: { [weak self] in
        self?.loginAPI()
      })
      .disposed(by: disposeBag)
  }
  
  func loginAPI() {
    guard let email = LoginStates.currentEmail else { return }
    guard let password = LoginStates.currentPassword else { return }
    service.postLogin(email: email, password: password)
      .subscribe(onNext: { [weak self] response in
        guard let token = String(data: response.data, encoding: .utf8) else { return }
        TokenManager.saveToken(token: token)
        self?.output.showOnboardingVC.onNext(Void())
      })
      .disposed(by: disposeBag)
  }
}
