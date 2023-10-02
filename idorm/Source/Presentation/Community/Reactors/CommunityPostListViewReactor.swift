//
//  PostListViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2023/01/14.
//

import Foundation

import ReactorKit
import RxMoya

final class CommunityPostListViewReactor: Reactor {
  
  enum Action {
    case itemSelected(CommunityPostListSectionItem)
    case writingButtonDidTap
    case dormitoryButtonDidTap
    case dormitoryDidChange(Dormitory)
    case bottomScrolled
  }
  
  enum Mutation {
    case setPostingVC
    case setPostVC(Post)
    case setDormitory(Dormitory)
  }
  
  struct State {
    var sections: [CommunityPostListSection] = []
    var items: [[CommunityPostListSectionItem]] = []
    var currentDormitory: Dormitory = UserStorage.shared.dormCategory
    var topPosts: [Post] = [.init()]
    var posts: [Post] = [.init()]
    var currentPage: Int = 0
    @Pulse var naivgateToPostVC: Post = .init()
    @Pulse var navigateToPostingVC: Bool = false
  }
  
  // MARK: - Properties
  
  var initialState: State = State()
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .itemSelected(let item):
      switch item {
      case .topPost(let post):
        return .just(.setPostVC(post))
      case .post(let post):
        return .just(.setPostVC(post))
      }
    case .writingButtonDidTap:
      return .just(.setPostingVC)
    case .bottomScrolled:
      return .empty()
    case .dormitoryButtonDidTap:
      ModalManager.presentBottomSheetVC(
        Dormitory.allCases.map { return BottomSheetItem.dormitory($0) }
      ) { item in
        switch item {
        case .dormitory(let dormitory):
          self.action.onNext(.dormitoryDidChange(dormitory))
        default: break
        }
      }
      return .empty()
    case .dormitoryDidChange(let dormitory):
      return .just(.setDormitory(dormitory))
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setPostingVC:
      newState.navigateToPostingVC = true
    case .setPostVC(let post):
      newState.naivgateToPostVC = post
    case .setDormitory(let dormitory):
      newState.currentDormitory = dormitory
    }
    
    return newState
  }
  
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      
      if state.topPosts.isEmpty {
        newState.sections = [.post]
      } else {
        newState.sections = [.topPost, .post]
      }
      
      newState.items = [
        state.topPosts.map { .topPost($0) },
        state.posts.map { .post($0) }
      ]
      
      return newState
    }
  }
}
