//
//  OnboardingViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2022/12/25.
//

import Foundation

import RxSwift
import RxCocoa
import RxMoya
import ReactorKit

final class OnboardingViewReactor: Reactor {
  
  enum Action {
    case viewDidLoad
    case didTapDormButton(Dormitory)
    case didTapGenderButton(Gender)
    case didTapJoinPeriodButton(JoinPeriod)
    case didTapHabitButton(Habit, Bool)
    case didChangeAgeTf(String)
    case didChangeWakeUpTf(String)
    case didChangeCleanUpTf(String)
    case didChangeShowerTimeTf(String)
    case didChangeOpenKakaoLinkTf(String)
    case didChangeMbtiTf(String)
    case didChangeWishTv(String)
    case didTapLeftButton
    case didTapRightButton
  }
  
  enum Mutation {
    case setLoading(Bool)
    case setMatchingInfo(MatchingInfoDTO.Save)
    case setDriver(OnboardingDriver)
    case setClear(Bool)
    case setMainVC(Bool)
    case setRootVC(Bool)
    case setOnboardingDetailVC(Bool, MatchingDTO.Retrieve)
  }
  
  struct State {
    var currentMatchingInfo: MatchingInfoDTO.Save = .init()
    var currentDriver: OnboardingDriver = .init()
    var isLoading: Bool = false
    var isCleared: Bool = false
    var isOpenedMainVC: Bool = false
    var isOpenedRootVC: Bool = false
    var isOpenedOnboardingDetailVC: (Bool, MatchingDTO.Retrieve) = (false, .init())
  }
  
  var initialState: State = State()
  private let type: OnboardingEnumerations
  
  init(_ type: OnboardingEnumerations) {
    self.type = type
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    var newMatchingInfo = currentState.currentMatchingInfo
    var newDriver = currentState.currentDriver
    
    switch action {
    case .viewDidLoad:
      newDriver.convertConditionToAll()
      return .just(.setDriver(newDriver))
      
    case .didTapDormButton(let dorm):
      newMatchingInfo.dormNum = dorm
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
      
    case .didChangeAgeTf(let age):
      newMatchingInfo.age = age
      age == "" ? newDriver.ageCondition.accept(false) : newDriver.ageCondition.accept(true)
      return .concat([
        .just(.setMatchingInfo(newMatchingInfo)),
        .just(.setDriver(newDriver))
      ])
      
    case .didChangeWakeUpTf(let string):
      newMatchingInfo.wakeupTime = string
      string == "" ? newDriver.wakeUpCondition.accept(false) : newDriver.wakeUpCondition.accept(true)
      return .concat([
        .just(.setMatchingInfo(newMatchingInfo)),
        .just(.setDriver(newDriver))
      ])
      
    case .didChangeCleanUpTf(let string):
      newMatchingInfo.cleanUpStatus = string
      string == "" ? newDriver.cleanupCondition.accept(false) : newDriver.cleanupCondition.accept(true)
      return .concat([
        .just(.setMatchingInfo(newMatchingInfo)),
        .just(.setDriver(newDriver))
      ])
      
    case .didChangeShowerTimeTf(let string):
      newMatchingInfo.showerTime = string
      string == "" ? newDriver.showerTimeCondition.accept(false) : newDriver.showerTimeCondition.accept(true)
      return .concat([
        .just(.setMatchingInfo(newMatchingInfo)),
        .just(.setDriver(newDriver))
      ])
      
    case .didChangeOpenKakaoLinkTf(let string):
      newMatchingInfo.openKakaoLink = string
      string == "" ? newDriver.chatLinkCondition.accept(false) : newDriver.chatLinkCondition.accept(true)
      return .concat([
        .just(.setMatchingInfo(newMatchingInfo)),
        .just(.setDriver(newDriver))
      ])
      
    case .didChangeMbtiTf(let string):
      newMatchingInfo.mbti = string
      return .just(.setMatchingInfo(newMatchingInfo))
      
    case .didChangeWishTv(let string):
      newMatchingInfo.wishText = string
      return .just(.setMatchingInfo(newMatchingInfo))
      
    case .didTapLeftButton:
      switch type {
      case .initial:
        return .concat([
          .just(.setMainVC(true)),
          .just(.setMainVC(false))
        ])
      case .main, .modify:
        newDriver = OnboardingDriver()
        return .concat([
          .just(.setClear(true)),
          .just(.setClear(false)),
          .just(.setDriver(newDriver))
        ])
      }
      
    case .didTapRightButton:
      switch type {
      case .initial, .main:
        let member = ModelTransformationManager.transformToMatchingDTO_RETRIEVE(currentState.currentMatchingInfo)
        return .concat([
          .just(.setOnboardingDetailVC(true, member)),
          .just(.setOnboardingDetailVC(false, member))
        ])
      case .modify:
        return .concat([
          .just(.setLoading(true)),
          APIService.onboardingProvider.rx.request(.modify(currentState.currentMatchingInfo))
            .asObservable()
            .retry()
            .map(ResponseModel<MatchingInfoDTO.Retrieve>.self)
            .flatMap { response -> Observable<Mutation> in
              MemberStorage.shared.saveMatchingInfo(response.data)
              return .concat([
                .just(.setLoading(false)),
                .just(.setRootVC(true)),
                .just(.setRootVC(false))
              ])
            }
        ])
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
    }
    
    return newState
  }
}
