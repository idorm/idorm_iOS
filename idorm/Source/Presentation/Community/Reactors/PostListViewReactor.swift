//
//  PostListViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2023/01/14.
//

import Foundation

import ReactorKit
import RxMoya

final class PostListViewReactor: Reactor {
  
  enum Action {
    case viewDidLoad
    case didTapDormBtn(Dormitory)
  }
  
  enum Mutation {
    case setPosts([CommunityDTO.Post])
    case setTopPosts([CommunityDTO.Post])
    case setDorm(Dormitory)
    case setLoading(Bool)
  }
  
  struct State {
    var currentPosts: [CommunityDTO.Post] = []
    var currentTopPosts: [CommunityDTO.Post] = []
    var currentDorm: Dormitory = .no3
    var isLoading: Bool = false
  }
  
  var initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
      
    case .viewDidLoad:
      if let dorm = MemberStorage.shared.matchingInfo?.dormNum {
        return .concat([
          .just(.setLoading(true)),
          .just(.setDorm(dorm)),
          retrieveTopPosts(dorm)
        ])
      } else {
        return .concat([
          .just(.setLoading(true)),
          retrieveTopPosts(.no3)
        ])
      }
      
    case .didTapDormBtn(let dorm):
      return .concat([
        .just(.setLoading(true)),
        .just(.setDorm(dorm)),
        retrieveTopPosts(dorm)
      ])
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setLoading(let isLoading):
      newState.isLoading = isLoading
      
    case .setPosts(let posts):
      newState.currentPosts = posts
      
    case .setTopPosts(let posts):
      newState.currentTopPosts = posts
      
    case .setDorm(let dorm):
      newState.currentDorm = dorm
    }
    
    return newState
  }
}

extension PostListViewReactor {
  private func retrievePosts(
    _ dorm: Dormitory,
    page: Int
  ) -> Observable<Mutation> {
    return APIService.communityProvider.rx.request(
      .retrievePosts(dorm: dorm, page: page)
    )
    .asObservable()
    .retry()
    .map(ResponseModel<[CommunityDTO.Post]>.self)
    .flatMap { responseModel -> Observable<Mutation> in
      let posts = responseModel.data
      return .concat([
        .just(.setPosts(posts)),
        .just(.setLoading(false))
      ])
    }
  }
  
  private func retrieveTopPosts(_ dorm: Dormitory) -> Observable<Mutation> {
    return APIService.communityProvider.rx.request(.retrieveTopPosts(dorm))
      .asObservable()
      .retry()
      .withUnretained(self)
      .flatMap { owner, response -> Observable<Mutation> in
        switch response.statusCode {
        case 200:
          let posts = APIService.decode(
            ResponseModel<[CommunityDTO.Post]>.self,
            data: response.data
          ).data
          
          return .concat([
            .just(.setTopPosts(posts)),
            owner.retrievePosts(dorm, page: 0)
          ])
        case 204:
          return .concat([
            .just(.setTopPosts([])),
            owner.retrievePosts(dorm, page: 0)
          ])
        default:
          return .empty()
        }
      }
  }
}
