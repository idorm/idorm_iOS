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
import RxMoya
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
    case setLoading(Bool)
    case setCurrentTextImage(MatchingEnumerations.TextImage)
    case setNoPublicPopup(Bool)
    case setNoMatchingInfoPopup(Bool)
    case setNoMatchingInfoPopup_initial(Bool)
    case setFilterVC(Bool)
    case setOnboardingVC(Bool)
    case setKakaoPopup(Bool, String)
    case setBasicPopup(Bool)
    case setWeb(Bool)
    case setMatchingMembers([MatchingDTO.Retrieve])
    case setBackgroundColor(MatchingEnumerations.Swipe)
    case setBackgroundColor_withSwipe(MatchingEnumerations.Swipe)
    case setDismissPopup(Bool)
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
    var dismissPopup: Bool = false
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
            .just(.setLoading(true)),
            fetchMatchingMembers()
          ])
        } else {
          return Observable.concat([
            .just(.setNoPublicPopup(true)),
            .just(.setNoPublicPopup(false))
          ])
        }
      } else {
        if UserDefaults.standard.bool(forKey: "launchedBefore") {
          UserDefaults.standard.set(true, forKey: "launchedBefore")
          return Observable.concat([
            .just(.setNoMatchingInfoPopup_initial(true)),
            .just(.setNoMatchingInfoPopup_initial(false))
          ])
        } else {
          return .empty()
        }
      }
      
    case .viewWillAppear:
      if memberStorage.hasMatchingInfo {
        if memberStorage.isPublicMatchingInfo {
           return .just(.setCurrentTextImage(.noMatchingCardInformation))
        } else {
          return .concat([
            .just(.setCurrentTextImage(.noShareState)),
            .just(.setMatchingMembers([]))
          ])
        }
      } else {
        return .just(.setCurrentTextImage(.noMatchingInformation))
      }
      
    case .didChangeFilter:
      if FilterStorage.shared.hasFilter {
        return .concat([
          .just(.setLoading(true)),
          fetchFilteredMembers()
        ])
      } else {
        return .concat([
          .just(.setLoading(true)),
          fetchMatchingMembers()
        ])
      }
      
    case .didTapPublicButton:
      return .concat([
        .just(.setDismissPopup(true)),
        .just(.setDismissPopup(false)),
        .just(.setLoading(true)),
        APIService.onboardingProvider.rx.request(.modifyPublic(true))
          .asObservable()
          .retry()
          .filterSuccessfulStatusCodes()
          .withUnretained(self)
          .flatMap { owner, _ -> Observable<Mutation> in
            SharedAPI.retrieveMatchingInfo()
            if FilterStorage.shared.hasFilter {
              return .concat([
                .just(.setNoPublicPopup(false)),
                owner.fetchFilteredMembers()
              ])
            } else {
              return .concat([
                .just(.setNoPublicPopup(false)),
                owner.fetchMatchingMembers()
              ])
            }
          }
      ])
      
    case .didTapMakeProfileButton:
      return .concat([
        .just(.setDismissPopup(true)),
        .just(.setDismissPopup(false)),
        .just(.setOnboardingVC(true)),
        .just(.setOnboardingVC(false))
      ])
      
    case .didTapFilterButton:
      if memberStorage.hasMatchingInfo {
        if memberStorage.isPublicMatchingInfo {
          return Observable.concat([
            .just(.setFilterVC(true)),
            .just(.setFilterVC(false))
          ])
        } else {
          return Observable.concat([
            .just(.setNoPublicPopup(true)),
            .just(.setNoPublicPopup(false))
          ])
        }
      } else {
        return Observable.concat([
          .just(.setNoMatchingInfoPopup(true)),
          .just(.setNoMatchingInfoPopup(false))
        ])
      }
      
    case .didTapRefreshButton:
      if memberStorage.hasMatchingInfo {
        if memberStorage.isPublicMatchingInfo {
          if FilterStorage.shared.hasFilter {
            return Observable.concat([
              .just(.setLoading(true)),
              fetchFilteredMembers()
            ])
          } else {
            return Observable.concat([
              .just(.setLoading(true)),
              fetchMatchingMembers()
            ])
          }
        } else {
          return Observable.concat([
            .just(.setNoPublicPopup(true)),
            .just(.setNoPublicPopup(false))
          ])
        }
      } else {
        return Observable.concat([
          .just(.setNoMatchingInfoPopup(true)),
          .just(.setNoMatchingInfoPopup(false))
        ])
      }
      
    case .didBeginSwipe(let swipeType):
      return .just(.setBackgroundColor_withSwipe(swipeType))
      
    case .cancel(let id):
      return Observable.concat([
        .just(.setLoading(true)),
        .just(.setBackgroundColor(.cancel)),
        APIService.matchingProvider.rx.request(.addDisliked(id))
          .asObservable()
          .retry()
          .flatMap { _ -> Observable<Mutation> in
            return Observable.concat([
              .just(.setLoading(false)),
              .just(.setBackgroundColor(.none))
            ])
          }
      ])
      
    case .heart(let id):
      return Observable.concat([
        .just(.setLoading(true)),
        .just(.setBackgroundColor(.heart)),
        APIService.matchingProvider.rx.request(.addLiked(id))
          .asObservable()
          .retry()
          .flatMap { response -> Observable<Mutation> in
            return Observable.concat([
              .just(.setLoading(false)),
              .just(.setBackgroundColor(.none))
            ])
          }
      ])
      
    case .message(let index):
      let link = currentState.matchingMembers[index].openKakaoLink
      return .concat([
        .just(.setKakaoPopup(true, link)),
        .just(.setKakaoPopup(false, ""))
      ])
      
    case .didTapKakaoLinkButton(let url):
      if url.isValidKakaoLink {
        return .concat([
          .just(.setDismissPopup(true)),
          .just(.setDismissPopup(false)),
          .just(.setWeb(true)),
          .just(.setWeb(false))
        ])
      } else {
        return .concat([
          .just(.setBasicPopup(true)),
          .just(.setKakaoPopup(false, "")),
          .just(.setBasicPopup(false))
        ])
      }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setLoading(let isLoading):
      newState.isLoading = isLoading
      
    case .setFilterVC(let isOpened):
      newState.isOpenedFilterVC = isOpened
      
    case .setOnboardingVC(let isOpened):
      newState.isOpenedOnboardingVC = isOpened
      
    case .setNoPublicPopup(let isOpened):
      newState.isOpenedNoPublicPopup = isOpened
      
    case .setNoMatchingInfoPopup(let isOpened):
      newState.isOpenedNoMatchingInfoPopup = isOpened
      
    case .setNoMatchingInfoPopup_initial(let isOpened):
      newState.isOpenedNoMatchingInfoPopup_Initial = isOpened
      
    case .setMatchingMembers(let members):
      newState.matchingMembers = members
      newState.isLoading = false
      
    case let .setKakaoPopup(isOpened, link):
      newState.isOpenedKakaoPopup = (isOpened, link)
      
    case .setCurrentTextImage(let imageType):
      newState.currentTextImage = imageType
      
    case .setBackgroundColor(let swipeType):
      newState.backgroundColor = swipeType
      
    case .setBackgroundColor_withSwipe(let swipeType):
      newState.backgroundColor_withSwipe = swipeType
      
    case .setWeb(let isOpened):
      newState.isOpenedWeb = isOpened
      
    case .setBasicPopup(let isOpened):
      newState.isOpenedBasicPopup = isOpened
      
    case .setDismissPopup(let isDismissed):
      newState.dismissPopup = isDismissed
    }
    
    return newState
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
          return .just(.setMatchingMembers(members))
        default:
          return .just(.setMatchingMembers([]))
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
          return .just(.setMatchingMembers(members))
        default:
          return .just(.setMatchingMembers([]))
        }
      }
  }
}
