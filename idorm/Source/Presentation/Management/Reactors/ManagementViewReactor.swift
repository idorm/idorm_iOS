//
//  ManagementViewReactor.swift
//  idorm
//
//  Created by 김응철 on 9/29/23.
//

import Foundation

import ReactorKit

final class ManagementViewReactor: Reactor {
  
  enum ViewType {
    case myPosts
    case recommendedPosts
    case myComments
    case likedRoommates
    case dislikedRoommates
    
    var title: String {
      switch self {
      case .myPosts: "내가 쓴 글"
      case .recommendedPosts: "공감한 글"
      case .myComments: "내가 쓴 댓글"
      case .likedRoommates: "좋아요한 룸메"
      case .dislikedRoommates: "싫어요한 룸메"
      }
    }
    
    var section: ManagementSection {
      switch self {
      case .myPosts, .recommendedPosts:
        return .post
      case .myComments:
        return .comment
      case .likedRoommates, .dislikedRoommates:
        return .matchingCard
      }
    }
  }
  
  enum Action {
    case orderButtonDidTap(isLastest: Bool)
  }
  
  enum Mutation {
    case setOrdering(isLastest: Bool)
  }
  
  struct State {
    let viewType: ViewType
    var section: ManagementSection
    var items: [ManagementSectionItem] = []
    var isLastest: Bool = true
  }
  
  // MARK: - Properties
  
  var initialState: State
  
  // MARK: - Initializer
  
  init(_ viewType: ViewType) {
    self.initialState = State(viewType: viewType, section: viewType.section)
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .orderButtonDidTap(let isLastest):
      return .just(.setOrdering(isLastest: isLastest))
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setOrdering(let isLastest):
      newState.isLastest = isLastest
    }
    
    return newState
  }
  
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      
      
      
      return newState
    }
  }
}
