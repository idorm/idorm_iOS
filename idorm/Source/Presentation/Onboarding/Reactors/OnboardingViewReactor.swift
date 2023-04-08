//
//  OnboardingViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2022/12/25.
//

import UIKit

import RxSwift
import RxCocoa
import RxMoya
import ReactorKit

final class OnboardingViewReactor: Reactor {
  
  enum Action {
    case viewDidLoad(MatchingInfoResponseModel.MatchingInfo)
    case didTapDormButton(Dormitory)
    case didTapGenderButton(Gender)
    case didTapJoinPeriodButton(JoinPeriod)
    case didTapHabitButton(Habit, Bool)
    case didChangeAgeTextField(String)
    case didChangeWakeUpTextField(String)
    case didChangeCleanUpTextField(String)
    case didChangeShowerTextField(String)
    case didChangeChatTextField(String)
    case didEndEditingChatTextField(String)
    case didChangeMbtiTextField(String)
    case didChangeWishTextView(String)
    case didTapLeftButton
    case didTapRightButton
  }
  
  enum Mutation {
    case setLoading(Bool)
    case setMatchingInfo(MatchingInfoRequestModel.MatchingInfo)
    case setDriver(OnboardingDriver)
    case setClear(Bool)
    case setMainVC(Bool)
    case setRootVC(Bool)
    case setOnboardingDetailVC(Bool, MatchingResponseModel.Member)
    case setChatBorderColor(UIColor)
    case setChatDescriptionTextColor(UIColor)
    case setChatTfCheckmark(Bool)
    case setPopup(Bool)
    case setWishTextCount(Int)
  }
  
  struct State {
    var currentMatchingInfo: MatchingInfoRequestModel.MatchingInfo = .init()
    var currentDriver: OnboardingDriver = .init()
    var currentWishTextCount: Int = 0
    var isLoading: Bool = false
    var isCleared: Bool = false
    var isOpenedMainVC: Bool = false
    var isOpenedRootVC: Bool = false
    var isOpenedOnboardingDetailVC: (Bool, MatchingResponseModel.Member) = (false, .init())
    var currentChatBorderColor: UIColor = .idorm_gray_300
    var currentChatDescriptionTextColor: UIColor = .idorm_gray_300
    var isHiddenChatTfCheckmark: Bool = true
    var isOpenedPopup: Bool = false
  }
  
  var initialState: State = State()
  private let type: Onboarding
  
