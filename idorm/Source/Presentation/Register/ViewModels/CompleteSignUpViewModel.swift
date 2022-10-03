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
    let startAnimation = PublishSubject<Void>()
    let stopAnimation = PublishSubject<Void>()
  }
  
  let input = Input()
  let output = Output()
  var disposeBag = DisposeBag()
  
  init() {
    bind()
  }
  
  func bind() {
    /// 로그인 버튼 클릭 시 회원가입API 요청
    input.continueButtonTapped
      .bind(onNext: { [weak self] in
        self?.LoginAPI()
      })
      .disposed(by: disposeBag)
    
    /// 로그인 버튼 클릭 시 애니메이션 시작
    input.continueButtonTapped
      .bind(to: output.startAnimation)
      .disposed(by: disposeBag)
  }
  
  func LoginAPI() {
    guard let email = LoginStates.email else { return }
    guard let password = LoginStates.password else { return }
    
    MemberService.LoginAPI(email: email, password: password)
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
          self?.output.showOnboardingVC.onNext(Void())
        default:
          fatalError("LoginAPI ERROR!")
        }
      })
      .disposed(by: disposeBag)
  }
}
