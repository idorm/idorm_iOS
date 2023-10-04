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
    var teamCalendar: TeamCalendar
    var scrollCollectionView: Int = 0
    var items: [[String]] = []
    @Pulse var isDismissing: Bool = false
  }
  
  // MARK: - Properties
  
  var initialState: State
  var dismissCompletion: ((TeamCalendar) -> Void)?
  
  // MARK: - Initializer
  
  init(isStartDate: Bool, teamCalendar: TeamCalendar) {
    self.initialState = State(isStartDate: isStartDate, teamCalendar: teamCalendar)
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
    case .calendarDidSelect(let date):
      return .just(.setDate(date))
    case .pickerViewDidChangeRow(let time):
      return .just(.setTime(time))
    case .doneButtonDidTap:
      return .just(.setDismissing)
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setStartDate(let isStartDate):
      newState.isStartDate = isStartDate
    case .setDate(let date):
      if state.isStartDate {
        newState.teamCalendar.startDate = date
      } else {
        newState.teamCalendar.endDate = date
      }
    case .setTime(let time):
      if state.isStartDate {
        newState.teamCalendar.startTime = time
      } else {
        newState.teamCalendar.endTime = time
      }
    case .setScrollCollectionView(let indexPath):
      newState.scrollCollectionView = indexPath
    case .setDismissing:
      newState.isDismissing = true
      self.dismissCompletion?(newState.teamCalendar)
    }
    
    return newState
  }
  
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      var teamCalendar = state.teamCalendar
      
      newState.items.append([teamCalendar.startDate, teamCalendar.startTime])
      newState.items.append([teamCalendar.endDate, teamCalendar.endTime])
      
      return newState
    }
  }
}
