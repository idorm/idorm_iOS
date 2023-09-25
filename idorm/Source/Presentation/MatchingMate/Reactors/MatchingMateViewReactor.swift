//
//  MatchingMateViewReactor.swift
//  idorm
//
//  Created by 김응철 on 9/23/23.
//

import Foundation
import OSLog

import ReactorKit

final class MatchingMateViewReactor: Reactor {
  
  enum Action {
    case viewDidLoad
    case viewWillAppear
    case like(identifier: Int)
    case dislike(identifier: Int)
    case kakaoButtonDidTap(index: Int)
    case refreshButtonDidTap
    case publicButtonDidTap
  }
  
  enum Mutation {
    case setWelcomePopupVC
    case setNoPublicPopupVC
    case setMates([MatchingInfo])
    case setQuotationType(MatchingMateQuotationView.ViewType)
    case setURL(URL)
  }
  
  struct State {
    @Pulse var mates: [MatchingInfo] = [.init(), .init()]
    @Pulse var quotationType: MatchingMateQuotationView.ViewType = .noCard
    @Pulse var presentToWelcomePopupVC: Bool = false
    @Pulse var presentToNoPublicPopupVC: Bool = false
    @Pulse var openURL: URL?
  }
  
  // MARK: - Properties
  
  var initialState: State = State()
  private let matchingMateService = NetworkService<MatchingMateAPI>()
  private let matchingInfoService = NetworkService<MatchingInfoAPI>()
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    let userStorage = UserStorage.shared
    
    switch action {
    case .viewDidLoad:
      if userStorage.hasMatchingInfo {
        // 자신의 매칭 정보가 있을 때
        if userStorage.isPublicMatchingInfo {
          // 매칭 정보가 공개 상태
          return self.requestMatchingMates()
        } else {
          // 매칭 정보가 비공개 상태
          return .just(.setNoPublicPopupVC)
        }
      } else {
        // 자신의 매칭 정보가 존재하지 않을 때
        if !userStorage.isLaunched {
          // 앱의 최초 실행일 때
          userStorage.isLaunched = true
          return .just(.setWelcomePopupVC)
        } else {
          // 앱이 전에 실행 되었을 때
          return .empty()
        }
      }
    case .viewWillAppear:
      if userStorage.hasMatchingInfo {
        // 자신의 매칭 정보가 있을 때
        if userStorage.isPublicMatchingInfo {
          // 매칭 정보 공개
          return .just(.setQuotationType(.noCard))
        } else {
          // 매칭 정보 비공개
          return .just(.setQuotationType(.noPublic))
        }
      } else {
        // 매칭 정보가 없을 때
        return .just(.setQuotationType(.noMatchingInfo))
      }
    case .like(let identifier):
      return self.matchingMateService
        .requestAPI(
          to: .createMatchingMate(isLiked: true, identifier: identifier),
          withAlert: false
        ).flatMap { _ in return Observable.empty() }
    case .dislike(let identifier):
      return self.matchingMateService
        .requestAPI(
          to: .createMatchingMate(isLiked: false, identifier: identifier),
          withAlert: false
        ).flatMap { _ in return Observable.empty() }
    case .kakaoButtonDidTap(let index):
      let kakaoLink = self.currentState.mates[index].openKakaoLink
      if let url = URL(string: kakaoLink) {
        return .just(.setURL(url))
      } else {
        AlertManager.shared.showAlertPopup("유효하지 않은 주소입니다.")
        os_log(.info, "❌ 올바른 URL주소가 아닙니다. \(kakaoLink)")
        return .empty()
      }
    case .refreshButtonDidTap:
      return self.requestMatchingMates()
    case .publicButtonDidTap:
      guard var matchingInfo = userStorage.matchingInfo else {
        AlertManager.shared.showAlertPopup("매칭 정보가 존재하지 않습니다.")
        return .empty()
      }
      let isPublic = matchingInfo.isMatchingInfoPublic
      return self.matchingInfoService.requestAPI(to: .updateMatchingInfoForPublic(!isPublic))
        .flatMap { _ in
          matchingInfo.isMatchingInfoPublic = !isPublic
          userStorage.matchingInfo = matchingInfo
          return self.requestMatchingMates()
        }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setWelcomePopupVC:
      newState.presentToWelcomePopupVC = true
    case .setNoPublicPopupVC:
      newState.presentToNoPublicPopupVC = true
    case .setMates(let mates):
      newState.mates = mates
    case .setQuotationType(let viewType):
      newState.quotationType = viewType
    case .setURL(let url):
      newState.openURL = url
    }
    
    return newState
  }
}

// MARK: - Privates

private extension MatchingMateViewReactor {
  func requestMatchingMates() -> Observable<Mutation> {
    if let requestDTO = UserStorage.shared.matchingMateFilter {
      return self.matchingMateService.requestAPI(to: .getFilteredMembers(requestDTO))
        .map(ResponseDTO<[MatchingMateResponseDTO]>.self)
        .flatMap { responseDTO in
          return Observable<Mutation>.just(.setMates(responseDTO.data.map { MatchingInfo($0) }))
        }
    } else {
      return self.matchingMateService.requestAPI(to: .getMembers)
        .map(ResponseDTO<[MatchingMateResponseDTO]>.self)
        .flatMap { responseDTO in
          return Observable<Mutation>.just(.setMates(responseDTO.data.map { MatchingInfo($0) }))
        }
    }
  }
}
