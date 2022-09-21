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
  
  init() {
    bind()
  }
  
  func bind() {
    input.continueButtonTapped
      .bind(onNext: { [weak self] in
        self?.requestLoginAPI()
      })
      .disposed(by: disposeBag)
  }
  
  func requestLoginAPI() {
    guard let email = LoginStates.email else { return }
    guard let password = LoginStates.password else { return }
    
    MemberService.LoginAPI(email: email, password: password)
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
          self?.output.showOnboardingVC.onNext(Void())
        default:
          // 오류처리
          break
        }
      })
      .disposed(by: disposeBag)
  }
}
