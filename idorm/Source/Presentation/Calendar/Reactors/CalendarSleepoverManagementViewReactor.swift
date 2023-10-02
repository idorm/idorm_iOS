//
//  CalendarSleepoverManagementViewReactor.swift
//  idorm
//
//  Created by 김응철 on 8/16/23.
//

import Foundation

import ReactorKit

final class CalendarSleepoverManagementViewReactor: Reactor {
  
  enum ViewType {
    case new
    case edit(TeamCalendar)
  }
  
  enum Action {
    case startButtonDidTap
    case endButtonDidTap
    case doneButtonDidTap
    case calendarDidSelect(date: String)
  }
  
  enum Mutation {
    case setStartDate(Bool)
    case setDate(String)
    case setPopping(Bool)
  }
  
  struct State {
    var teamCalendar: TeamCalendar = .init()
    var isStartDate: Bool = true
    /// `시작 날짜`, `종료 날짜`
    var items: [String] = []
    @Pulse var isPopping: Bool = false
  }
  
  // MARK: - Properties
  
  var initialState: State = State()
  private let apiManager = NetworkService<CalendarAPI>()
  
  // MARK: - Initializer
  
  init(_ viewType: ViewType) {
    if case .edit(let teamCalendar) = viewType {
      self.initialState = State(teamCalendar: teamCalendar)
    }
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .startButtonDidTap:
      return .just(.setStartDate(true))
      
    case .endButtonDidTap:
      return .just(.setStartDate(false))
      
    case .doneButtonDidTap:
      let teamCalendar = self.currentState.teamCalendar
      let startDate = teamCalendar.startDate
      let endDate = teamCalendar.endDate
      return self.apiManager.requestAPI(
        to: .createSleepoverCalendar(startDate: startDate, endDate: endDate)
      ).flatMap { _ in return Observable<Mutation>.just(.setPopping(true)) }
      
    case .calendarDidSelect(let date):
      return .just(.setDate(date))
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
      
    case .setPopping(let isPopping):
      newState.isPopping = isPopping
    }
    
    return newState
  }
  
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      
      var items: [String] = []
      items.append(state.teamCalendar.startDate)
      items.append(state.teamCalendar.endDate)
      newState.items = items
      
      return newState
    }
  }
}
