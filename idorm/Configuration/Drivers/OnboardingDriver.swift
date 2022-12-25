//
//  OnboardingDriver.swift
//  idorm
//
//  Created by 김응철 on 2022/12/25.
//

import RxSwift
import RxCocoa

final class OnboardingDriver {
  let dormConditon = BehaviorRelay<Bool>(value: false)
  let genderCondition = BehaviorRelay<Bool>(value: false)
  let joinPeriodCondition = BehaviorRelay<Bool>(value: false)
  let ageCondition = BehaviorRelay<Bool>(value: false)
  let wakeUpCondition = BehaviorRelay<Bool>(value: false)
  let cleanupCondition = BehaviorRelay<Bool>(value: false)
  let showerTimeCondition = BehaviorRelay<Bool>(value: false)
  let chatLinkCondition = BehaviorRelay<Bool>(value: false)
  
  let isEnabled = PublishSubject<Bool>()
  
  let disposeBag = DisposeBag()
  
  init() {
    Observable.combineLatest(
      dormConditon,
      genderCondition,
      joinPeriodCondition,
      ageCondition,
      wakeUpCondition,
      cleanupCondition,
      showerTimeCondition,
      chatLinkCondition
    )
    .map { $0.0 && $0.1 && $0.2 && $0.3 && $0.4 && $0.5 && $0.6 && $0.7 }
    .bind(to: isEnabled)
    .disposed(by: disposeBag)
  }
  
  func convertConditionToAll() {
    [
      dormConditon,
      genderCondition,
      joinPeriodCondition,
      ageCondition,
      wakeUpCondition,
      cleanupCondition,
      showerTimeCondition,
      chatLinkCondition
    ].forEach { $0.accept(true) }
  }
}
