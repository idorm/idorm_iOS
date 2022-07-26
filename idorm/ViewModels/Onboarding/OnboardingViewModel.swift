//
//  OnboardingViewModel.swift
//  idorm
//
//  Created by 김응철 on 2022/07/08.
//

import RxSwift
import RxCocoa

class OnboardingViewModel {
  // MARK: - Properties
  struct Input {
    let dorm1ButtonTapped = BehaviorRelay<Bool>(value: false)
    let dorm2ButtonTapped = BehaviorRelay<Bool>(value: false)
    let dorm3ButtonTapped = BehaviorRelay<Bool>(value: false)
    
    let maleButtonTapped = BehaviorRelay<Bool>(value: false)
    let femaleButtonTapped = BehaviorRelay<Bool>(value: false)
    
    let snoringButtonTapped = BehaviorRelay<Bool>(value: false)
    let grindingButtonTapped = BehaviorRelay<Bool>(value: false)
    let smokingButtonTapped = BehaviorRelay<Bool>(value: false)
    let allowedFoodButtonTapped = BehaviorRelay<Bool>(value: false)
    let allowedEarphoneButtonTapped = BehaviorRelay<Bool>(value: false)
    
    let ageTextFieldChanged = BehaviorRelay<String>(value: "")
    
    let wakeUpTimeTextFieldChanged = BehaviorRelay<String>(value: "")
    let cleanUpTimeTextFieldChanged = BehaviorRelay<String>(value: "")
    let showerTimeTextFieldChanged = BehaviorRelay<String>(value: "")
    let mbtiTextFieldChanged = BehaviorRelay<String>(value: "")
    let chatLinkTextFieldChanged = BehaviorRelay<String>(value: "")
    let wishTextTextFieldChanged = BehaviorRelay<String>(value: "")
  }
  
  struct Output {
    let myInfo = BehaviorRelay<MyInfo?>(value: nil)
    let enableConfirmButton = PublishRelay<Bool>()
    let didClickJumpButton = PublishRelay<Void>()
  }
  
  let input = Input()
  let output = Output()
  
  var numberOfRowsInSection: Int {
    return OnboardingListType.allCases.count
  }

  func getQuestionText(index: Int) -> String {
    return OnboardingListType.allCases[index].query
  }
  
  // MARK: - LifeCycle
  init() {
    input.dorm1ButtonTapped
      .asObservable()
      .subscribe(onNext: {
        output.myInfo.
      })
  }
  
  var myInfo: MyInfo?
}
