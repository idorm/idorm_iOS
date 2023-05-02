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
    case didTapResetButton
    case didTapConfirmButton
    case didTapDormButton(Dormitory)
    case didTapJoinPeriodButton(JoinPeriod)
    case didTapHabitButton(Habit)
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
  }
  
  let initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    var newFilter = FilterStorage.shared.filter
    
    switch action {
    case .didTapResetButton:
      FilterStorage.shared.resetFilter()
      FilterDriver.shared.reset()
      return .concat([
        .just(.setRequestCard),
        .just(.setPopVC)
      ])
      
    case .didTapConfirmButton:
      return Observable.concat([
        Observable.just(.setRequestCard),
        Observable.just(.setPopVC)
      ])
      
    case .didTapDormButton(let dorm):
      FilterDriver.shared.dorm.accept(true)
      newFilter.dormCategory = dorm
      return Observable.just(.setFilter(newFilter))

    case .didTapJoinPeriodButton(let period):
      FilterDriver.shared.joinPeriod.accept(true)
      newFilter.joinPeriod = period
      return Observable.just(.setFilter(newFilter))
      
    case .didTapHabitButton(let habit):
      switch habit {
      case .snoring:
        newFilter.isSnoring = !newFilter.isSnoring
      case .smoking:
        newFilter.isSmoking = !newFilter.isSmoking
      case .grinding:
        newFilter.isGrinding = !newFilter.isGrinding
      case .allowedEarphone:
        newFilter.isWearEarphones = !newFilter.isWearEarphones
      case .allowedFood:
        newFilter.isAllowedFood = !newFilter.isAllowedFood
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
      FilterStorage.shared.saveFilter(newFilter)
    }
    
    return newState
  }
}
