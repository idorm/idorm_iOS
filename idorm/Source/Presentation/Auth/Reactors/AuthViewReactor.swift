//
//  AuthViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2022/12/23.
//

import UIKit

import RxSwift
import RxCocoa
import ReactorKit

final class AuthViewReactor: Reactor {
  
  enum Action {
    case viewDidLoad
    case cancelButtonDidTap
    case goMailBoxButtonDidTap
    case enterNumberButtonDidTap
  }
  
  enum Mutation {
    case setDismiss(Bool)
    case setAuthNumberVC(Bool)
  }
  
  struct State {
    @Pulse var shouldDismiss: Bool = false
    @Pulse var shouldNavigateToAuthNumberVC: Bool = false
  }
  
  // MARK: - Properties
  
  var initialState: State = State()
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      return .empty()
      
    case .cancelButtonDidTap:
      return .just(.setDismiss(true))
      
    case .goMailBoxButtonDidTap:
      guard
        let url = URL(string: "https://webmail.inu.ac.kr/member/login?host_domain=inu.ac.kr")
      else { return .empty() }
      UIApplication.shared.open(url)
      return .empty()
      
    case .enterNumberButtonDidTap:
      return .just(.setAuthNumberVC(true))
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setDismiss(let state):
      newState.shouldDismiss = state
      
    case .setAuthNumberVC(let mailTimerChecker):
      newState.shouldNavigateToAuthNumberVC = mailTimerChecker
    }
    
    return newState
  }
}
