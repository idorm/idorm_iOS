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
    LoginService.postLogin(email: self.emailText, password: self.passwordText)
      .subscribe(onNext: { [weak self] result in
        let statusCode = result.response.statusCode
        if statusCode == 200 {
          guard let accessToken = String(data: result.data, encoding: .utf8) else { return }
          let userDefaults = UserDefaults.standard
          userDefaults.set(accessToken, forKey: "Token")
          self?.output.showTabBarVC.onNext(Void())
        } else {
          struct Response: Codable {
            let message: String
          }
          guard let response = try? JSONDecoder().decode(Response.self, from: result.data) else { return }
          self?.output.showErrorPopupVC.onNext(response.message)
        }
      })
      .disposed(by: disposeBag)
  }
  
  func isValidEmail(id: String) -> Bool {
         let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
         let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
         return emailTest.evaluate(with: id)
     }
     
  func isValidPassword(pwd: String) -> Bool {
      let passwordRegEx = "^(?=.*[a-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{0,}"
      let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
      return passwordTest.evaluate(with: pwd)
  }
  
  func isValidPasswordFinal(pwd: String) -> Bool {
      let passwordRegEx = "^(?=.*[a-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,20}"
      let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
      return passwordTest.evaluate(with: pwd)
  }
}
