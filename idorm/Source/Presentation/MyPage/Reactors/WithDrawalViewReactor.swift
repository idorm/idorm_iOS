//
//  WithDrawalViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2022/12/22.
//

import Foundation

import RxSwift
import RxCocoa
import ReactorKit
import RxMoya

final class WithDrawalViewReactor: Reactor {
  
  enum Action {
    case didTapWithDrawalButton
  }
  
  enum Mutation {
    case setLoading(Bool)
    case setPopup(Bool)
  }
  
  struct State {
    var isLoading: Bool = false
    var isOpenedPopup: Bool = false
  }
  
  var initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .didTapWithDrawalButton:
      return .concat([
        .just(.setLoading(true)),
        MemberAPI.provider.rx.request(.deleteUser)
          .asObservable()
          .retry()
          .filterSuccessfulStatusCodes()
          .flatMap { _ -> Observable<Mutation> in
            TokenStorage.removeToken()
            return .concat([
              .just(.setPopup(true)),
              .just(.setPopup(false))
            ])
          }
      ])
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setLoading(let isLoading):
      newState.isLoading = isLoading
      
    case .setPopup(let isOpened):
      newState.isOpenedPopup = isOpened
    }
    
    return newState
  }
}
