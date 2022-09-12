//
//  OnboardingDetailViewModel.swift
//  idorm
//
//  Created by 김응철 on 2022/09/10.
//

import Foundation
import RxSwift
import RxCocoa

class OnboardingDetailViewModel {
  struct Input {
    let didTapBackButton = PublishSubject<Void>()
  }
  
  struct Output {
    let popVC = PublishSubject<Void>()
  }
  
  let input = Input()
  let output = Output()
  let disposeBag = DisposeBag()
  
  init() {
    bind()
  }
  
  func bind() {
    input.didTapBackButton
      .bind(to: output.popVC)
      .disposed(by: disposeBag)
  }
}
