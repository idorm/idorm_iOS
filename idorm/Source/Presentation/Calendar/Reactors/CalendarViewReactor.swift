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
    case nothing
    case requestAllData
    case currentDateDidChange(String)
    case itemSelected(CalendarSectionItem)
    case registerScheduleButtonDidTap
    case exitCalendarButtonDidTap
    case manageFriendButtonDidTap
    case manageCalendarButtonDidTap
    case shareCalendarButtonDidTap
    case doneButtonDidTap
    case removeTeamMember(memberID: Int)
    case removeTeamCalendar(teamCalendarID: Int)
  }
  
  enum Mutation {
    case setTeamMembers(TeamCalendarMemberResponseDTO)
    case setTeamCalendars([TeamCalendar])
    case setDormCalendars([DormCalendar])
    case setCurrentDate(String)
    case setCalendarManagementVC(TeamCalendar?)
    case setCalendarSleepoverListVC([TeamCalendar], memberID: Int)
    case setEditingMode(isMemberSection: Bool?)
  }
  
  struct State {
    var teamId: Int = 0
    var isNeedToConfirmDeleted: Bool = false
    var isEditingMemberSection: Bool = false
    var isEditingTeamCalendarSection: Bool = false
    var currentDate: String = Date().toString("yyyy-MM")
    var members: [TeamMember] = []
    var teamCalendars: [TeamCalendar] = []
    var dormCalendars: [DormCalendar] = []
    var sections: [CalendarSection] = []
    var items: [[CalendarSectionItem]] = []
    
    // Presentation
    @Pulse var navigateToCalendarManagementVC: (
      (CalendarManagementViewReactor.ViewState, [TeamMember])
    ) = (.new, [])
    @Pulse var presentToCalendarSleepoverListVC: (
      teamCalendars: [TeamCalendar],
      yearMonth: String,
      memberID: Int
    )?
  }
  
  // MARK: - Properties
  
  var initialState: State = State()
  private let apiManager = NetworkService<CalendarAPI>()
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .nothing:
      return .empty()
      
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
      case let .teamMember(teamMember, _):
        let memberID = teamMember.identifier
        let yearMonth = self.currentState.currentDate
        return self.apiManager.requestAPI(to: .getSleepoverCalendars(memberID: memberID, yearMonth: yearMonth))
          .map(ResponseDTO<[TeamCalendarSleepoverResponseDTO]>.self)
          .flatMap {
            let teamCalendars = $0.data.map { TeamCalendar($0) }
            return Observable<Mutation>.just(.setCalendarSleepoverListVC(teamCalendars, memberID: memberID))
          }
      case let .teamCalendar(teamCalendar, isEditing):
        if !isEditing { return self.requestTeamCalendar(with: teamCalendar.identifier) }
        return .empty()
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
      
    case .manageFriendButtonDidTap:
      if self.currentState.teamId < 0 { return .empty() }
      return .just(.setEditingMode(isMemberSection: true))
      
    case .manageCalendarButtonDidTap:
      if self.currentState.teamCalendars.isEmpty { return .empty() }
      return .just(.setEditingMode(isMemberSection: false))
      
    case .doneButtonDidTap:
      return .just(.setEditingMode(isMemberSection: nil))
      
    case .removeTeamMember(let memberID):
      return self.apiManager.requestAPI(to: .deleteTeamMember(memberID: memberID))
        .flatMap { _ in return self.requestGetTeamMembers() }
      
    case .removeTeamCalendar(let teamCalendarID):
      return self.apiManager.requestAPI(to: .deleteTeamCalendar(teamCalendarId: teamCalendarID))
        .flatMap { _ in return self.requestGetTeamMembers() }
      
    case .shareCalendarButtonDidTap:
      let profileURL = UserStorage.shared.member?.profilePhotoURL
      let nickNM = UserStorage.shared.member?.nickname
      KakaoShareManager.shared.inviteTeamCalendar(
        profileURL: profileURL,
        nickname: nickNM!,
        inviter: self.currentState.teamId
      )
      return .empty()
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setTeamMembers(let teamMembers):
      newState.isNeedToConfirmDeleted = teamMembers.isNeedToConfirmDeleted
      newState.teamId = teamMembers.teamId
      newState.members = teamMembers.members.map { TeamMember($0) }
    case .setTeamCalendars(let teamCalendars):
      newState.teamCalendars = teamCalendars
    case .setDormCalendars(let dormCalendars):
      newState.dormCalendars = dormCalendars
    case .setCurrentDate(let dateString):
      newState.currentDate = dateString
    case .setCalendarManagementVC(let teamCalendar):
      if let teamCalendar {
        newState.navigateToCalendarManagementVC = (.edit(teamCalendar), state.members)
      } else {
        newState.navigateToCalendarManagementVC = (.new, state.members)
      }
    case .setEditingMode(let isMemberSection):
      if isMemberSection == nil {
        newState.isEditingMemberSection = false
        newState.isEditingTeamCalendarSection = false
      } else {
        newState.isEditingMemberSection = isMemberSection!
        newState.isEditingTeamCalendarSection = !isMemberSection!
      }
      
    case let .setCalendarSleepoverListVC(teamCalendars, memberID):
      newState.presentToCalendarSleepoverListVC = (teamCalendars, state.currentDate, memberID)
    }
    
    return newState
  }
  
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      
      // TeamMember
      newState.items.append(state.members.map {
        CalendarSectionItem.teamMember($0, isEditing: state.isEditingMemberSection)
      })
      let isEditingMode = state.isEditingMemberSection || state.isEditingTeamCalendarSection
      newState.sections.append(
        .teamMembers(state.members, isEditing: isEditingMode)
      )
      
      // Calendar
      newState.sections.append(.calendar(
        teamCalenars: state.teamCalendars,
        dormCalendars: state.dormCalendars
      ))
      newState.items.append([])
      
      // TeamCalendar
      if state.teamCalendars.isNotEmpty {
        newState.sections.append(.teamCalendar)
        newState.items.append(state.teamCalendars.map {
          CalendarSectionItem.teamCalendar($0, isEditing: state.isEditingTeamCalendarSection)
        })
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
      .map(ResponseDTO<TeamCalendarMemberResponseDTO>.self)
      .flatMap { response -> Observable<Mutation> in
        return .concat([
          .just(.setTeamMembers(response.data)),
          self.requestDormCalendars()
        ])
      }
  }
  
  /// 기숙사 공식 월별 일정을 조회합니다.
  func requestDormCalendars() -> Observable<Mutation> {
    self.apiManager.requestAPI(to: .getDormCalendars(yearMonth: self.currentState.currentDate))
      .map(ResponseDTO<[DormCalendarResponseDTO]>.self)
      .flatMap { response -> Observable<Mutation> in
        return .concat([
          .just(.setDormCalendars(response.data.map { DormCalendar($0) })),
          self.requestTeamCalendars()
        ])
      }
  }
  
  /// 공유 캘린더의 월별 일정을 조회합니다.
  func requestTeamCalendars() -> Observable<Mutation> {
    guard !(self.currentState.teamId == -999) else { return .empty() }
    return self.apiManager.requestAPI(to: .getTeamCalendars(yearMonth: self.currentState.currentDate))
      .map(ResponseDTO<[TeamCalendarResponseDTO]>.self)
      .flatMap { response -> Observable<Mutation> in
        return .just(.setTeamCalendars(response.data.map { TeamCalendar($0) }))
      }
  }
  
  /// 공유 캘린더의 단건 일정을 조회합니다.
  /// `CalendarManagement`로 가기위한 과정 중 하나입니다.
  func requestTeamCalendar(with teamCalendarId: Int) -> Observable<Mutation> {
    return self.apiManager.requestAPI(to: .getTeamCalendar(teamCalendarId: teamCalendarId))
      .map(ResponseDTO<TeamCalendarSingleResponseDTO>.self)
      .flatMap { response -> Observable<Mutation> in
        return .just(.setCalendarManagementVC(TeamCalendar(response.data)))
      }
  }
}
