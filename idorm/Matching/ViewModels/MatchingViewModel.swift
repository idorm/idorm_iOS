//
//  MatchingViewModel.swift
//  idorm
//
//  Created by 김응철 on 2022/08/07.
//

import UIKit
import RxSwift
import RxCocoa

class MatchingViewModel {
  struct Input {
    let cancelButtonObserver = PublishSubject<Void>()
    let backButtonObserver = PublishSubject<Void>()
    let messageButtonObserver = PublishSubject<Void>()
    let heartButtonObserver = PublishSubject<Void>()
  }
  
  struct Output {
    let cancelUserInfo = PublishSubject<Void>()
    let heartUserInfo = PublishSubject<Void>()
    let matchingCardInfos = BehaviorRelay<[MyInfo]>(value: [])
    
  }
  
  let input = Input()
  let output = Output()
  let disposeBag = DisposeBag()
  
  init() {
    bind()
  }
  
  func bind() {
    input.cancelButtonObserver
      .bind(to: output.cancelUserInfo)
      .disposed(by: disposeBag)
    
    input.heartButtonObserver
      .bind(to: output.heartUserInfo)
      .disposed(by: disposeBag)
  }
}
