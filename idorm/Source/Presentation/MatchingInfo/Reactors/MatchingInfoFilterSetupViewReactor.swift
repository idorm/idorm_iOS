//
//  MatchingInfoFilterSetupViewReactor.swift
//  idorm
//
//  Created by 김응철 on 9/25/23.
//

import Foundation

import ReactorKit

final class MatchingInfoFilterSetupViewReactor: Reactor {
  
  enum Action {
    case resetButtonDidTap
    case confirmButtonDidTap
    case buttonDidTap(MatchingInfoSetupSectionItem)
    case sliderDidChange(minValue: Int, maxValue: Int)
  }
  
  enum Mutation {
    case setButton(MatchingInfoSetupSectionItem)
    case setAge(minValue: Int, maxValue: Int)
    case setPopping
  }
  
  struct State {
    var matchingInfoFilter: MatchingInfoFilter
    var items: [[MatchingInfoSetupSectionItem]] = []
    var sections: [MatchingInfoSetupSection] = []
    @Pulse var isPopping: Bool = false
  }
  
  // MARK: - Properties
  
  var initialState: State
  
  // MARK: - Initializer
  
  init() {
    if let matchingInfoFilter = UserStorage.shared.matchingMateFilter.value {
      self.initialState = State(matchingInfoFilter: matchingInfoFilter)
    } else {
      self.initialState = State(matchingInfoFilter: .init(
        dormitory: UserStorage.shared.dormCategory,
        joinPeriod: UserStorage.shared.joinPeriod
      ))
    }
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .buttonDidTap(let item):
      return .just(.setButton(item))
    case let .sliderDidChange(minValue, maxValue):
      return .just(.setAge(minValue: minValue, maxValue: maxValue))
    case .resetButtonDidTap:
      // 필터 초기화
      UserStorage.shared.matchingMateFilter.accept(nil)
      return .just(.setPopping)
    case .confirmButtonDidTap:
      UserStorage.shared.matchingMateFilter.accept(self.currentState.matchingInfoFilter)
      return .just(.setPopping)
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setButton(let item):
      switch item {
      case let .dormitory(dormitory, _):
        newState.matchingInfoFilter.dormitory = dormitory
      case let .period(joinPeriod, _):
        newState.matchingInfoFilter.joinPeriod = joinPeriod
      case let .habit(habit, isSelected):
        switch habit {
        case .snoring:
          newState.matchingInfoFilter.isSnoring = !isSelected
        case .grinding:
          newState.matchingInfoFilter.isGrinding = !isSelected
        case .smoking:
          newState.matchingInfoFilter.isSmoking = !isSelected
        case .allowedFood:
          newState.matchingInfoFilter.isAllowedFood = !isSelected
        case .allowedEarphone:
          newState.matchingInfoFilter.isAllowedEarphones = !isSelected
        }
      default: break
      }
    case let .setAge(minValue, maxValue):
      newState.matchingInfoFilter.minAge = minValue
      newState.matchingInfoFilter.maxAge = maxValue
    case .setPopping:
      newState.isPopping = true
    }
    
    return newState
  }
  
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      
      newState.sections =
      [
        .dormitory(isFilterSetupVC: true),
        .period,
        .habit(isFilterSetupVC: true),
        .age(isFilterSetupVC: true)
      ]
      
      newState.items =
      [
        Dormitory.allCases.map {          
          .dormitory($0, isSelected: $0 == state.matchingInfoFilter.dormitory)
        },
        JoinPeriod.allCases.map {
          .period($0, isSelected: $0 == state.matchingInfoFilter.joinPeriod)
        },
        [
          .habit(.snoring, isSelected: state.matchingInfoFilter.isSnoring),
          .habit(.grinding, isSelected: state.matchingInfoFilter.isGrinding),
          .habit(.smoking, isSelected: state.matchingInfoFilter.isSmoking),
          .habit(.allowedFood, isSelected: state.matchingInfoFilter.isAllowedFood),
          .habit(.allowedEarphone, isSelected: state.matchingInfoFilter.isAllowedEarphones)
        ],
        [.age]
      ]
      
      return newState
    }
  }
}
