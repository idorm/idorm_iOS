//
//  FindPwOrSignUpViewModel.swift
//  idorm
//
//  Created by 김응철 on 2022/08/17.
//

import Foundation
import RxSwift
import RxCocoa

class PutEmailViewModel {
  struct Input {
    let emailText = BehaviorRelay<String>(value: "")
    let confirmButtonTapped = PublishSubject<Void>()
  }
  
  struct Output {
    let showAuthVC = PublishSubject<Void>()
    let showErrorPopupVC = PublishSubject<String>()
  }
  
  let input = Input()
  let output = Output()
  let disposeBag = DisposeBag()
  
  init() {
    bind()
  }
  
  func bind() {
    // 완료 버튼 클릭 시 오류 및 이동
    input.confirmButtonTapped
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        let email = self.input.emailText.value
        if self.isValidEmail(id: email) == false {
          self.output.showErrorPopupVC.onNext("이메일 형식을 확인해 주세요.")
        } else {
          LoginStates.currentEmail = email
          self.output.showAuthVC.onNext(Void())
        }
      })
      .disposed(by: disposeBag)
  }

  func isValidEmail(id: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@inu.ac.kr"
    let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: id)
  }
}
