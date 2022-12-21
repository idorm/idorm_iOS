//
//  MatchingViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2022/12/20.
//

import Foundation

import Moya
import RxSwift
import RxCocoa
import ReactorKit

final class MatchingViewReactor: Reactor {
  
  enum Action {
    case viewDidLoad
    case viewWillAppear
    case didTapFilterButton
    case didTapRefreshButton
    case didTapPublicButton
    case didTapMakeProfileButton
    case didTapKakaoLinkButton(String)
    case didBeginSwipe(MatchingEnumerations.Swipe)
    case cancel(Int)
    case heart(Int)
    case message(Int)
    case didChangeFilter
  }
  
  enum Mutation {
    case updateLoading(Bool)
    case updateCurrentTextImage(MatchingEnumerations.TextImage)
    case updateNoPublicPopup(Bool)
    case updateNoMatchingInfoPopup(Bool)
    case updateNoMatchingInfoPopup_initial(Bool)
    case updateFilterVC(Bool)
    case updateOnboardingVC(Bool)
    case updateKakaoPopup(Bool, String)
    case updateBasicPopup(Bool)
    case updateIsOpenedWeb(Bool)
    case updateMatchingMembers([MatchingDTO.Retrieve])
    case updateBackgroundColor(MatchingEnumerations.Swipe)
    case updateBackgroundColor_withSwipe(MatchingEnumerations.Swipe)
  }
  
  struct State {
    var matchingMembers: [MatchingDTO.Retrieve] = []
    var isLoading: Bool = false
    var isOpenedNoPublicPopup: Bool = false
    var isOpenedNoMatchingInfoPopup: Bool = false
    var isOpenedNoMatchingInfoPopup_Initial: Bool = false
    var isOpenedKakaoPopup: (Bool, String) = (false, "")
    var isOpenedBasicPopup: Bool = false
    var isOpenedFilterVC: Bool = false
    var isOpenedOnboardingVC: Bool = false
    var isOpenedWeb: Bool = false
    var backgroundColor: MatchingEnumerations.Swipe = .none
    var backgroundColor_withSwipe: MatchingEnumerations.Swipe = .none
    var currentTextImage: MatchingEnumerations.TextImage = .noMatchingCardInformation
  }
  
