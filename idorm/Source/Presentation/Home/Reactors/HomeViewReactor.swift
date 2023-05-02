//
//  HomeViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2022/12/28.
//

import Foundation

import RxSwift
import RxCocoa
import ReactorKit
import RxMoya

final class HomeViewReactor: Reactor {
  
  enum Action {
    case viewDidLoad
    case postDidTap(postId: Int)
  }
  
  enum Mutation {
    case setLoading(Bool)
    case setPosts([CommunityResponseModel.Posts])
    case setPostDetailVC(Bool, Int)
  }
  
  struct State {
    var isLoading: Bool = false
    var popularPosts: [CommunityResponseModel.Posts] = []
    var pushToPostDetailVC: (Bool, Int) = (false, 0)
  }
  
  var initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      let dormCategory = UserStorage.shared.matchingInfo?.dormCategory ?? .no1
      return .concat([
        .just(.setLoading(true)),
        CommunityAPI.provider.rx.request(.lookupTopPosts(dormCategory))
          .asObservable()
          .flatMap { response -> Observable<Mutation> in
            let responseModel = CommunityAPI.decode(
              ResponseModel<[CommunityResponseModel.Posts]>.self,
              data: response.data
            ).data
            return .just(.setPosts(responseModel))
          }
      ])
      
    case let .postDidTap(postId):
      return .concat([
        .just(.setPostDetailVC(true, postId)),
        .just(.setPostDetailVC(false, 0))
      ])
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setLoading(let isLoading):
      newState.isLoading = isLoading
      
    case .setPosts(let posts):
      newState.popularPosts = posts
      
    case let .setPostDetailVC(state, postId):
      newState.pushToPostDetailVC = (state, postId)
    }
    
    return newState
  }
}

