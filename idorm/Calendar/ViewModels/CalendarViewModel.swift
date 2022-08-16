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
    let viewWillAppear = PublishSubject<Void>()
  }
  
  struct Output {
    let updateScrollViewHeight = PublishSubject<Void>()
  }
  
  let input = Input()
  let output = Output()
  let disposeBag = DisposeBag()
  
  func bind() {
    /// 화면 반응 할 때 ScrollViewHeight 동적 변경
    Observable.merge(
      input.leftArrowButtonTapped,
      input.rightArrowButtonTapped,
      input.viewWillAppear
    )
    .bind(to: output.updateScrollViewHeight)
    .disposed(by: disposeBag)
  }
  
  init() {
    bind()
  }
}
