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
    case setLoginVC(Bool)
  }
  
  struct State {
    var isLoading: Bool = false
    var isOpenedLoginVC: Bool = false
  }
  
  var initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .didTapWithDrawalButton:
      return .concat([
        .just(.setLoading(true)),
        APIService.memberProvider.rx.request(.withdrawal)
          .asObservable()
          .retry()
          .filterSuccessfulStatusCodes()
          .flatMap { _ in Observable<Mutation>.just(.setLoginVC(true)) }
      ])
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setLoading(let isLoading):
      newState.isLoading = isLoading
      
    case .setLoginVC(let isOpened):
      newState.isOpenedLoginVC = isOpened
    }
    
    return newState
  }
}
