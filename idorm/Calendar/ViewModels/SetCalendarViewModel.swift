//
//  SetCalendarViewModel.swift
//  idorm
//
//  Created by 김응철 on 2022/08/04.
//

import RxSwift
import RxCocoa
import Foundation

class SetCalendarViewModel {
  struct Input {
    let valueChangedDatePicker = PublishSubject<Date>()
  }
  
  struct Output {
    let onChangedAllDayButtonState = BehaviorRelay<Bool>(value: false)
    let onChangedStartDate = BehaviorRelay<Date>(value: Date())
    let onChangedEndDate = BehaviorRelay<Date>(value: Date())
    let onChangedStartTime = BehaviorRelay<Date>(value: Date())
    let onChangedEndTime = BehaviorRelay<Date>(value: Date())
  }
  
  let input = Input()
  let output = Output()
  
  init() {
    bind()
  }
  
  func bind() {
  }
}
