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
    let startAnimation = PublishSubject<Void>()
    let stopAnimation = PublishSubject<Void>()
  }
  
  let input = Input()
  let output = Output()
  let disposeBag = DisposeBag()
  
  var email: String {
    return input.emailText.value
  }
  
  init() {
    bind()
  }
  
  func bind() {
    // 완료 버튼 클릭 시 오류 및 이동
    input.confirmButtonTapped
      .bind(onNext: { [weak self] in
        self?.output.startAnimation.onNext(Void())
        guard let self = self else { return }
        LoginStates.currentEmail = self.email
        self.requestEmailAPI(email: self.email, type: LoginStates.currentLoginType)
      })
      .disposed(by: disposeBag)
  }
  
  func requestEmailAPI(email: String, type: LoginType) {
    EmailService.emailAPI(email: email, type: type)
      .subscribe(onNext: { [weak self] response in
        guard let statusCode = response.response?.statusCode else { return }
        guard let data = response.data else { return }
        self?.output.stopAnimation.onNext(Void())
        switch statusCode {
        case 200:
          self?.output.showAuthVC.onNext(Void())
        case 400:
          struct Response: Codable {
            let message: String
          }
          let message = APIService.decode(Response.self, data: data).message
          self?.output.showErrorPopupVC.onNext(message)
        default:
          // 오류 처리 하기
          break
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

