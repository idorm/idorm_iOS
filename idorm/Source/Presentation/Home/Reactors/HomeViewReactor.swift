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
    case setCalendars([CalendarResponseModel.Calendar])
  }
  
  struct State {
    var isLoading: Bool = false
    var popularPosts: [CommunityResponseModel.Posts] = []
    var calendars: [CalendarResponseModel.Calendar] = []
    var pushToPostDetailVC: (Bool, Int) = (false, 0)
  }
  
  var initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      return .empty()
//      let dormCategory = UserStorage.shared.matchingInfo?.dormCategory ?? .no1
//      return .concat([
//        .just(.setLoading(true)),
//        CommunityAPI.provider.rx.request(.lookupTopPosts(dormCategory))
//          .asObservable()
//          .withUnretained(self)
//          .flatMap { owner, response -> Observable<Mutation> in
//            let responseModel = CommunityAPI.decode(
//              ResponseModel<[CommunityResponseModel.Posts]>.self,
//              data: response.data
//            ).data
//            return .concat([
//              .just(.setPosts(responseModel)),
//              owner.retrieveCalendars()
//            ])
//          }
//      ])
      
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
      
    case .setCalendars(let calendars):
      newState.calendars = calendars
    }
    
    return newState
  }
}

extension HomeViewReactor {
  func retrieveCalendars() -> Observable<Mutation> {
    let date = Date()
    let calendar = Calendar.current
    let year = calendar.component(.year, from: date)
    let month = calendar.component(.month, from: date)
    let paddedString = String(format: "%02d", month)
    return DormCalendarAPI.provider.rx.request(.retrieveCalendars(
      year: "\(year)",
      month: paddedString
    ))
      .asObservable()
      .retry()
      .filterSuccessfulStatusCodes()
      .flatMap { response -> Observable<Mutation> in
        let calendars = DormCalendarAPI.decode(
          ResponseModel<[CalendarResponseModel.Calendar]>.self,
          data: response.data
        ).data
        return .concat([
          .just(.setCalendars(calendars)),
          .just(.setLoading(false))
        ])
      }
  }
}
