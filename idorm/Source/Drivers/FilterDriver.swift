//
//  FilterDriver.swift
//  idorm
//
//  Created by 김응철 on 2022/12/19.
//

import Foundation

import RxSwift
import RxCocoa

final class FilterDriver {
  
  static let shared = FilterDriver()
  private let disposeBag = DisposeBag()
  private init() {
    Observable.combineLatest(dorm, joinPeriod)
      .map { $0.0 && $0.1 ? true : false }
      .bind(to: isAllowed)
      .disposed(by: disposeBag)
  }
  
  let dorm = BehaviorRelay<Bool>(value: false)
  let joinPeriod = BehaviorRelay<Bool>(value: false)
  
  let isAllowed = BehaviorRelay<Bool>(value: false)
  
  func reset() {
    [dorm, joinPeriod].forEach { $0.accept(false) }
  }
}
