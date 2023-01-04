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
    case didTapKakaoButton(String)
  }
  
  enum Mutation {
    case setCurrentSort(MyPageEnumerations.Sort)
    case setCurrentMembers([MatchingDTO.Retrieve])
    case setLoading(Bool)
    case setBottomSheet(Bool)
    case setSafari(Bool, String)
    case setDismiss(Bool)
    case setKakaoPopup(Bool, String)
  }
  
  struct State {
    var currentSort: MyPageEnumerations.Sort = .lastest
    var currentMembers: [MatchingDTO.Retrieve] = []
    var isLoading: Bool = false
    var isOpenedBottomSheet: Bool = false
    var isOpenedSafari: (Bool, String) = (false, "")
    var isDismissed: Bool = false
    var isOpenedKakaoPopup: (Bool, String) = (false, "")
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
                  .just(.setLoading(false))
                ])
              default:
                return .concat([
                  .just(.setCurrentMembers([])),
                  .just(.setLoading(false))
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
                  .just(.setLoading(false))
                ])
              default:
                return .concat([
                  .just(.setCurrentMembers([])),
                  .just(.setLoading(false))
                ])
              }
            }
        ])
      }
      
    case .didTapPastButton:
      return .concat([
        .just(.setCurrentSort(.past)),
      ])
      
    case .didTapLastestButton:
      return .concat([
        .just(.setCurrentSort(.lastest)),
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
        .just(.setDismiss(true)),
        .just(.setDismiss(false)),
        .just(.setKakaoPopup(true, url)),
        .just(.setKakaoPopup(false, ""))
      ])
      
    case .didTapKakaoButton(let url):
      return .concat([
        .just(.setDismiss(true)),
        .just(.setDismiss(false)),
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
      
    case .setBottomSheet(let isOpened):
      newState.isOpenedBottomSheet = isOpened
      
    case let .setSafari(isOpened, url):
      newState.isOpenedSafari = (isOpened, url)
      
    case .setDismiss(let isDismissed):
      newState.isDismissed = isDismissed
      
    case let .setKakaoPopup(isOpened, url):
      newState.isOpenedKakaoPopup = (isOpened, url)
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
              .just(.setDismiss(true)),
              .just(.setDismiss(false)),
              .just(.setLoading(false))
            ])
          default:
            return .concat([
              .just(.setCurrentMembers([])),
              .just(.setDismiss(true)),
              .just(.setDismiss(false)),
              .just(.setLoading(false))
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
              .just(.setDismiss(true)),
              .just(.setDismiss(false)),
              .just(.setLoading(false))
            ])
          default:
            return .concat([
              .just(.setCurrentMembers([])),
              .just(.setDismiss(true)),
              .just(.setDismiss(false)),
              .just(.setLoading(false))
            ])
          }
        }
    }
  }
}
