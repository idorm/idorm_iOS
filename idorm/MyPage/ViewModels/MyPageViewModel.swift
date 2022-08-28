//
//  MyPageViewModel.swift
//  idorm
//
//  Created by 김응철 on 2022/08/28.
//

import Foundation
import RxSwift
import RxCocoa

class MyPageViewModel {
  struct Input {
    let gearImageTapped = PublishSubject<Void>()
    let myPostButtonTapped = PublishSubject<MyPostVCType>()
    let myCommentsButtonTapped = PublishSubject<MyPostVCType>()
    let myRecommendButtonTapped = PublishSubject<MyPostVCType>()
    let likeRoommateButtonTapped = PublishSubject<MyPostVCType>()
    let matchingManagementButtonTapped = PublishSubject<Void>()
  }
  
  struct Output {
    let showManageMyInfoVC = PublishSubject<Void>()
    let showMyPostVC = PublishSubject<MyPostVCType>()
    let showOnboardingVC = PublishSubject<Void>()
  }
  
  let input = Input()
  let output = Output()
  let disposeBag = DisposeBag()
  
  init() {
    bind()
  }
  
  func bind() {
    input.gearImageTapped
      .bind(to: output.showManageMyInfoVC)
      .disposed(by: disposeBag)
    
    input.matchingManagementButtonTapped
      .bind(to: output.showOnboardingVC)
      .disposed(by: disposeBag)
    
    Observable.merge(
      input.myPostButtonTapped,
      input.myCommentsButtonTapped,
      input.myRecommendButtonTapped,
      input.likeRoommateButtonTapped
    )
    .bind(to: output.showMyPostVC)
    .disposed(by: disposeBag)
  }
}
