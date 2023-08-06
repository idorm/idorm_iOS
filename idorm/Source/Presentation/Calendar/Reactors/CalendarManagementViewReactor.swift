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
    case dateButtonDidTap(isStartDate: Bool)
  }
  
  enum Mutation {
    case setViewState
    case setTeamMembers
    case setTitle(String)
    case setMemo(String)
    case setTargets([Int])
    case setCalendarDateSelectionVC(isStartDate: Bool)
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
    
    @Pulse var presentToCalendarDateSelectionVC: CalendarDateSelectionViewReactor?
  }
  
  // MARK: - Properties
  
  var initialState: State
  
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
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setViewState:
      switch state.viewState {
      case .new:
        newState.startDate = Date().toString("yyyy-MM-dd")
        newState.endDate = Date().toString("yyyy-MM-dd")
        newState.startTime = Date().toString("HH:mm:ss")
        newState.endTime = Date().toString("HH:mm:ss")
      case .edit(let teamCalendar):
        newState.title = teamCalendar.title
        newState.memo = teamCalendar.content
        newState.startDate = teamCalendar.startDate
        newState.startTime = teamCalendar.startTime
        newState.endDate = teamCalendar.endDate
        newState.endTime = teamCalendar.endTime
        newState.targets = teamCalendar.targets.map { $0.memberId }
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
