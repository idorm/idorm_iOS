//
//  CalendarViewReactor.swift
//  idorm
//
//  Created by 김응철 on 7/11/23.
//

import UIKit
import OSLog

import ReactorKit

final class CalendarViewReactor: Reactor {
  
  enum Action {
    case requestAllData
    case currentDateDidChange(String)
    case itemSelected(CalendarSectionItem)
    case registerScheduleButtonDidTap
    case exitCalendarButtonDidTap
  }
  
  enum Mutation {
    case setTeamMembers(TeamMembers)
    case setTeamCalendars([TeamCalendars])
    case setDormCalendars([DormCalendar])
    case setCurrentDate(String)
    case setCalendarManagementVC(TeamCalendar?)
  }
  
  struct State {
    var teamId: Int = 0
    var isNeedToConfirmDeleted: Bool = false
    var currentDate: String = Date().toString("yyyy-MM")
    var members: [TeamMember] = []
    var teamCalendars: [TeamCalendars] = []
    var dormCalendars: [DormCalendar] = []
    var sections: [CalendarSection] = []
    var items: [[CalendarSectionItem]] = []
    @Pulse var navigateToCalendarMaanagementVC: ((CalendarManagementViewReactor.ViewState, [TeamMember])) = (.new, [])
  }
  
  // MARK: - Properties
  
  var initialState: State = State()
  private let apiManager = APIManager<CalendarAPI>()
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .requestAllData:
      return self.requestGetTeamMembers()
      
    case .currentDateDidChange(let dateString):
      if dateString.elementsEqual(self.currentState.currentDate) {
        // 중복된 호출을 줄입니다.
        return .empty()
      } else {
        return .concat([
          .just(.setCurrentDate(dateString)),
          self.requestGetTeamMembers()
        ])
      }
      
    case .itemSelected(let item):
      switch item {
      case .teamCalendar(let teamCalendars):
        return self.requestTeamCalendar(with: teamCalendars.teamCalendarId)
        
      case .dormCalendar(let dormCalendar):
        // 브라우저에서 해당 URL로 이동합니다.
        guard let urlString = dormCalendar.url,
              let url = URL(string: urlString)
        else {
          os_log(.info, "🔗 해당 기숙사 공식 일정의 URL이 존재하지 않습니다!")
          return .empty()
        }
        UIApplication.shared.open(url)
        return .empty()
      default:
        return .empty()
      }
      
    case .registerScheduleButtonDidTap: // 일정 등록 버튼 클릭
      return .just(.setCalendarManagementVC(nil))

    case .exitCalendarButtonDidTap:
      return self.apiManager.requestAPI(to: .deleteTeam)
        .flatMap { _ in return self.requestGetTeamMembers() }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setTeamMembers(let teamMembers):
      newState.isNeedToConfirmDeleted = teamMembers.isNeedToConfirmDeleted
      newState.teamId = teamMembers.teamId
      newState.members = teamMembers.members
      
    case .setTeamCalendars(let teamCalendars):
      newState.teamCalendars = teamCalendars
      
    case .setDormCalendars(let dormCalendars):
      newState.dormCalendars = dormCalendars
      
    case .setCurrentDate(let dateString):
      newState.currentDate = dateString
      
    case .setCalendarManagementVC(let teamCalendar):
      if let teamCalendar {
        newState.navigateToCalendarMaanagementVC = (.edit(teamCalendar), state.members)
      } else {
        newState.navigateToCalendarMaanagementVC = (.new, state.members)
      }
    }
    
    return newState
  }
  
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      
      // TeamMember
      newState.items.append(state.members.map { CalendarSectionItem.teamMember($0) })
      newState.sections.append(.teamMembers(state.members))
      
      // Calendar
      newState.sections.append(.calendar(
        teamCalenars: state.teamCalendars,
        dormCalendars: state.dormCalendars
      ))
      newState.items.append([])
      
      // TeamCalendar
      if state.teamCalendars.isNotEmpty {
        newState.sections.append(.teamCalendar)
        newState.items.append(state.teamCalendars.map { CalendarSectionItem.teamCalendar($0) })
      }

      // DormCalendar
      newState.sections.append(.dormCalendar)
      if state.dormCalendars.isNotEmpty {
        newState.items.append(state.dormCalendars.map { CalendarSectionItem.dormCalendar($0) })
      } else {
        newState.items.append([.dormEmpty])
      }
      
      return newState
    }
  }
}
// MARK: - Privates

private extension CalendarViewReactor {
  /// 팀원들의 정보를 조회합니다.
  func requestGetTeamMembers() -> Observable<Mutation> {
    self.apiManager.requestAPI(to: .getTeamMembers)
      .map(ResponseModel<TeamMembers>.self)
      .flatMap { response -> Observable<Mutation> in
        return .concat([
          .just(.setTeamMembers(response.data)),
          self.requestDormCalendars()
        ])
      }
  }
  
  /// 기숙사 공식 월별 일정을 조회합니다.
  func requestDormCalendars() -> Observable<Mutation> {
    self.apiManager.requestAPI(to: .postDormCalendars(yearMonth: self.currentState.currentDate))
      .map(ResponseModel<[DormCalendar]>.self)
      .flatMap { response -> Observable<Mutation> in
        return .concat([
          .just(.setDormCalendars(response.data)),
          self.requestTeamCalendars()
        ])
      }
  }
  
  /// 공유 캘린더의 월별 일정을 조회합니다.
  func requestTeamCalendars() -> Observable<Mutation> {
    guard !(self.currentState.teamId == -999) else { return .empty() }
    return self.apiManager.requestAPI(to: .postTeamCalendars(yearMonth: self.currentState.currentDate))
      .map(ResponseModel<[TeamCalendars]>.self)
      .flatMap { response -> Observable<Mutation> in
        return .just(.setTeamCalendars(response.data))
      }
  }
  
  /// 공유 캘린더의 단건 일정을 조회합니다.
  /// `CalendarManagement`로 가기위한 과정 중 하나입니다.
  func requestTeamCalendar(with teamCalendarId: Int) -> Observable<Mutation> {
    return self.apiManager.requestAPI(to: .getTeamCalendar(teamCalendarId: teamCalendarId))
      .map(ResponseModel<TeamCalendar>.self)
      .flatMap { response -> Observable<Mutation> in
        return .just(.setCalendarManagementVC(response.data))
      }
  }
}
