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
    
  }
  
  struct Output {
    let matchingCardInfos = BehaviorRelay<[MyInfo]>(value: [])
  }
  
  let input = Input()
  let output = Output()
  
  init() {
    bind()
  }
  
  func bind() {
    
  }
}
