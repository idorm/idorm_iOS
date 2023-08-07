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
    case edit(TeamCalendar)
  }
  
  enum Action {
    case viewDidLoad
    case titleTextFieldDidChange(String)
    case memoTextViewDidChange(String)
    case targetsDidChange([Int])
    case dateDidChange(startDate: String, startTime: String, endDate: String, endTime: String)
    case dateButtonDidTap(isStartDate: Bool)
    case doneButtonDidTap
    case deleteButtonDidTap
  }
  
  enum Mutation {
    case setViewState
    case setTeamMembers
    case setTitle(String)
    case setMemo(String)
    case setTargets([Int])
    case setDate(startDate: String, startTime: String, endDate: String, endTime: String)
    case setCalendarDateSelectionVC(isStartDate: Bool)
    case setPop(Bool)
  }
  
  struct State {
    var viewState: ViewState
    var teamMembers: [TeamMember]
    var isEnabledDoneButon: Bool = false
    var title: String = ""
    var targets: [Int] = []
    var memo: String = ""
    var startDate: String = ""
    var startTime: String = ""
    var endDate: String = ""
    var endTime: String = ""
    var teamCalendarId: Int = 0
    
    @Pulse var isPopping: Bool = false
    @Pulse var presentToCalendarDateSelectionVC: CalendarDateSelectionViewReactor?
  }
  
  // MARK: - Properties
  
  var initialState: State
  private let apiManager = APIManager<CalendarAPI>()
  
  /// `일정 수정` 또는 `일정 생성`에서 필요할 `RequestModel`의 계산프로퍼티 입니다.
  private var teamCalendarRequestModel: TeamCalendarRequestModel {
    let currentState = self.currentState
    return TeamCalendarRequestModel(
      content: currentState.memo,
      endDate: currentState.endDate,
      endTime: currentState.endTime,
      startDate: currentState.startDate,
      startTime: currentState.startTime,
      targets: currentState.targets,
      title: currentState.title,
      teamCalendarId: currentState.teamCalendarId
    )
  }
  
  // MARK: - Initiailizer
  
  /// `CalendarManagementViewReactor`를 초기화 하기 위해서는
  /// 두 가지의 인자가 필요합니다.
  ///
  /// - Parameters:
  ///  - viewState: 이 화면의 분기처리된 상태 값
  init(
    with viewState: ViewState,
    teamMembers: [TeamMember]
  ) {
    self.initialState = State(viewState: viewState, teamMembers: teamMembers)
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      return .concat([
        .just(.setTeamMembers),
        .just(.setViewState)
      ])
      
    case .titleTextFieldDidChange(let title):
      return .just(.setTitle(title))
      
    case .memoTextViewDidChange(let memo):
      return .just(.setMemo(memo))
      
    case .targetsDidChange(let targets):
      return .just(.setTargets(targets))
      
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
        return self.apiManager.requestAPI(to: .postTeamCalendar(self.teamCalendarRequestModel))
          .flatMap { _ in return Observable<Mutation>.just(.setPop(true)) }
      case .edit:
        return self.apiManager.requestAPI(to: .putTeamCalendar(self.teamCalendarRequestModel))
          .flatMap { _ in return Observable<Mutation>.just(.setPop(true)) }
      }
      
    case .deleteButtonDidTap:
      switch self.currentState.viewState {
      case .new:
        return .just(.setPop(true))
      case .edit(let teamCalendar):
        return self.apiManager.requestAPI(
          to: .deleteTeamCalendar(teamCalendarId: teamCalendar.teamCalendarId)
        )
        .flatMap { _ -> Observable<Mutation> in
          return .just(.setPop(true))
        }
      }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setViewState:
      switch state.viewState {
      case .new:
        newState.startDate = Date().toString("yyyy-MM-dd")
        newState.endDate = Date().addingTimeInterval(3600).toString("yyyy-MM-dd")
        newState.startTime = Date().toString("HH:mm:ss")
        newState.endTime = Date().addingTimeInterval(3600).toString("HH:mm:ss")
      case .edit(let teamCalendar):
        newState.title = teamCalendar.title
        newState.memo = teamCalendar.content
        newState.startDate = teamCalendar.startDate
        newState.startTime = teamCalendar.startTime
        newState.endDate = teamCalendar.endDate
        newState.endTime = teamCalendar.endTime
        newState.targets = teamCalendar.targets.map { $0.memberId }
        newState.teamCalendarId = teamCalendar.teamCalendarId
      }
      
    case .setTeamMembers:
      newState.teamMembers = state.teamMembers
      
    case .setTitle(let title):
      newState.title = title
      
    case .setMemo(let memo):
      newState.memo = memo
      
    case .setTargets(let targets):
      newState.targets = targets
      
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
      
      if state.title.isNotEmpty,
         state.startDate.isNotEmpty,
         state.startTime.isNotEmpty,
         state.endTime.isNotEmpty,
         state.endDate.isNotEmpty,
         state.targets.isNotEmpty {
        newState.isEnabledDoneButon = true
      } else {
        newState.isEnabledDoneButon = false
      }
      
      return newState
    }
  }
}
