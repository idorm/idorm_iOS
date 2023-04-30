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
    case viewNeedsUpdate
    case sortButtonDidTap(Bool)
  }
  
  enum Mutation {
    case setLoading(Bool)
    case setPosts([CommunityResponseModel.Posts])
    case setComments([CommunityResponseModel.SubComment])
    case setReloadData(Bool)
    case setSort(Bool)
  }
  
  struct State {
    var isLoading: Bool = false
    var posts: [CommunityResponseModel.Posts] = []
    var comments: [CommunityResponseModel.SubComment] = []
    var reloadData: Bool = false
    var isLatest: Bool = true
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
    case .viewNeedsUpdate:
      switch viewControllerType {
      case .post:
        return .concat([
          .just(.setLoading(true)),
          CommunityAPI.provider.rx.request(.lookupMyPosts)
            .asObservable()
            .withUnretained(self)
            .flatMap { owner, response -> Observable<Mutation> in
              let posts = CommunityAPI.decode(
                ResponseModel<[CommunityResponseModel.Posts]>.self,
                data: response.data
              ).data
              return .concat([
                .just(.setLoading(false)),
                .just(.setPosts(
                  owner.currentState.isLatest ? posts : posts.reversed()
                )),
                .just(.setReloadData(true)),
                .just(.setReloadData(false))
              ])
            }
        ])
        
      case .comment:
        return .concat([
          .just(.setLoading(true)),
          CommunityAPI.provider.rx.request(.lookupMyComments)
            .asObservable()
            .withUnretained(self)
            .flatMap { owner, response -> Observable<Mutation> in
              switch response.statusCode {
              case 200:
                let comments = CommunityAPI.decode(
                  ResponseModel<[CommunityResponseModel.SubComment]>.self,
                  data: response.data
                ).data
                return .concat([
                  .just(.setLoading(false)),
                  .just(.setComments(
                    owner.currentState.isLatest ? comments : comments.reversed()
                  )),
                  .just(.setReloadData(true)),
                  .just(.setReloadData(false))
                ])
              default:
                fatalError()
              }
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
      
    case .sortButtonDidTap(let isLatest):
      let newPosts = Array(currentState.posts.reversed())
      let newComments = Array(currentState.comments.reversed())
      return .concat([
        .just(.setComments(newComments)),
        .just(.setPosts(newPosts)),
        .just(.setReloadData(true)),
        .just(.setReloadData(false)),
        .just(.setSort(isLatest))
      ])
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
      
    case .setReloadData(let reloadData):
      newState.reloadData = reloadData
      
    case .setSort(let isLatest):
      newState.isLatest = isLatest
    }
    
    return newState
  }
}
