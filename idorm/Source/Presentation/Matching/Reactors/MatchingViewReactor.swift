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
    case didTapFilterButton
    case didTapRefreshButton
    case didTapCancelButton
    case didTapMessageButton
    case didTapHeartButton
    case didTapBackButton
    case didChangePublicState(Bool)
  }
  
  enum Mutation {
    case updateIsLoading(Bool)
    case updateCurrentTextImage
    case updateNoPublicPopup(Bool)
    case updateNoMatchingInfoPopup(Bool)
    case updateNoMatchingInfoPopup_initial(Bool)
    case updateFilterVC(Bool)
    case updateMatchingMembers([MatchingDTO.Retrieve])
  }
  
  struct State {
    var matchingMembers: [MatchingDTO.Retrieve] = []
    var isLoading: Bool = false
    var noPublicPopup: Bool = false
    var noMatchingInfoPopup: Bool = false
    var noMatchingInfoPopup_Initial: Bool = false
    var filterVC: Bool = false
    var currentTextImage: MatchingImageViewType = .noMatchingCardInformation
  }
  
  let initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    let memberStorage = MemberStorage.shared
    
    switch action {
    case .viewDidLoad:
      if memberStorage.hasMatchingInfo {
        if memberStorage.isPublicMatchingInfo {
          return Observable.concat([
            .just(.updateIsLoading(true)),
            fetchMatchingMembers()
          ])
        } else {
          return Observable.concat([
            .just(.updateNoMatchingInfoPopup_initial(true)),
            .just(.updateNoMatchingInfoPopup_initial(false))
          ])
        }
      } else {
        
      }
      
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
              .just(.updateIsLoading(true)),
              fetchFilteredMembers()
            ])
          } else {
            return Observable.concat([
              .just(.updateIsLoading(true)),
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
      
      
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .updateFilterVC(let isOpened):
      newState.filterVC = isOpened
      
    case .updateNoPublicPopup(let isOpened):
      newState.noPublicPopup = isOpened
      
    case .updateNoMatchingInfoPopup(let isOpened):
      newState.noMatchingInfoPopup = isOpened
      
    case .updateNoMatchingInfoPopup_initial(let isOpened):
      newState.noMatchingInfoPopup_Initial = isOpened
      
    case .updateMatchingMembers(let members):
      newState.matchingMembers = members
    }
    
    return newState
  }
  
  func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
    let publicEvent = MemberStorage.shared.didChangePublicState
      .distinctUntilChanged()
      .flatMap { isPublic -> Observable<Mutation> in
        return .just(.updateNoPublicPopup(true))
      }
    return Observable.merge(mutation, publicEvent)
  }
}

extension MatchingViewReactor {
  private func fetchMatchingMembers() -> Observable<Mutation> {
    return APIService.matchingProvider.rx.request(.retrieve)
      .asObservable()
      .filterSuccessfulStatusCodes()
      .retry()
      .flatMap { response -> Observable<Mutation> in
        switch response.statusCode {
        case 200:
          let members = APIService.decode(ResponseModel<[MatchingDTO.Retrieve]>.self, data: response.data).data
          return Observable.concat([
            .just(.updateMatchingMembers(members)),
            .just(.updateIsLoading(false))
          ])
        case 204:
          return Observable.concat([
            .just(.updateMatchingMembers([])),
            .just(.updateIsLoading(false))
          ])
        default:
          break
        }
      }
  }
  
  private func fetchFilteredMembers() -> Observable<Mutation> {
    let filter = FilterStorage.shared.filter
    return APIService.matchingProvider.rx.request(.retrieveFiltered(filter: filter))
      .asObservable()
      .filterSuccessfulStatusCodes()
      .retry()
      .flatMap { response -> Observable<Mutation> in
        switch response.statusCode {
        case 200:
          let members = APIService.decode(ResponseModel<[MatchingDTO.Retrieve]>.self, data: response.data).data
          return Observable.concat([
            .just(.updateMatchingMembers(members)),
            .just(.updateIsLoading(false))
          ])
        case 204:
          return Observable.concat([
            .just(.updateMatchingMembers([])),
            .just(.updateIsLoading(false))
          ])
        default:
          break
        }
      }
  }
}
