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
    /// 완료 버튼 클릭 시 오류 및 이동
    input.confirmButtonTapped
      .bind(onNext: { [unowned self] in
        LoginStates.email = self.email
        
        switch LoginStates.registerType {
        case .findPW:
          self.passwordEmailAPI()
        case .signUp:
          self.registerEmailAPI()
        }
      })
      .disposed(by: disposeBag)
    
    /// 완료 버튼 클릭 시 애니메이션 시작
    input.confirmButtonTapped
      .bind(to: output.startAnimation)
      .disposed(by: disposeBag)
  }
  
  func passwordEmailAPI() {
    EmailService.passwordEmailAPI(email: self.email)
      .subscribe(onNext: { [weak self] response in
        guard let statusCode = response.response?.statusCode else { return }
        self?.output.stopAnimation.onNext(Void())
        switch statusCode {
        case 200:
          self?.output.showAuthVC.onNext(Void())
        case 401:
          self?.output.showErrorPopupVC.onNext("이메일을 찾을 수 없습니다.")
        case 409:
          self?.output.showErrorPopupVC.onNext("가입되지 않은 이메일입니다.")
        default:
          self?.output.showErrorPopupVC.onNext("이메일을 다시 한번 확인해주세요.")
        }
      })
      .disposed(by: disposeBag)
  }
  
  func registerEmailAPI() {
    EmailService.registerEmailAPI(email: self.email)
      .subscribe(onNext: { [weak self] response in
        guard let statusCode = response.response?.statusCode else { return }
        self?.output.stopAnimation.onNext(Void())
        switch statusCode {
        case 200:
          self?.output.showAuthVC.onNext(Void())
        case 400:
          self?.output.showErrorPopupVC.onNext("이메일을 입력해 주세요.")
        case 401:
          self?.output.showErrorPopupVC.onNext("올바른 이메일 형식이 아닙니다.")
        case 409:
          self?.output.showErrorPopupVC.onNext("이미 가입된 이메일입니다.")
        default:
          self?.output.showErrorPopupVC.onNext("이메일을 다시 한번 확인해주세요.")
        }
      })
      .disposed(by: disposeBag)
  }
}
