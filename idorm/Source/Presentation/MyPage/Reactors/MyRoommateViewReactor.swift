//
//  MyRoommateViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2022/12/21.
//

import Foundation

import RxSwift
import RxCocoa
import RxMoya
import ReactorKit

final class MyRoommateViewReactor: Reactor {
  
  enum Action {
    case viewDidLoad(MyPageEnumerations.Roommate)
    case didTapLastestButton
    case didTapPastButton
    case didTapDeleteButton(MyPageEnumerations.Roommate, Int)
    case didTapChatButton(String)
  }
  
  enum Mutation {
    case setCurrentSort(MyPageEnumerations.Sort)
    case setCurrentMembers([MatchingDTO.Retrieve])
    case setLoading(Bool)
    case setReloadData(Bool)
    case setBottomSheet(Bool)
    case setSafari(Bool, String)
    case setPopup(Bool)
    case setDismissBottomSheet(Bool)
  }
  
  struct State {
    var currentSort: MyPageEnumerations.Sort = .lastest
    var currentMembers: [MatchingDTO.Retrieve] = []
    var isLoading: Bool = false
    var isOpenedBottomSheet: Bool = false
    var isOpenedSafari: (Bool, String) = (false, "")
    var isOpenedPopup: Bool = false
    var isDismissedBottomSheet: Bool = false
    var reloadData: Bool = false
  }
  
  var initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad(let roommate):
      switch roommate {
      case .dislike:
        
        return .concat([
          .just(.setLoading(true)),
          APIService.matchingProvider.rx.request(.retrieveDisliked)
            .asObservable()
            .retry()
            .flatMap { response -> Observable<Mutation> in
              switch response.statusCode {
              case 200:
                let members = APIService.decode(ResponseModel<[MatchingDTO.Retrieve]>.self, data: response.data).data
                return .concat([
                  .just(.setCurrentMembers(members)),
                  .just(.setReloadData(true)),
                  .just(.setReloadData(false))
                ])
              default:
                return .concat([
                  .just(.setCurrentMembers([])),
                  .just(.setReloadData(true)),
                  .just(.setReloadData(false))
                ])
              }
            }
        ])
        
      case .like:
        return .concat([
          .just(.setLoading(true)),
          APIService.matchingProvider.rx.request(.retrieveLiked)
            .asObservable()
            .retry()
            .flatMap { response -> Observable<Mutation> in
              switch response.statusCode {
              case 200:
                let members = APIService.decode(ResponseModel<[MatchingDTO.Retrieve]>.self, data: response.data).data
                return .concat([
                  .just(.setCurrentMembers(members)),
                  .just(.setReloadData(true)),
                  .just(.setReloadData(false))
                ])
              default:
                return .concat([
                  .just(.setCurrentMembers([])),
                  .just(.setReloadData(true)),
                  .just(.setReloadData(false))
                ])
              }
            }
        ])
      }
      
    case .didTapPastButton:
      return .concat([
        .just(.setCurrentSort(.past)),
        .just(.setReloadData(true)),
        .just(.setReloadData(false))
      ])
      
    case .didTapLastestButton:
      return .concat([
        .just(.setCurrentSort(.lastest)),
        .just(.setReloadData(true)),
        .just(.setReloadData(false))
      ])
      
    case let .didTapDeleteButton(roommate, id):
      switch roommate {
      case .like:
        return .concat([
          .just(.setLoading(true)),
          APIService.matchingProvider.rx.request(.deleteLiked(id))
            .asObservable()
            .retry()
            .filterSuccessfulStatusCodes()
            .withUnretained(self)
            .flatMap { $0.0.fetchMembers(roommate) }
        ])
      case .dislike:
        return .concat([
          .just(.setLoading(true)),
          APIService.matchingProvider.rx.request(.deleteDisliked(id))
            .asObservable()
            .retry()
            .filterSuccessfulStatusCodes()
            .withUnretained(self)
            .flatMap { $0.0.fetchMembers(roommate) }
        ])
      }
      
    case .didTapChatButton(let url):
      return .concat([
        .just(.setDismissBottomSheet(true)),
        .just(.setDismissBottomSheet(false)),
        .just(.setSafari(true, url)),
        .just(.setSafari(false, ""))
      ])
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setCurrentSort(let sort):
      newState.currentMembers = currentState.currentMembers.reversed()
      newState.currentSort = sort
      
    case .setLoading(let isLoading):
      newState.isLoading = isLoading
      
    case .setCurrentMembers(let members):
      newState.currentMembers = members
      newState.isLoading = false
      newState.reloadData = false
      
    case .setReloadData(let reloadData):
      newState.reloadData = reloadData
      
    case .setBottomSheet(let isOpened):
      newState.isOpenedBottomSheet = isOpened
      
    case let .setSafari(isOpened, url):
      newState.isOpenedSafari = (isOpened, url)
      
    case .setPopup(let isOpened):
      newState.isOpenedPopup = isOpened
      
    case .setDismissBottomSheet(let isDismissed):
      newState.isDismissedBottomSheet = isDismissed
    }
    
    return newState
  }
}

extension MyRoommateViewReactor {
  private func fetchMembers(_ roommate: MyPageEnumerations.Roommate) -> Observable<Mutation> {
    switch roommate {
    case .like:
      return APIService.matchingProvider.rx.request(.retrieveLiked)
        .asObservable()
        .retry()
        .flatMap { response -> Observable<Mutation> in
          switch response.statusCode {
          case 200:
            let members = APIService.decode(ResponseModel<[MatchingDTO.Retrieve]>.self, data: response.data).data
            return .concat([
              .just(.setCurrentMembers(members)),
              .just(.setDismissBottomSheet(true)),
              .just(.setDismissBottomSheet(false)),
              .just(.setReloadData(true)),
              .just(.setReloadData(false))
            ])
          default:
            return .concat([
              .just(.setCurrentMembers([])),
              .just(.setDismissBottomSheet(true)),
              .just(.setDismissBottomSheet(false)),
              .just(.setReloadData(true)),
              .just(.setReloadData(false))
            ])
          }
        }
    case .dislike:
      return APIService.matchingProvider.rx.request(.retrieveDisliked)
        .asObservable()
        .retry()
        .flatMap { response -> Observable<Mutation> in
          switch response.statusCode {
          case 200:
            let members = APIService.decode(ResponseModel<[MatchingDTO.Retrieve]>.self, data: response.data).data
            return .concat([
              .just(.setCurrentMembers(members)),
              .just(.setDismissBottomSheet(true)),
              .just(.setDismissBottomSheet(false)),
              .just(.setReloadData(true)),
              .just(.setReloadData(false))
            ])
          default:
            return .concat([
              .just(.setCurrentMembers([])),
              .just(.setDismissBottomSheet(true)),
              .just(.setDismissBottomSheet(false)),
              .just(.setReloadData(true)),
              .just(.setReloadData(false))
            ])
          }
        }
    }
  }
}
