//
//  PostListViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2023/01/14.
//

import Foundation

import ReactorKit
import RxMoya

final class CommunityListViewReactor: Reactor {
  
  enum Action {
    case viewDidLoad
    case didTapDormBtn(Dormitory)
    case didTapPostingBtn
    case didTapPostBtn(Int)
    case pullToRefresh
    case fetchMorePosts
    case fetchNewPosts
  }
  
  enum Mutation {
    case appendPosts([CommunityResponseModel.Posts])
    case setTopPosts([CommunityResponseModel.Posts])
    case setDorm(Dormitory)
    case setLoading(Bool)
    case setEndRefreshing(Bool)
    case setPage(Int)
    case setPagination(Bool)
    case setBlockRequest(Bool)
    case setPostingVC(Bool, Dormitory)
    case setPostDetailVC(Bool, Post)
    case setReloadData(Bool)
    case resetPosts
    case setRefreshing(Bool)
    case setScrollToTop(Bool)
  }
  
  struct State {
    var currentPosts: [CommunityResponseModel.Posts] = []
    var currentTopPosts: [CommunityResponseModel.Posts] = []
    var currentDorm: Dormitory = .no1
    var currentPage: Int = 0
    var isLoading: Bool = false
    var isRefreshing: Bool = false
    var endRefreshing: Bool = false
    var isPagination: Bool = false
    var isBlockedRequest: Bool = false
    var reloadData: Bool = false
    var showsPostingVC: (Bool, Dormitory) = (false, .no3)
    var showsPostDetailVC: (Bool, Post) = (false, .init())
    var scrollToTop: Bool = false
  }
  
  var initialState: State = State()
  private let apiManager = NetworkService<CommunityAPI>()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
      
    case .viewDidLoad:
      if let dorm = MemberStorage.shared.matchingInfo?.dormCategory {
        return .concat([
          .just(.setLoading(true)),
          .just(.setDorm(dorm)),
          retrieveTopPosts(dorm)
        ])
      } else {
        return .concat([
          .just(.setLoading(true)),
          retrieveTopPosts(.no1)
        ])
      }
      
    case .didTapDormBtn(let dorm):
      return .concat([
        .just(.setLoading(true)),
        .just(.resetPosts),
        .just(.setPage(0)),
        .just(.setDorm(dorm)),
        .just(.setPagination(false)),
        .just(.setBlockRequest(false)),
        .just(.setScrollToTop(true)),
        .just(.setScrollToTop(false)),
        retrieveTopPosts(dorm)
      ])
      
    case .didTapPostingBtn:
      return .concat([
        .just(.setPostingVC(true, currentState.currentDorm)),
        .just(.setPostingVC(false, .no3))
      ])
      
    case .didTapPostBtn(let postId):
      return self.apiManager.requestAPI(to: .lookupDetailPost(postId: postId))
        .map(ResponseDTO<CommunitySinglePostResponseDTO>.self)
        .flatMap {
          return Observable<Mutation>.concat([
            .just(.setPostDetailVC(true, $0.data.toPost())),
            .just(.setPostDetailVC(false, .init()))
          ])
        }
      
    case .pullToRefresh:
      return .concat([
        .just(.resetPosts),
        .just(.setBlockRequest(false)),
        .just(.setPagination(false)),
        .just(.setPage(0)),
        retrieveTopPosts(currentState.currentDorm)
      ])
      
    case .fetchMorePosts:
      let nextPage = currentState.currentPage + 1
      return .concat([
        .just(.setPagination(true)),
        .just(.setPage(nextPage)),
        retrievePosts(currentState.currentDorm, page: nextPage)
      ])
      
    case .fetchNewPosts:
      return .concat([
        .just(.setLoading(true)),
        .just(.resetPosts),
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
      
    case .setPage(let page):
      newState.currentPage = page
      
    case .setPagination(let isPagination):
      newState.isPagination = isPagination
      
    case .setBlockRequest(let isBlockedRequest):
      newState.isBlockedRequest = isBlockedRequest
      
    case let .setPostingVC(isOpened, dorm):
      newState.showsPostingVC = (isOpened, dorm)
      
    case let .setPostDetailVC(isOpened, postId):
      newState.showsPostDetailVC = (isOpened, postId)
      
    case .setEndRefreshing(let state):
      newState.endRefreshing = state
      
    case .setReloadData(let state):
      newState.reloadData = state
      
    case .resetPosts:
      newState.currentPosts = []
      newState.currentTopPosts = []
      
    case .setScrollToTop(let state):
      newState.scrollToTop = state
      
    case .setRefreshing(let isRefreshing):
      newState.isRefreshing = isRefreshing
    }
    
    return newState
  }
}

extension CommunityListViewReactor {
  private func retrievePosts(
    _ dorm: Dormitory,
    page: Int
  ) -> Observable<Mutation> {
    return .concat([
      CommunityAPI.provider.rx.request(
        .lookupPosts(dorm: dorm, page: page)
      )
      .asObservable()
      .retry()
      .map(ResponseDTO<[CommunityResponseModel.Posts]>.self)
      .flatMap { responseModel -> Observable<Mutation> in
        let posts = responseModel.data
        if posts.count < 10 {
          return .concat([
            .just(.setBlockRequest(true)),
            .just(.appendPosts(posts)),
          ])
        } else {
          return .concat([
            .just(.setBlockRequest(false)),
            .just(.appendPosts(posts))
          ])
        }
      },
      .just(.setReloadData(true)),
      .just(.setReloadData(false)),
      .just(.setPagination(false)),
      .just(.setLoading(false)),
      .just(.setEndRefreshing(true)),
      .just(.setEndRefreshing(false)),
    ])
  }
  
  private func retrieveTopPosts(_ dorm: Dormitory) -> Observable<Mutation> {
    return CommunityAPI.provider.rx.request(.lookupTopPosts(dorm))
      .asObservable()
      .retry()
      .withUnretained(self)
      .flatMap { owner, response -> Observable<Mutation> in
        switch response.statusCode {
        case 200:
          let posts = CommunityAPI.decode(
            ResponseDTO<[CommunityResponseModel.Posts]>.self,
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