  init(_ type: Onboarding) {
    self.type = type
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    var newMatchingInfo = currentState.currentMatchingInfo
    let newDriver = currentState.currentDriver
    
    switch action {
    case .viewDidLoad(let matchingInfo):
      newDriver.convertConditionToAllTrue()
      
      newMatchingInfo.dormCategory = matchingInfo.dormCategory
      newMatchingInfo.joinPeriod = matchingInfo.joinPeriod
      newMatchingInfo.gender = matchingInfo.gender
      newMatchingInfo.age = String(matchingInfo.age)
      newMatchingInfo.isSnoring = matchingInfo.isSnoring
      newMatchingInfo.isGrinding = matchingInfo.isGrinding
      newMatchingInfo.isSmoking = matchingInfo.isSmoking
      newMatchingInfo.isAllowedFood = matchingInfo.isAllowedFood
      newMatchingInfo.isWearEarphones = matchingInfo.isWearEarphones
      newMatchingInfo.wakeupTime = matchingInfo.wakeUpTime
      newMatchingInfo.cleanUpStatus = matchingInfo.cleanUpStatus
      newMatchingInfo.showerTime = matchingInfo.showerTime
      newMatchingInfo.mbti = matchingInfo.mbti
      newMatchingInfo.wishText = matchingInfo.wishText
      newMatchingInfo.openKakaoLink = matchingInfo.openKakaoLink
      
      return .concat([
        .just(.setDriver(newDriver)),
        .just(.setMatchingInfo(newMatchingInfo)),
        .just(.setChatTfCheckmark(false))
      ])
      
    case .didTapDormButton(let dorm):
      newMatchingInfo.dormCategory = dorm
      newDriver.dormConditon.accept(true)
      return .concat([
        .just(.setMatchingInfo(newMatchingInfo)),
        .just(.setDriver(newDriver))
      ])
      
    case .didTapGenderButton(let gender):
      newMatchingInfo.gender = gender
      newDriver.genderCondition.accept(true)
      return .concat([
        .just(.setMatchingInfo(newMatchingInfo)),
        .just(.setDriver(newDriver))
      ])

    case .didTapJoinPeriodButton(let period):
      newMatchingInfo.joinPeriod = period
      newDriver.joinPeriodCondition.accept(true)
      return .concat([
        .just(.setMatchingInfo(newMatchingInfo)),
        .just(.setDriver(newDriver))
      ])
      
    case let .didTapHabitButton(habit, isSelected):
      switch habit {
      case .snoring:
        newMatchingInfo.isSnoring = isSelected
        return .just(.setMatchingInfo(newMatchingInfo))
        
      case .smoking:
        newMatchingInfo.isSmoking = isSelected
        return .just(.setMatchingInfo(newMatchingInfo))
        
      case .grinding:
        newMatchingInfo.isGrinding = isSelected
        return .just(.setMatchingInfo(newMatchingInfo))
        
      case .allowedFood:
        newMatchingInfo.isAllowedFood = isSelected
        return .just(.setMatchingInfo(newMatchingInfo))
        
      case .allowedEarphone:
        newMatchingInfo.isWearEarphones = isSelected
        return .just(.setMatchingInfo(newMatchingInfo))
      }
      
    case .didChangeAgeTextField(let age):
      newMatchingInfo.age = age
      if age.count < 2 {
        newDriver.ageCondition.accept(false)
      } else {
        newDriver.ageCondition.accept(true)
      }
      return .concat([
        .just(.setMatchingInfo(newMatchingInfo)),
        .just(.setDriver(newDriver))
      ])
      
    case .didChangeWakeUpTextField(let string):
      newMatchingInfo.wakeupTime = string
      string == "" ? newDriver.wakeUpCondition.accept(false) : newDriver.wakeUpCondition.accept(true)
      return .concat([
        .just(.setMatchingInfo(newMatchingInfo)),
        .just(.setDriver(newDriver))
      ])
      
    case .didChangeCleanUpTextField(let string):
      newMatchingInfo.cleanUpStatus = string
      string == "" ? newDriver.cleanupCondition.accept(false) : newDriver.cleanupCondition.accept(true)
      return .concat([
        .just(.setMatchingInfo(newMatchingInfo)),
        .just(.setDriver(newDriver))
      ])
      
    case .didChangeShowerTextField(let string):
      newMatchingInfo.showerTime = string
      string == "" ? newDriver.showerTimeCondition.accept(false) : newDriver.showerTimeCondition.accept(true)
      return .concat([
        .just(.setMatchingInfo(newMatchingInfo)),
        .just(.setDriver(newDriver))
      ])
      
    case .didChangeChatTextField(let string):
      if string == "" {
        newDriver.chatLinkCondition.accept(false)
      } else {
        newDriver.chatLinkCondition.accept(true)
      }
      newMatchingInfo.openKakaoLink = string
      return .concat([
        .just(.setMatchingInfo(newMatchingInfo)),
        .just(.setDriver(newDriver)),
        .just(.setChatTfCheckmark(true))
      ])
      
    case .didEndEditingChatTextField(let text):
      if text.isValidKakaoLink {
        return .concat([
          .just(.setChatBorderColor(.idorm_gray_300)),
          .just(.setChatTfCheckmark(false)),
          .just(.setChatDescriptionTextColor(.idorm_gray_300))
        ])
      } else {
        return .concat([
          .just(.setChatBorderColor(.idorm_red)),
          .just(.setChatTfCheckmark(true)),
          .just(.setChatDescriptionTextColor(.idorm_red))
        ])
      }
      
    case .didChangeMbtiTextField(let string):
      newMatchingInfo.mbti = string
      return .just(.setMatchingInfo(newMatchingInfo))
      
    case .didChangeWishTextView(let string):
      newMatchingInfo.wishText = string
      return .concat([
        .just(.setMatchingInfo(newMatchingInfo)),
        .just(.setWishTextCount(string.count))
      ])
      
    case .didTapLeftButton:
      switch type {
      case .initial:
        return .concat([
          .just(.setMainVC(true)),
          .just(.setMainVC(false))
        ])
      case .main, .modify:
        newDriver.convertConditionToAllFalse()
        return .concat([
          .just(.setClear(true)),
          .just(.setClear(false)),
          .just(.setDriver(newDriver))
        ])
      }
      
    case .didTapRightButton:
      let kakaoLink = currentState.currentMatchingInfo.openKakaoLink
      
      switch type {
      case .initial, .main:
        let member = TransformUtils.transfer(currentState.currentMatchingInfo)
        
        if kakaoLink.isValidKakaoLink {
          return .concat([
            .just(.setOnboardingDetailVC(true, member)),
            .just(.setOnboardingDetailVC(false, member))
          ])
        } else {
          return .concat([
            .just(.setPopup(true)),
            .just(.setPopup(false))
          ])
        }
        
      case .modify:
        if kakaoLink.isValidKakaoLink {
          return .concat([
            .just(.setLoading(true)),
            MatchingInfoAPI.provider.rx.request(
              .modify(currentState.currentMatchingInfo)
            )
              .asObservable()
              .debug()
              .retry()
              .map(ResponseModel<MatchingInfoResponseModel.MatchingInfo>.self)
              .flatMap { response -> Observable<Mutation> in
                UserStorage.shared.saveMatchingInfo(response.data)
                return .concat([
                  .just(.setLoading(false)),
                  .just(.setRootVC(true)),
                  .just(.setRootVC(false))
                ])
              }
          ])
        } else {
          return .concat([
            .just(.setPopup(true)),
            .just(.setPopup(false))
          ])
        }
        
      }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setMatchingInfo(let matchingInfo):
      newState.currentMatchingInfo = matchingInfo
      
    case .setDriver(let driver):
      newState.currentDriver = driver
      
    case .setLoading(let isLoading):
      newState.isLoading = isLoading
      
    case .setRootVC(let isOpened):
      newState.isOpenedRootVC = isOpened
      
    case let .setOnboardingDetailVC(isOpened, info):
      newState.isOpenedOnboardingDetailVC = (isOpened, info)
      
    case .setClear(let isCleared):
      newState.isCleared = isCleared
      
    case .setMainVC(let isOpened):
      newState.isOpenedMainVC = isOpened
      
    case .setChatTfCheckmark(let isHidden):
      newState.isHiddenChatTfCheckmark = isHidden
      
    case .setChatBorderColor(let color):
      newState.currentChatBorderColor = color
      
    case .setChatDescriptionTextColor(let textColor):
      newState.currentChatDescriptionTextColor = textColor
      
    case .setPopup(let isOpened):
      newState.isOpenedPopup = isOpened
      
    case .setWishTextCount(let count):
      newState.currentWishTextCount = count
    }
    
    return newState
  }
}
