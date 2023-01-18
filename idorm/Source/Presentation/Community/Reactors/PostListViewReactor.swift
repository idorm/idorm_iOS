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
    case didTapPostingBtn
    case pullToRefresh
    case fetchMorePosts
    case reloadCompletion
  }
  
  enum Mutation {
    case appendPosts([CommunityDTO.Post])
    case setTopPosts([CommunityDTO.Post])
    case setDorm(Dormitory)
    case setLoading(Bool)
    case setRefreshing(Bool)
    case setPage(Int)
    case setPagination(Bool)
    case setBlockRequest(Bool)
    case resetPosts
    case setPostingVC(Bool, Dormitory)
  }
  
  struct State {
    var currentPosts: [CommunityDTO.Post] = []
    var currentTopPosts: [CommunityDTO.Post] = []
    var currentDorm: Dormitory = .no3
    var currentPage: Int = 0
    var isLoading: Bool = false
    var isRefreshing: Bool = false
    var isPagination: Bool = false
    var isBlockedRequest: Bool = false
    var showsPostingVC: (Bool, Dormitory) = (false, .no3)
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
        .just(.resetPosts),
        retrieveTopPosts(dorm)
      ])
      
    case .didTapPostingBtn:
      return .concat([
        .just(.setPostingVC(true, currentState.currentDorm)),
        .just(.setPostingVC(false, .no3))
      ])
      
    case .pullToRefresh:
      return .concat([
        .just(.setRefreshing(true)),
        .just(.resetPosts),
        retrieveTopPosts(currentState.currentDorm)
      ])
      
    case .fetchMorePosts:
      let nextPage = currentState.currentPage + 1
      
      return .concat([
        .just(.setPagination(true)),
        retrievePosts(currentState.currentDorm, page: nextPage)
      ])
      
    case .reloadCompletion:
      return .concat([
        .just(.setLoading(true)),
        retrieveTopPosts(currentState.currentDorm)
      ])
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setLoading(let isLoading):
      newState.isLoading = isLoading
      
    case .appendPosts(let posts):
      newState.currentPosts += posts
      
    case .setTopPosts(let posts):
      newState.currentTopPosts = posts
      
    case .setDorm(let dorm):
      newState.currentDorm = dorm
      
    case .setRefreshing(let isRefreshing):
      newState.isRefreshing = isRefreshing
      
    case .setPage(let page):
      newState.currentPage = page
      
    case .setPagination(let isPagination):
      newState.isPagination = isPagination
      
    case .setBlockRequest(let isBlockedRequest):
      newState.isBlockedRequest = isBlockedRequest
      
    case .resetPosts:
      newState.currentPosts = []
      
    case let .setPostingVC(isOpened, dorm):
      newState.showsPostingVC = (isOpened, dorm)
    }
    
    return newState
  }
}

extension PostListViewReactor {
  private func retrievePosts(
    _ dorm: Dormitory,
    page: Int
  ) -> Observable<Mutation> {
    return .concat([
      APIService.communityProvider.rx.request(
        .retrievePosts(dorm: dorm, page: page)
      )
      .asObservable()
      .retry()
      .map(ResponseModel<[CommunityDTO.Post]>.self)
      .flatMap { responseModel -> Observable<Mutation> in
        let posts = responseModel.data
        
        if posts.count < 20 {
          return .concat([
            .just(.setBlockRequest(true)),
            .just(.appendPosts(posts))
          ])
        } else {
          return .concat([
            .just(.setBlockRequest(false)),
            .just(.appendPosts(posts))
          ])
        }
      },
      .just(.setPagination(false)),
      .just(.setLoading(false)),
      .just(.setRefreshing(false))
    ])
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
