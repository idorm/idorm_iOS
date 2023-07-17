//
//  CalendarViewReactor.swift
//  idorm
//
//  Created by 김응철 on 7/11/23.
//

import ReactorKit

final class CalendarViewReactor: Reactor {
  
  enum Action {
    case viewDidLoad
  }
  
  enum Mutation {
    
  }
  
  struct State {
    var sections: [CalendarSection] = []
    var items: [[CalendarSectionItem]] = []
  }
  
  // MARK: - Properties
  
  var initialState: State = State()
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      return .empty()
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    return newState
  }
  
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      
      let member1: TeamMember = .init(memberId: 0, nickname: "도미도미도미", order: 1, profilePhotoUrl: "")
      let member2: TeamMember = .init(memberId: 0, nickname: "나도미", order: 2, profilePhotoUrl: "")
      
      newState.items = [[.teamMember(member1), .teamMember(member2)], [], [.teamCalendar]]
      newState.sections = [.teamMembers, .calendar, .teamCalendar]
      
      return newState
    }
  }
}

// MARK: - Privates

private extension CalendarViewReactor {
  
}
