//
//  AuthNumberViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2022/12/24.
//

import Foundation

import RxSwift
import RxCocoa
import ReactorKit
import RxMoya

final class AuthNumberViewReactor: Reactor {
  
  enum Action {
    case textFieldDidChange(String)
    case requestAuthNumberButtonDidTap
    case continueButtonDidTap
  }
  
  enum Mutation {
    case setAuthenticationNumber(String)
    case setDismiss(Bool)
  }
  
  struct State {
    var authenticationNumber: String = ""
    @Pulse var shouldDismiss: Bool = false
  }
  
  // MARK: - Properties
  
  var initialState: State = State()
  private let mailNetworkService = NetworkService<MailAPI>()
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    let email = Logger.shared.email
    
    switch action {
    case .textFieldDidChange(let number):
      return .just(.setAuthenticationNumber(number))
      
    case .continueButtonDidTap:
      switch Logger.shared.authProcess {
      case .findPw: // 비밀번호 찾기
        return self.mailNetworkService.requestAPI(to: .pwVerification(
          email: email,
          code: self.currentState.authenticationNumber
        )).flatMap { _ in return Observable<Mutation>.just(.setDismiss(true)) }
        
      case .signUp: // 회원가입
        return self.mailNetworkService.requestAPI(to: .emailVerification(
          email: email,
          code: self.currentState.authenticationNumber
        )).flatMap { _ in return Observable<Mutation>.just(.setDismiss(true)) }
      }
      
    case .requestAuthNumberButtonDidTap:
      switch Logger.shared.authProcess {
      case .signUp:
        return self.mailNetworkService.requestAPI(to: .emailAuthentication(email: email))
          .flatMap { _ in
            MailStopWatchManager.shared.reset()
            return Observable<Mutation>.empty()
          }
        
      case .findPw:
        return self.mailNetworkService.requestAPI(to: .pwAuthentication(email: email))
          .flatMap { _ in
            MailStopWatchManager.shared.reset()
            return Observable<Mutation>.empty()
          }
      }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
      var newState = state
      
      switch mutation {
      case .setAuthenticationNumber(let number):
        newState.authenticationNumber = number
        
      case .setDismiss(let state):
        newState.shouldDismiss = state
      }
      
      return newState
    }
  }
}
