//
//  CalendarSleepoverListViewReactor.swift
//  idorm
//
//  Created by 김응철 on 8/21/23.
//

import UIKit

import ReactorKit

final class CalendarSleepoverListViewReactor: Reactor {
  
  enum Action {
    case itemSelected(CalendarSleepoverListSectionItem)
    case didTapRemoveCalendarButton
    case doNoting
  }
  
  enum Mutation {
    case setCalendarSleepoverManagementVC(TeamCalendar)
    case setTeamCalendars([TeamCalendar])
    case setEditing(Bool)
  }
  
  struct State {
    var isEditing: Bool = false
    var yearMonth: String
    var memberID: Int
    var teamCalendars: [TeamCalendar]
    var sections: [CalendarSleepoverListSection] = []
    var items: [CalendarSleepoverListSectionItem] = []
    @Pulse var navigateToCalendarSleepoverManagementVC: TeamCalendar = .init()
  }
  
  // MARK: - Properties
  
  var initialState: State
  private let calendarService = NetworkService<CalendarAPI>()
  
  var isMyOwnCalendars: Bool {
    return UserStorage.shared.member?.identifier ?? 0 == self.currentState.memberID
  }
  
  // MARK: - initializer
  
  init(
    _ teamCalendars: [TeamCalendar],
    yearMonth: String,
    memberID: Int
  ) {
    self.initialState = State(
      yearMonth: yearMonth,
      memberID: memberID,
      teamCalendars: teamCalendars
    )
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .itemSelected(let item):
      switch item {
      case let .sleepover(calendar, isEditing, isMyOwnCalendar):
        if isEditing {
          return calendarService.requestAPI(
            to: .deleteTeamCalendar(teamCalendarId: calendar.identifier)
          ).flatMap { _ in self.requestSleepoverCalendars() }
        } else {
          if isMyOwnCalendar {
            return .just(.setCalendarSleepoverManagementVC(calendar))
          } else {
            return .empty()
          }
        }
      }
      
    case .didTapRemoveCalendarButton:
      return .just(.setEditing(!self.currentState.isEditing))
      
    case .doNoting:
      return .empty()
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case let .setCalendarSleepoverManagementVC(teamCalendar):
      newState.navigateToCalendarSleepoverManagementVC = teamCalendar
      
    case let .setEditing(isEditing):
      newState.isEditing = isEditing
      
    case .setTeamCalendars(let teamCalendars):
      newState.teamCalendars = teamCalendars
    }
    
    return newState
  }
  
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      
      newState.sections.append(.sleepover(canEdit: self.isMyOwnCalendars))
      newState.items.append(
        contentsOf: state.teamCalendars.map {
          CalendarSleepoverListSectionItem.sleepover(
            calendar: $0,
            isEditing: state.isEditing,
            isMyOwnCalendar: self.isMyOwnCalendars
          )
        }
      )
      
      return newState
    }
  }
}

// MARK: - Privates

private extension CalendarSleepoverListViewReactor {
  func requestSleepoverCalendars() -> Observable<Mutation> {
    return self.calendarService.requestAPI(to: .postSleepoverCalendars(
      memberID: self.currentState.memberID,
      yearMonth: self.currentState.yearMonth
    ))
    .map(ResponseDTO<[TeamCalendarSleepoverResponseDTO]>.self)
    .flatMap {
      return Observable<Mutation>.just(.setTeamCalendars($0.data.map { TeamCalendar($0) }))
    }
  }
}
