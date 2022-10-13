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
    let viewDidLoadObserver = PublishSubject<Void>()
    
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
    let showFirstPopupVC = PublishSubject<Void>()
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
    
    // 화면 처음 진입 -> 온보딩 유무 체크 후 PopupVC 보여주기
    input.viewDidLoadObserver
      .bind(onNext: {
        self.matchingInfoAPI()
      })
      .disposed(by: disposeBag)
    
    // 스와이프 액션 -> 배경화면 컬러 감지
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
  
  func matchingInfoAPI() {
    OnboardingService.matchingInfoAPI_Get()
      .bind(onNext: { [unowned self] response in
        guard let statusCode = response.response?.statusCode else { return }
        switch statusCode {
        case 200:
          break
        default:
          // 매칭 정보가 없을 시에 팝업 창 띄우기
          self.output.showFirstPopupVC.onNext(Void())
        }
      })
      .disposed(by: disposeBag)
  }
}
