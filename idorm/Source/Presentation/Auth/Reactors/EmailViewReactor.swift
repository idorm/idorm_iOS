//
//  PutEmailViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2022/12/23.
//

import Foundation

import RxSwift
import RxMoya
import ReactorKit

final class EmailViewReactor: Reactor {
  
  enum ViewType {
    case signUp
    case changePassword
    case findPassword
  }
  
  enum Action {
    case emailTextFieldDidChange(String)
    case continueButtonDidTap
  }
  
  enum Mutation {
    case setAuthVC(Bool)
    case setEmail(String)
  }
  
  struct State {
    var viewType: ViewType
    var email: String = ""
    @Pulse var shouldPresentToAuthVC: Bool = false
  }
  
  // MARK: - Properties
  
  var initialState: State
  private let viewType: ViewType
  private let mailNetworkService = NetworkService<MailAPI>()
  
  // MARK: - Initailizer
  
  init(_ viewType: ViewType) {
    self.viewType = viewType
    self.initialState = State(viewType: viewType)
  }
  
  // MARK: - HELPERS
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .emailTextFieldDidChange(let email):
      return .just(.setEmail(email))
      
    case .continueButtonDidTap:
      let email = self.currentState.email
      switch self.currentState.viewType {
      case .changePassword:
        return .empty()
      case .findPassword:
        return self.mailNetworkService.requestAPI(to: .pwAuthentication(email: email))
          .flatMap { _ in
            Logger.shared.saveEmail(email)
            Logger.shared.saveAuthProcess(.findPw)
            MailStopWatchManager.shared.start()
            return Observable<Mutation>.just(.setAuthVC(true))
          }
      case .signUp:
        return self.mailNetworkService.requestAPI(to: .emailAuthentication(email: email))
          .flatMap {_ in
            Logger.shared.saveAuthProcess(.signUp)
            Logger.shared.saveEmail(email)
            MailStopWatchManager.shared.start()
            return Observable<Mutation>.just(.setAuthVC(true))
          }
      }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setEmail(let email):
      newState.email = email
      
    case .setAuthVC(let state):
      newState.shouldPresentToAuthVC = state
    }
    
    return newState
  }
}
