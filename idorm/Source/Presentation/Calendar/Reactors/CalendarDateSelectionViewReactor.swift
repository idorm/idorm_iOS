//
//  CalendarDateSelectionViewReactor.swift
//  idorm
//
//  Created by 김응철 on 8/3/23.
//

import Foundation

import ReactorKit

final class CalendarDateSelectionViewReactor: Reactor {
  
  enum Action {
    case viewDidAppear
    case tabButtonDidTap(isStartDate: Bool)
    case doneButtonDidTap
    case calendarDidSelect(String)
    case pickerViewDidChangeRow(String)
  }
  
  enum Mutation {
    case setStartDate(Bool)
    case setDate(String)
    case setTime(String)
    case setScrollCollectionView(Int)
    case setDismissing
  }
  
  struct State {
    var isStartDate: Bool
    var startDate: String
    var startTime: String
    var endDate: String
    var endTime: String
    
    // UI
    var scrollCollectionView: Int = 0
    var items: [[String]] = []
    @Pulse var isDismissing: (
      startDate: String,
      startTime: String,
      endDate: String,
      endTime: String
    )?
  }
  
  // MARK: - Properties
  
  var initialState: State
  
  // MARK: - Initializer
  
  init(
    isStartDate: Bool,
    startDate: String,
    startTime: String,
    endDate: String,
    endTime: String
  ) {
    self.initialState = State(
      isStartDate: isStartDate,
      startDate: startDate,
      startTime: startTime,
      endDate: endDate,
      endTime: endTime
    )
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidAppear:
      return .just(.setScrollCollectionView(self.currentState.isStartDate ? 0 : 1))
      
    case .tabButtonDidTap(let isStartDate):
      return .concat([
        .just(.setStartDate(isStartDate)),
        .just(.setScrollCollectionView(isStartDate ? 0 : 1))
      ])
      
    case .calendarDidSelect(let dateString):
      return .just(.setDate(dateString))
      
    case .pickerViewDidChangeRow(let timeString):
      return .just(.setTime(timeString))
      
    case .doneButtonDidTap:
      return .just(.setDismissing)
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setStartDate(let isStartDate):
      newState.isStartDate = isStartDate
      
    case .setDate(let dateString):
      if state.isStartDate {
        newState.startDate = dateString
      } else {
        newState.endDate = dateString
      }
      
    case .setTime(let timeString):
      if state.isStartDate {
        newState.startTime = timeString
      } else {
        newState.endTime = timeString
      }
      
    case .setScrollCollectionView(let indexPath):
      newState.scrollCollectionView = indexPath
      
    case .setDismissing:
      newState.isDismissing = (state.startDate, state.startTime, state.endDate, state.endTime)
    }
    
    return newState
  }
  
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      
      newState.items.append([state.startDate, state.startTime])
      newState.items.append([state.endDate, state.endTime])
      
      return newState
    }
  }
}

// MARK: - Privates

private extension CalendarDateSelectionViewReactor {
  
}
