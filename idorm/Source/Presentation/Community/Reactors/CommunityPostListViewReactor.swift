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
    case bottomScrolled
  }
  
  enum Mutation {
    case setPostingVC
    case setPostVC(Post)
  }
  
  struct State {
    var sections: [CommunityPostListSection] = []
    var items: [[CommunityPostListSectionItem]] = []
    var topPosts: [Post] = [.init()]
    var posts: [Post] = [.init()]
    var currentPage: Int = 0
    @Pulse var naivgateToPostVC: Post = .init()
    @Pulse var navigateToPostingVC: Bool = false
  }
  
  // MARK: - Properties
  
  var initialState: State = State()
  private let communityService = NetworkService<CommunityAPI>()
  
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
      
      //    case .viewDidLoad:
      //      if let dorm = MemberStorage.shared.matchingInfo?.dormCategory {
      //        return .concat([
      //          .just(.setLoading(true)),
      //          .just(.setDorm(dorm)),
      //          retrieveTopPosts(dorm)
      //        ])
      //      } else {
      //        return .concat([
      //          .just(.setLoading(true)),
      //          retrieveTopPosts(.no1)
      //        ])
      //      }
      //
      //    case .didTapDormBtn(let dorm):
      //      return .concat([
      //        .just(.setLoading(true)),
      //        .just(.resetPosts),
      //        .just(.setPage(0)),
      //        .just(.setDorm(dorm)),
      //        .just(.setPagination(false)),
      //        .just(.setBlockRequest(false)),
      //        .just(.setScrollToTop(true)),
      //        .just(.setScrollToTop(false)),
      //        retrieveTopPosts(dorm)
      //      ])
      //
      //    case .didTapPostingBtn:
      //      return .concat([
      //        .just(.setPostingVC(true, currentState.currentDorm)),
      //        .just(.setPostingVC(false, .no3))
      //      ])
      //
      //    case .didTapPostBtn(let postId):
      //      return self.apiManager.requestAPI(to: .lookupDetailPost(postId: postId))
      //        .map(ResponseDTO<CommunitySinglePostResponseDTO>.self)
      //        .flatMap { _ in
      //          return Observable<Mutation>.concat([
      ////            .just(.setPostDetailVC(true, $0.data.toPost())),
      //            .just(.setPostDetailVC(false, .init()))
      //          ])
      //        }
      //
      //    case .pullToRefresh:
      //      return .concat([
      //        .just(.resetPosts),
      //        .just(.setBlockRequest(false)),
      //        .just(.setPagination(false)),
      //        .just(.setPage(0)),
      //        retrieveTopPosts(currentState.currentDorm)
      //      ])
      //
      //    case .fetchMorePosts:
      //      let nextPage = currentState.currentPage + 1
      //      return .concat([
      //        .just(.setPagination(true)),
      //        .just(.setPage(nextPage)),
      //        retrievePosts(currentState.currentDorm, page: nextPage)
      //      ])
      //
      //    case .fetchNewPosts:
      //      return .concat([
      //        .just(.setLoading(true)),
      //        .just(.resetPosts),
      //        retrieveTopPosts(currentState.currentDorm)
      //      ])
      //    }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
      var newState = state
      
      //    switch mutation {
      //    case .setLoading(let isLoading):
      //      newState.isLoading = isLoading
      //
      //    case .appendPosts(let posts):
      //      newState.currentPosts += posts
      //
      //    case .setTopPosts(let posts):
      //      newState.currentTopPosts = posts
      //
      //    case .setDorm(let dorm):
      //      newState.currentDorm = dorm
      //
      //    case .setPage(let page):
      //      newState.currentPage = page
      //
      //    case .setPagination(let isPagination):
      //      newState.isPagination = isPagination
      //
      //    case .setBlockRequest(let isBlockedRequest):
      //      newState.isBlockedRequest = isBlockedRequest
      //
      //    case let .setPostingVC(isOpened, dorm):
      //      newState.showsPostingVC = (isOpened, dorm)
      //
      //    case let .setPostDetailVC(isOpened, postId):
      //      newState.showsPostDetailVC = (isOpened, postId)
      //
      //    case .setEndRefreshing(let state):
      //      newState.endRefreshing = state
      //
      //    case .setReloadData(let state):
      //      newState.reloadData = state
      //
      //    case .resetPosts:
      //      newState.currentPosts = []
      //      newState.currentTopPosts = []
      //
      //    case .setScrollToTop(let state):
      //      newState.scrollToTop = state
      //
      //    case .setRefreshing(let isRefreshing):
      //      newState.isRefreshing = isRefreshing
      //    }
      
      return newState
    }
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

//extension CommunityPostListViewReactor {
//  private func retrievePosts(
//    _ dorm: Dormitory,
//    page: Int
//  ) -> Observable<Mutation> {
//    return .concat([
//      CommunityAPI.provider.rx.request(
//        .lookupPosts(dorm: dorm, page: page)
//      )
//      .asObservable()
//      .retry()
//      .map(ResponseDTO<[CommunityResponseModel.Posts]>.self)
//      .flatMap { responseModel -> Observable<Mutation> in
//        let posts = responseModel.data
//        if posts.count < 10 {
//          return .concat([
//            .just(.setBlockRequest(true)),
//            .just(.appendPosts(posts)),
//          ])
//        } else {
//          return .concat([
//            .just(.setBlockRequest(false)),
//            .just(.appendPosts(posts))
//          ])
//        }
//      },
//      .just(.setReloadData(true)),
//      .just(.setReloadData(false)),
//      .just(.setPagination(false)),
//      .just(.setLoading(false)),
//      .just(.setEndRefreshing(true)),
//      .just(.setEndRefreshing(false)),
//    ])
//  }
//  
//  private func retrieveTopPosts(_ dorm: Dormitory) -> Observable<Mutation> {
//    return CommunityAPI.provider.rx.request(.lookupTopPosts(dorm))
//      .asObservable()
//      .retry()
//      .withUnretained(self)
//      .flatMap { owner, response -> Observable<Mutation> in
//        switch response.statusCode {
//        case 200:
//          let posts = CommunityAPI.decode(
//            ResponseDTO<[CommunityResponseModel.Posts]>.self,
//            data: response.data
//          ).data
//          
//          return .concat([
//            .just(.setTopPosts(posts)),
//            owner.retrievePosts(dorm, page: 0)
//          ])
//        case 204:
//          return .concat([
//            .just(.setTopPosts([])),
//            owner.retrievePosts(dorm, page: 0)
//          ])
//        default:
//          return .empty()
//        }
//      }
//  }
//}
