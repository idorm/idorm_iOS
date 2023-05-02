//
//  MatchingFilterViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2022/12/19.
//

import RxSwift
import RxCocoa
import ReactorKit

final class MatchingFilterViewReactor: Reactor {
  
  enum Action {
    case viewDidLoad
    case didTapResetButton
    case didTapConfirmButton
    case didTapDormButton(Dormitory)
    case didTapJoinPeriodButton(JoinPeriod)
    case didTapHabitButton(Habit, Bool)
    case didChangeSlider(minValue: Int, maxValue: Int)
  }
  
  enum Mutation {
    case setPopVC
    case setRequestCard
    case setFilter(MatchingRequestModel.Filter)
  }
  
  struct State {
    var popVC: Bool = false
    var requestCard: Bool = false
    var currentFilter: MatchingRequestModel.Filter = .init()
    var isAllowedConfirmBtn: Bool = false
  }
  
  let initialState: State = State()
  var filterDriver = FilterDriver()
  
  func mutate(action: Action) -> Observable<Mutation> {
    var newFilter = currentState.currentFilter
    
    switch action {
    case .viewDidLoad:
      if FilterStorage.shared.hasFilter {
        filterDriver.dorm.accept(true)
        filterDriver.joinPeriod.accept(true)
        
        let currentFilter = FilterStorage.shared.filter
        return .just(.setFilter(currentFilter))
      } else {
        
        return .empty()
      }
      
    case .didTapResetButton:
      FilterStorage.shared.hasFilter = false
      FilterStorage.shared.resetFilter()
      
      return .concat([
        .just(.setRequestCard),
        .just(.setPopVC)
      ])
      
    case .didTapConfirmButton:
      FilterStorage.shared.hasFilter = true
      FilterStorage.shared.saveFilter(currentState.currentFilter)
      
      return Observable.concat([
        .just(.setRequestCard),
        .just(.setPopVC)
      ])
      
    case .didTapDormButton(let dorm):
      newFilter.dormCategory = dorm
      return Observable.just(.setFilter(newFilter))

    case .didTapJoinPeriodButton(let period):
      filterDriver.joinPeriod.accept(true)
      newFilter.joinPeriod = period
      return .just(.setFilter(newFilter))
      
    case let .didTapHabitButton(habit, state):
      switch habit {
      case .snoring:
        newFilter.isSnoring = state
      case .smoking:
        newFilter.isSmoking = state
      case .grinding:
        newFilter.isGrinding = state
      case .allowedEarphone:
        newFilter.isWearEarphones = state
      case .allowedFood:
        newFilter.isAllowedFood = state
      }
      return Observable.just(.setFilter(newFilter))
      
    case let .didChangeSlider(minValue, maxValue):
      newFilter.minAge = minValue
      newFilter.maxAge = maxValue
      return Observable.just(.setFilter(newFilter))
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setPopVC:
      newState.popVC = true
      
    case .setRequestCard:
      newState.requestCard = true
      
    case .setFilter(let newFilter):
      newState.currentFilter = newFilter
    }
    
    return newState
  }
}
