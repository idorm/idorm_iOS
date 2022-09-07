//
//  LoginViewModel.swift
//  idorm
//
//  Created by 김응철 on 2022/08/16.
//

import Foundation
import RxSwift
import RxCocoa

class LoginViewModel {
  struct Input {
    let loginButtonTapped = PublishSubject<Void>()
    let forgotButtonTapped = PublishSubject<Void>()
    let signUpButtonTapped = PublishSubject<Void>()
    let emailText = BehaviorRelay<String>(value: "")
    let passwordText = BehaviorRelay<String>(value: "")
  }
  
  struct Output {
    let showPutEmailVC = PublishSubject<LoginType>()
    let showErrorPopupVC = PublishSubject<String>()
    let showTabBarVC = PublishSubject<Void>()
  }
  
  init() {
    bind()
  }
  
  let input = Input()
  let output = Output()
  let disposeBag = DisposeBag()
  
  var emailText: String {
    return input.emailText.value
  }
  
  var passwordText: String {
    return input.passwordText.value
  }
  
  func bind() {
    // 비밀번호 찾기, 회원 가입 버튼 클릭 시에 화면전환
    input.forgotButtonTapped
      .map { .findPW }
      .bind(to: output.showPutEmailVC)
      .disposed(by: disposeBag)
    
    input.signUpButtonTapped
      .map { .singUp }
      .bind(to: output.showPutEmailVC)
      .disposed(by: disposeBag)
    
    // 로그인 시도 서버로 요청
    input.loginButtonTapped
      .bind(onNext: { [weak self] in
        self?.verifyUser()
      })
      .disposed(by: disposeBag)
  }
  
  func verifyUser() {
    MemberService.LoginAPI(email: self.emailText, password: self.passwordText)
      .subscribe(onNext: { [weak self] response in
        guard let statusCode = response.response?.statusCode else { return }
        guard let data = response.data else { return }
        switch statusCode {
        case 200:
          struct Response: Codable {
            let data: String
          }
          let token = APIService.decode(Response.self, data: data).data
          TokenManager.saveToken(token: token)
          self?.output.showTabBarVC.onNext(Void())
        case 400:
          struct Response: Codable {
            let message: String
          }
          let message = APIService.decode(Response.self, data: data).message
          self?.output.showErrorPopupVC.onNext(message)
        default:
          fatalError("Internal Server Error!")
        }
      })
      .disposed(by: disposeBag)
  }
}
