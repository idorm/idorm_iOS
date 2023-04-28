//
//  MyCommunityViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2023/04/27.
//

import Foundation

import ReactorKit
import RxMoya

final class MyCommunityViewReactor: Reactor {
  
  enum Action {
    case viewDidLoad
  }
  
  enum Mutation {
    case setLoading(Bool)
    case setPosts([CommunityResponseModel.Posts])
    case setComments([CommunityResponseModel.Comment])
  }
  
  struct State {
    var isLoading: Bool = false
    var posts: [CommunityResponseModel.Posts] = []
    var comments: [CommunityResponseModel.Comment] = []
  }
  
  // MARK: - Properties
  
  var initialState: State = State()
  let viewControllerType: MyCommunityViewController.ViewControllerType
  
  // MARK: - Initializer
  
  init(_ viewControllerType: MyCommunityViewController.ViewControllerType) {
    self.viewControllerType = viewControllerType
  }
  
  // MARK: - Helpers
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      switch viewControllerType {
      case .post:
        return .concat([
          .just(.setLoading(true)),
          CommunityAPI.provider.rx.request(.lookupMyPosts)
            .asObservable()
            .flatMap { response -> Observable<Mutation> in
              let posts = CommunityAPI.decode(
                ResponseModel<[CommunityResponseModel.Posts]>.self,
                data: response.data
              ).data
              return .concat([
                .just(.setLoading(false)),
                .just(.setPosts(posts))
              ])
            }
        ])
        
      case .comment:
        return .concat([
          .just(.setLoading(true)),
          CommunityAPI.provider.rx.request(.lookupMyComments)
            .asObservable()
            .flatMap { response -> Observable<Mutation> in
              let comments = CommunityAPI.decode(
                ResponseModel<[CommunityResponseModel.Comment]>.self,
                data: response.data
              ).data
              return .concat([
                .just(.setLoading(false)),
                .just(.setComments(comments))
              ])
            }
        ])
        
      case .recommend:
        return .concat([
          .just(.setLoading(true)),
          CommunityAPI.provider.rx.request(.lookupMyLikedPosts)
            .asObservable()
            .flatMap { response -> Observable<Mutation> in
              let posts = CommunityAPI.decode(
                ResponseModel<[CommunityResponseModel.Posts]>.self,
                data: response.data
              ).data
              return .concat([
                .just(.setLoading(false)),
                .just(.setPosts(posts))
              ])
            }
        ])
      }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setLoading(let isLoading):
      newState.isLoading = isLoading
      
    case .setPosts(let posts):
      newState.posts = posts
      
    case .setComments(let comments):
      newState.comments = comments
    }
    
    return newState
  }
}
