//
//  ManagementMyInfoViewReactor.swift
//  idorm
//
//  Created by 김응철 on 9/29/23.
//

import Foundation

import ReactorKit

final class ManagementMyInfoViewReactor: Reactor {
  
  enum Action {
    case viewWillAppear
  }
  
  enum Mutation {
    
  }
  
  struct State {
    var sections: [ManagementMyInfoSection] = []
    var items: [[ManagementMyInfoSectionItem]] = []
  }
  
  // MARK: - Properties
  
  var initialState: State = State()
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewWillAppear:
      return .empty()
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    
  }
  
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      
//      guard let member = UserStorage.shared.member else { return newState }
      var member = Member()
      member.email = "SDASDA"
      member.nickname = "ASDFSDF"
      
      newState.sections = [.profileImage, .main, .service, .membership]
      newState.items = [
        [.profileImage(imageURL: member.profilePhotoURL)],
        [.nickname(nickname: member.nickname), .changePassword, .email(email: member.email)],
        [.terms, .version],
        [.membership]
      ]
      
      return newState
    }
  }
}
