//
//  CalendarManagementViewReactor.swift
//  idorm
//
//  Created by 김응철 on 7/27/23.
//

import Foundation

import ReactorKit

final class CalendarManagementViewReactor: Reactor {
  
  /// `CalenadrManagementVC`에는
  /// `새로운 일정 등록`과 `일정 수정`이 있습니다.
  enum ViewState: Equatable {
    case new
    case edit
  }
  
  enum Action {
    case titleTextFieldDidChange(String)
    case memoTextViewDidChange(String)
    case membersDidChange([TeamMember])
    case dateDidChange(startDate: String, startTime: String, endDate: String, endTime: String)
    case dateButtonDidTap(isStartDate: Bool)
    case doneButtonDidTap
    case deleteButtonDidTap
  }
  
  enum Mutation {
    case setTitle(String)
    case setContent(String)
    case setMembers([TeamMember])
    case setDate(startDate: String, startTime: String, endDate: String, endTime: String)
    case setCalendarDateSelectionVC(isStartDate: Bool)
    case setPop(Bool)
  }
  
  struct State {
    var teamCalendar: TeamCalendar
    var viewState: ViewState
    var isEnabledDoneButon: Bool = false
    @Pulse var isPopping: Bool = false
    @Pulse var presentToCalendarDateSelectionVC: CalendarDateSelectionViewReactor?
  }
  
  // MARK: - Properties
  
  var initialState: State
  private let apiManager = NetworkService<CalendarAPI>()
  
  // MARK: - Initiailizer
  
  init(with viewState: ViewState, teamCalendar: TeamCalendar) {
    self.initialState = State(teamCalendar: teamCalendar, viewState: viewState)
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .titleTextFieldDidChange(let title):
      return .just(.setTitle(title))
    case .memoTextViewDidChange(let memo):
      return .just(.setContent(memo))
    case .membersDidChange(let members):
      return .just(.setMembers(members))
    case .dateButtonDidTap(let isStartDate):
      return .just(.setCalendarDateSelectionVC(isStartDate: isStartDate))
    case let .dateDidChange(startDate, startTime, endDate, endTime):
      return .just(.setDate(
        startDate: startDate,
        startTime: startTime,
        endDate: endDate,
        endTime: endTime
      ))
    case .doneButtonDidTap:
      switch self.currentState.viewState {
      case .new:
        return self.apiManager.requestAPI(
          to: .createTeamCalendar(TeamCalendarRequestDTO(self.currentState.teamCalendar))
        ).flatMap { _ in return Observable<Mutation>.just(.setPop(true)) }
      case .edit:
        return self.apiManager.requestAPI(
          to: .updateTeamCalendar(TeamCalendarRequestDTO(self.currentState.teamCalendar))
        ).flatMap { _ in return Observable<Mutation>.just(.setPop(true)) }
      }
    case .deleteButtonDidTap:
      switch self.currentState.viewState {
      case .new:
        return .just(.setPop(true))
      case .edit:
        return self.apiManager.requestAPI(
          to: .deleteTeamCalendar(teamCalendarId: self.currentState.teamCalendar.identifier)
        ).flatMap { _ -> Observable<Mutation> in return .just(.setPop(true)) }
      }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setTitle(let title):
      newState.teamCalendar.title = title
    case .setContent(let content):
      newState.teamCalendar.content = content
    case .setMembers(let members):
      newState.teamCalendar.members = members
    case .setCalendarDateSelectionVC(let isStartDate):
      newState.presentToCalendarDateSelectionVC = CalendarDateSelectionViewReactor(
        isStartDate: isStartDate,
        startDate: state.startDate,
        startTime: state.startTime,
        endDate: state.endDate,
        endTime: state.endTime
      )
    case let .setDate(startDate, startTime, endDate, endTime):
      newState.startDate = startDate
      newState.startTime = startTime
      newState.endDate = endDate
      newState.endTime = endTime
    case .setPop(let isPopping):
      newState.isPopping = isPopping
    }
    
    return newState
  }
  
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      
      var teamCalendar = state.teamCalendar
      
      if teamCalendar.title.isNotEmpty,
         teamCalendar.startDate.isNotEmpty,
         teamCalendar.startTime.isNotEmpty,
         teamCalendar.endTime.isNotEmpty,
         teamCalendar.endDate.isNotEmpty,
         teamCalendar.members.isNotEmpty {
        newState.isEnabledDoneButon = true
      } else {
        newState.isEnabledDoneButon = false
      }
      
      teamCalendar.startDate = teamCalendar.startDate.toDateString(from: "M월 d일", to: "MM월 dd일 (E)")
      teamCalendar.endDate = teamCalendar.endDate.toDateString(from: "M월 d일", to: "MM월 dd일 (E)")
      teamCalendar.startTime = teamCalendar.startTime.toDateString(from: "a h:mm", to: "a h시~")
      teamCalendar.endTime = teamCalendar.endTime.toDateString(from: "a h:mm", to: "a h시~")
      
      newState.teamCalendar = teamCalendar
      
      return newState
    }
  }
}
