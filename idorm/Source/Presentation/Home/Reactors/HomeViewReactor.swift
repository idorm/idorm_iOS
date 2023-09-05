//
//  HomeViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2022/12/28.
//

import UIKit
import OSLog

import RxSwift
import RxCocoa
import ReactorKit
import RxMoya

final class HomeViewReactor: Reactor {
  
  enum Action {
    case viewWillAppear
    case itemSelected(HomeSectionItem)
  }
  
  enum Mutation {
    case setTopPosts([Post])
    case setDormCalendars([DormCalendar])
    case setCommunityPostVC(Post)
  }
  
  struct State {
    var topPosts: [Post] = []
    var dormCalendars: [DormCalendar] = []
    var sections: [HomeSection] = []
    var items: [[HomeSectionItem]] = []
    @Pulse var navigateToCommunityPostVC: Post = .init()
  }
    
  var initialState: State = State()
  private let communityAPIManager = NetworkService<CommunityAPI>()
  private let calendarAPIManger = NetworkService<CalendarAPI>()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewWillAppear:
      return self.requestTopPosts()
      
    case .itemSelected(let item):
      switch item {
      case .dormCalendar(let calendar):
        guard let url = calendar.url else {
          os_log(.info, "🔗 URL주소가 존재하지 않습니다!")
          return .empty()
        }
        if let url = URL(string: url) {
          UIApplication.shared.open(url)
        } else {
          os_log(.error, "🔴 유효한 URL주소가 아닙니다!")
        }
        return .empty()
        
      case .topPost(let post):
        return self.communityAPIManager.requestAPI(to: .lookupDetailPost(postId: post.identifier))
          .map(ResponseDTO<CommunitySinglePostResponseDTO>.self)
          .flatMap { return Observable<Mutation>.just(.setCommunityPostVC(Post($0.data))) }
        
      default:
        return .empty()
      }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setTopPosts(let topPosts):
      newState.topPosts = topPosts
      
    case .setDormCalendars(let dormCalendars):
      newState.dormCalendars = dormCalendars
      
    case .setCommunityPostVC(let post):
      newState.navigateToCommunityPostVC = post
    }
    
    return newState
  }
  
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      
      var sections: [HomeSection] = []
      var items: [[HomeSectionItem]] = []
      
      // Main
      sections.append(.main)
      items.append([.main])
      
      // TopPosts
      if state.topPosts.isNotEmpty {
        sections.append(.topPosts)
        items.append(state.topPosts.map { HomeSectionItem.topPost($0) })
      }
      
      // DormCalendars
      sections.append(.dormCalendars)
      if state.dormCalendars.isNotEmpty {
        items.append(state.dormCalendars.map { HomeSectionItem.dormCalendar($0) })
      } else {
        items.append([.emptyDormCalendar])
      }
      
      newState.sections = sections
      newState.items = items
      
      return newState
    }
  }
}

// MARK: - Privates

private extension HomeViewReactor {
  func requestTopPosts() -> Observable<Mutation> {
    let domitory = UserStorage.shared.matchingInfo?.dormCategory ?? .no1
    return self.communityAPIManager.requestAPI(to: .lookupTopPosts(domitory))
      .map(ResponseDTO<[CommunitySingleTopPostResponseDTO]>.self)
      .flatMap { response -> Observable<Mutation> in
        let topPosts = response.data.map { Post($0) }
        return .concat([
          .just(.setTopPosts(topPosts)),
          self.requestDormCalendars()
        ])
      }
  }
  
  func requestDormCalendars() -> Observable<Mutation> {
    let yearMonth = Date().toString("yyyy-MM")
    return self.calendarAPIManger.requestAPI(to: .postDormCalendars(yearMonth: yearMonth))
      .map(ResponseDTO<[DormCalendarResponseDTO]>.self)
      .flatMap {
        let dormCalendars = $0.data.map { DormCalendar($0) }
        return Observable<Mutation>.just(.setDormCalendars(dormCalendars))
      }
  }
}
