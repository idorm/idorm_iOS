//
//  AuthViewModel.swift
//  idorm
//
//  Created by 김응철 on 2022/08/17.
//

import Foundation
import RxSwift
import RxCocoa

class AuthViewModel {
  struct Input {
    let backButtonTapped = PublishSubject<Void>()
    let portalButtonTapped = PublishSubject<Void>()
    let confirmButtonTapped = PublishSubject<Void>()
  }
  
  struct Output {
    let dismissVC = PublishSubject<Void>()
    let showPortalWeb = PublishSubject<Void>()
    let showAuthNumberVC = PublishSubject<Void>()
  }
  
  let input = Input()
  let output = Output()
  let disposeBag = DisposeBag()
  
  init() {
    bind()
  }
  
  func bind() {
    input.backButtonTapped
      .bind(to: output.dismissVC)
      .disposed(by: disposeBag)
    
    input.portalButtonTapped
      .bind(to: output.showPortalWeb)
      .disposed(by: disposeBag)
    
    input.confirmButtonTapped
      .bind(to: output.showAuthNumberVC)
      .disposed(by: disposeBag)
  }
}
