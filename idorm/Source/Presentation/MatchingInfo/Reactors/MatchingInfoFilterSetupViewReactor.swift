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
  }
  
  enum Mutation {
    
  }
  
  struct State {
    var matchingInfoFilter: MatchingInfoFilter
    var items: [[MatchingInfoSetupSectionItem]] = []
    var sections: [MatchingInfoSetupSection] = []
  }
  
  // MARK: - Properties
  
  var initialState: State
  
  // MARK: - Initializer
  
  init() {
    if let matchingInfoFilter = UserStorage.shared.matchingMateFilter {
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
      
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
      
    }
    
    return newState
  }
  
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      
      newState.items =
      [
        Dormitory.allCases.map {
          .dormitory($0, isSelected: $0 == state.filterRequestDTO?.dormCategory)
        },
        JoinPeriod.allCases.map {
          .period($0, isSelected: $0 == state.filterRequestDTO?.joinPeriod)
        },
        [
          .habit(.snoring, isSelected: state.filterRequestDTO?.isSnoring ?? false)
        ]
      ]
      
      return newState
    }
  }
}
