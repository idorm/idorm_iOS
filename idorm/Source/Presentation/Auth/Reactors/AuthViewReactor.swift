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
    case portal
    case next
    case dismiss
  }
  
  enum Mutation {
    case setSafari(Bool)
    case setAuthNumberVC(Bool)
    case setDismiss(Bool)
  }
  
  struct State {
    var isOpenedSafari: Bool = false
    var isOpenedAuthNumberVC: Bool = false
    var isDismiss: Bool = false
  }
  
  var initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .portal:
      return .concat([
        .just(.setSafari(true)),
        .just(.setSafari(false))
      ])
      
    case .next:
      return .concat([
        .just(.setAuthNumberVC(true)),
        .just(.setAuthNumberVC(false))
      ])
      
    case .dismiss:
      return .concat([
        .just(.setDismiss(true)),
        .just(.setDismiss(false))
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
      
    case .setDismiss(let isDismiss):
      newState.isDismiss = isDismiss
    }
    
    return newState
  }
}