  let initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    let memberStorage = MemberStorage.shared
    switch action {
    case .viewDidLoad:
      if memberStorage.hasMatchingInfo {
        if memberStorage.isPublicMatchingInfo {
          return Observable.concat([
            .just(.updateLoading(true)),
            fetchMatchingMembers()
          ])
        } else {
          return Observable.concat([
            .just(.updateNoPublicPopup(true)),
            .just(.updateNoPublicPopup(false))
          ])
        }
      } else {
        return Observable.concat([
          .just(.updateNoMatchingInfoPopup_initial(true)),
          .just(.updateNoMatchingInfoPopup_initial(false))
        ])
      }
      
    case .viewWillAppear:
      if memberStorage.hasMatchingInfo {
        if memberStorage.isPublicMatchingInfo {
          return .just(.updateCurrentTextImage(.noMatchingCardInformation))
        } else {
          return .just(.updateCurrentTextImage(.noShareState))
        }
      } else {
        return .just(.updateCurrentTextImage(.noMatchingInformation))
      }
      
    case .didChangeFilter:
      if FilterStorage.shared.hasFilter {
        return .concat([
          .just(.updateLoading(true)),
          fetchFilteredMembers()
        ])
      } else {
        return .concat([
          .just(.updateLoading(true)),
          fetchMatchingMembers()
        ])
      }
      
    case .didTapPublicButton:
      return .concat([
        .just(.updateLoading(true)),
        APIService.onboardingProvider.rx.request(.modifyPublic(true))
          .asObservable()
          .retry()
          .filterSuccessfulStatusCodes()
          .withUnretained(self)
          .flatMap { owner, _ -> Observable<Mutation> in
            SharedAPI.retrieveMatchingInfo()
            if FilterStorage.shared.hasFilter {
              return .concat([
                .just(.updateNoPublicPopup(false)),
                owner.fetchFilteredMembers()
              ])
            } else {
              return .concat([
                .just(.updateNoPublicPopup(false)),
                owner.fetchMatchingMembers()
              ])
            }
          }
      ])
      
    case .didTapMakeProfileButton:
      return .concat([
        .just(.updateNoMatchingInfoPopup(false)),
        .just(.updateNoMatchingInfoPopup_initial(false)),
        .just(.updateOnboardingVC(true)),
        .just(.updateOnboardingVC(false))
      ])
      
    case .didTapFilterButton:
      if memberStorage.hasMatchingInfo {
        if memberStorage.isPublicMatchingInfo {
          return Observable.concat([
            .just(.updateFilterVC(true)),
            .just(.updateFilterVC(false))
          ])
        } else {
          return Observable.concat([
            .just(.updateNoPublicPopup(true)),
            .just(.updateNoPublicPopup(false))
          ])
        }
      } else {
        return Observable.concat([
          .just(.updateNoMatchingInfoPopup(true)),
          .just(.updateNoMatchingInfoPopup(false))
        ])
      }
      
    case .didTapRefreshButton:
      if memberStorage.hasMatchingInfo {
        if memberStorage.isPublicMatchingInfo {
          if FilterStorage.shared.hasFilter {
            let filter = FilterStorage.shared.filter
            return Observable.concat([
              .just(.updateLoading(true)),
              fetchFilteredMembers()
            ])
          } else {
            return Observable.concat([
              .just(.updateLoading(true)),
              fetchMatchingMembers()
            ])
          }
        } else {
          return Observable.concat([
            .just(.updateNoPublicPopup(true)),
            .just(.updateNoPublicPopup(false))
          ])
        }
      } else {
        return Observable.concat([
          .just(.updateNoMatchingInfoPopup(true)),
          .just(.updateNoMatchingInfoPopup(false))
        ])
      }
      
    case .didBeginSwipe(let swipeType):
      return .just(.updateBackgroundColor_withSwipe(swipeType))
      
    case .cancel(let id):
      return Observable.concat([
        .just(.updateLoading(true)),
        .just(.updateBackgroundColor(.cancel)),
        APIService.matchingProvider.rx.request(.addDisliked(id))
          .asObservable()
          .retry()
          .filterSuccessfulStatusCodes()
          .flatMap { _ -> Observable<Mutation> in
            return Observable.concat([
              .just(.updateLoading(false)),
              .just(.updateBackgroundColor(.none))
            ])
          }
      ])
      
    case .heart(let id):
      return Observable.concat([
        .just(.updateLoading(true)),
        .just(.updateBackgroundColor(.heart)),
        APIService.matchingProvider.rx.request(.addLiked(id))
          .asObservable()
          .retry()
          .filterSuccessfulStatusCodes()
          .flatMap { _ -> Observable<Mutation> in
            return Observable.concat([
              .just(.updateLoading(false)),
              .just(.updateBackgroundColor(.none))
            ])
          }
      ])
      
    case .message(let index):
      let link = currentState.matchingMembers[index].openKakaoLink
      return .concat([
        .just(.updateKakaoPopup(true, link)),
        .just(.updateKakaoPopup(false, ""))
      ])
      
    case .didTapKakaoLinkButton(let url):
      if url.isValidKakaoLink {
        return .concat([
          .just(.updateIsOpenedWeb(true)),
          .just(.updateKakaoPopup(false, "")),
          .just(.updateIsOpenedWeb(false))
        ])
      } else {
        return .concat([
          .just(.updateBasicPopup(true)),
          .just(.updateKakaoPopup(false, "")),
          .just(.updateBasicPopup(false))
        ])
      }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .updateLoading(let isLoading):
      newState.isLoading = isLoading
      
    case .updateFilterVC(let isOpened):
      newState.isOpenedFilterVC = isOpened
      
    case .updateOnboardingVC(let isOpened):
      newState.isOpenedOnboardingVC = isOpened
      
    case .updateNoPublicPopup(let isOpened):
      newState.isOpenedNoPublicPopup = isOpened
      
    case .updateNoMatchingInfoPopup(let isOpened):
      newState.isOpenedNoMatchingInfoPopup = isOpened
      
    case .updateNoMatchingInfoPopup_initial(let isOpened):
      newState.isOpenedNoMatchingInfoPopup_Initial = isOpened
      
    case .updateMatchingMembers(let members):
      newState.matchingMembers = members
      newState.isLoading = false
      
    case let .updateKakaoPopup(isOpened, link):
      newState.isOpenedKakaoPopup = (isOpened, link)
      
    case .updateCurrentTextImage(let imageType):
      newState.currentTextImage = imageType
      
    case .updateBackgroundColor(let swipeType):
      newState.backgroundColor = swipeType
      
    case .updateBackgroundColor_withSwipe(let swipeType):
      newState.backgroundColor_withSwipe = swipeType
      
    case .updateIsOpenedWeb(let isOpened):
      newState.isOpenedWeb = isOpened
      
    case .updateBasicPopup(let isOpened):
      newState.isOpenedBasicPopup = isOpened
    }
    
    return newState
  }
  
  func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
    let publicEvent = MemberStorage.shared.didChangePublicState
      .distinctUntilChanged()
      .flatMap { isPublic -> Observable<Mutation> in
        return .concat([
          .just(.updateNoPublicPopup(true)),
          .just(.updateNoPublicPopup(false))
        ])
      }
    return Observable.merge(mutation, publicEvent)
  }
}

extension MatchingViewReactor {
  private func fetchMatchingMembers() -> Observable<Mutation> {
    return APIService.matchingProvider.rx.request(.retrieve)
      .asObservable()
      .retry()
      .filterSuccessfulStatusCodes()
      .flatMap { response -> Observable<Mutation> in
        switch response.statusCode {
        case 200:
          let members = APIService.decode(ResponseModel<[MatchingDTO.Retrieve]>.self, data: response.data).data
          return .just(.updateMatchingMembers(members))
        default:
          return .just(.updateMatchingMembers([]))
        }
      }
  }
  
  private func fetchFilteredMembers() -> Observable<Mutation> {
    let filter = FilterStorage.shared.filter
    return APIService.matchingProvider.rx.request(.retrieveFiltered(filter: filter))
      .asObservable()
      .retry()
      .filterSuccessfulStatusCodes()
      .flatMap { response -> Observable<Mutation> in
        switch response.statusCode {
        case 200:
          let members = APIService.decode(ResponseModel<[MatchingDTO.Retrieve]>.self, data: response.data).data
          return .just(.updateMatchingMembers(members))
        default:
          return .just(.updateMatchingMembers([]))
        }
      }
  }
}
