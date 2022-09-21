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
    let showPutEmailVC = PublishSubject<RegisterType>()
    let showErrorPopupVC = PublishSubject<String>()
    let showTabBarVC = PublishSubject<Void>()
    let startAnimation = PublishSubject<Void>()
    let stopAnimation = PublishSubject<Void>()
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
    /// 비밀번호 찾기, 회원 가입 버튼 클릭 시에 화면전환
    input.forgotButtonTapped
      .map { .findPW }
      .bind(to: output.showPutEmailVC)
      .disposed(by: disposeBag)
    
    /// 회원가입 버튼 클릭 시 화면전환
    input.signUpButtonTapped
      .map { .signUp }
      .bind(to: output.showPutEmailVC)
      .disposed(by: disposeBag)
    
    /// 로그인 시도 서버로 요청
    input.loginButtonTapped
      .bind(onNext: { [weak self] in
        self?.loginAPI()
      })
      .disposed(by: disposeBag)
    
    /// 로그인 버튼 클릭 시 interaction, Animation 조정
    input.loginButtonTapped
      .bind(to: output.startAnimation)
      .disposed(by: disposeBag)
  }
  
  func loginAPI() {
    MemberService.LoginAPI(email: self.emailText, password: self.passwordText)
      .subscribe(onNext: { [weak self] response in
        guard let statusCode = response.response?.statusCode else { return }
        guard let data = response.data else { return }
        self?.output.stopAnimation.onNext(Void())
        switch statusCode {
        case 200:
          struct LoginResponseModel: Codable {
            struct Response: Codable {
              let loginToken: String
            }
            let data: Response
          }
          let token = APIService.decode(LoginResponseModel.self, data: data).data.loginToken
          TokenManager.saveToken(token: token)
          self?.output.showTabBarVC.onNext(Void())
        case 400:
          self?.output.showErrorPopupVC.onNext("가입되지 않은 이메일입니다.")
        case 401:
          self?.output.showErrorPopupVC.onNext("올바르지 않은 비밀번호입니다.")
        default:
          self?.output.showErrorPopupVC.onNext("이메일과 비밀번호를 다시 한번 확인해주세요.")
        }
      })
      .disposed(by: disposeBag)
  }
}

