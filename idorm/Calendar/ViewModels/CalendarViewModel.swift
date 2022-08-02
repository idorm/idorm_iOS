//
//  CalendarViewModel.swift
//  idorm
//
//  Created by 김응철 on 2022/07/29.
//

import RxSwift
import CoreGraphics

class CalendarViewModel {
  struct Input {
    let leftArrowButtonTapped = PublishSubject<Void>()
    let rightArrowButtonTapped = PublishSubject<Void>()
  }
  
  struct Output {
    let onChangedMonth = PublishSubject<Bool>()
    let onChangedCalendarViewHeight = PublishSubject<CGFloat>()
  }
  
  let input = Input()
  let output = Output()
  let disposeBag = DisposeBag()
  
  func bind() {
    input.leftArrowButtonTapped
      .map { false }
      .bind(to: output.onChangedMonth)
      .disposed(by: disposeBag)
    
    input.rightArrowButtonTapped
      .map { true }
      .bind(to: output.onChangedMonth)
      .disposed(by: disposeBag)
  }
  
  init() {
    bind()
  }
}
