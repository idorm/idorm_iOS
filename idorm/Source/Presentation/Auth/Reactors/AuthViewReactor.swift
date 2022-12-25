//
//  AuthViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2022/12/23.
//

import Foundation

import RxSwift
import RxCocoa
import ReactorKit

final class AuthViewReactor: Reactor {
  
  enum Action {
    case didTapPortalButton
    case didTapConfirmButton
  }
  
  enum Mutation {
    case setSafari(Bool)
    case setAuthNumberVC(Bool)
  }
  
  struct State {
    var isOpenedSafari: Bool = false
    var isOpenedAuthNumberVC: Bool = false
  }
  
  var initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .didTapPortalButton:
      return .concat([
        .just(.setSafari(true)),
        .just(.setSafari(false))
      ])
      
    case .didTapConfirmButton:
      return .concat([
        .just(.setAuthNumberVC(true)),
        .just(.setAuthNumberVC(false))
      ])
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setSafari(let isOpened):
      newState.isOpenedSafari = isOpened
      
    case .setAuthNumberVC(let isOpened):
      newState.isOpenedAuthNumberVC = isOpened
    }
    
    return newState
  }
}
