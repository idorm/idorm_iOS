//
//  MatchingViewModel.swift
//  idorm
//
//  Created by 김응철 on 2022/08/07.
//

import UIKit
import RxSwift
import RxCocoa

enum MatchingType {
  case cancel
  case heart
}

enum SwipeType {
  case cancel
  case heart
  case none
}

class MatchingViewModel {
  struct Input {
    let cancelButtonObserver = PublishSubject<Void>()
    let backButtonObserver = PublishSubject<Void>()
    let messageButtonObserver = PublishSubject<Void>()
    let heartButtonObserver = PublishSubject<Void>()
    let filterButtonObserver = PublishSubject<Void>()
    
    let swipeObserver = PublishSubject<MatchingType>()
    let didEndSwipeObserver = PublishSubject<SwipeType>()
    let cancelDeliverCardObserver = PublishSubject<SwipeCardView>()
  }
  
  struct Output {
    let cancelUserInfo = PublishSubject<Void>()
    let heartUserInfo = PublishSubject<Void>()
    
    let onChangedTopBackgroundColor = PublishSubject<MatchingType>()
    let onChangedTopBackgroundColor_WithTouch = PublishSubject<MatchingType>()
    let drawBackTopBackgroundColor = PublishSubject<Void>()
    let onChangedSwipeAnimation = PublishSubject<MatchingType>()
    
    let showFliterVC = PublishSubject<Void>()
    let appendRemovedCard = PublishSubject<SwipeCardView>()
    let revertCard = PublishSubject<Void>()
    
    let matchingCardInfos = BehaviorRelay<[MatchingInfo]>(value: [])
  }
  
  let input = Input()
  let output = Output()
  let disposeBag = DisposeBag()
  
  init() {
    bind()
  }
  
  func bind() {
    input.swipeObserver
      .bind(to: output.onChangedTopBackgroundColor)
      .disposed(by: disposeBag)
    
    input.didEndSwipeObserver
      .map { _ in Void() }
      .bind(to: output.drawBackTopBackgroundColor)
      .disposed(by: disposeBag)
    
    input.cancelButtonObserver
      .map { MatchingType.cancel }
      .bind(to: output.onChangedSwipeAnimation)
      .disposed(by: disposeBag)
    
    input.heartButtonObserver
      .map { MatchingType.heart }
      .bind(to: output.onChangedSwipeAnimation)
      .disposed(by: disposeBag)
    
    input.heartButtonObserver
      .map { MatchingType.heart }
      .bind(to: output.onChangedTopBackgroundColor_WithTouch)
      .disposed(by: disposeBag)
    
    input.cancelButtonObserver
      .map { MatchingType.cancel }
      .bind(to: output.onChangedTopBackgroundColor_WithTouch)
      .disposed(by: disposeBag)
    
    input.filterButtonObserver
      .bind(to: output.showFliterVC)
      .disposed(by: disposeBag)

    input.cancelDeliverCardObserver
      .bind(to: output.appendRemovedCard)
      .disposed(by: disposeBag)
    
    input.backButtonObserver
      .bind(to: output.revertCard)
      .disposed(by: disposeBag)
  }
}
