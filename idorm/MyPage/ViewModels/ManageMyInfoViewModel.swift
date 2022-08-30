//
//  ManageMyInfoViewModel.swift
//  idorm
//
//  Created by 김응철 on 2022/08/29.
//

import RxSwift
import RxCocoa
import Foundation

class ManageMyInfoViewModel {
  struct Input {
    let viewDidLoad = PublishSubject<Void>()
    let viewWillAppear = PublishSubject<Void>()
    let profileImageTapped = PublishSubject<Void>()
  }
  
  struct Output {
    let configureUI = PublishSubject<Void>()
  }
  
  let input = Input()
  let output = Output()
  let disposeBag = DisposeBag()
  
  init() {
    bind()
  }
  
  func bind() {
    input.viewDidLoad
      .bind(to: output.configureUI)
      .disposed(by: disposeBag)
    
    input.profileImageTapped
      .subscribe(onNext: {
        print("Tapped!")
      })
      .disposed(by: disposeBag)
  }
}
