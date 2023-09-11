//
//  ConfirmPwViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2022/12/23.
//

import UIKit

import RxSwift
import RxCocoa
import RxMoya
import ReactorKit

final class PasswordViewReactor: Reactor {
  
  enum ViewType {
    case findPassword
    case signUp
  }
  
  enum Action {
    case passwordTextFieldDidChange(String)
    case verifyPasswordTextFieldDidChange(String)
    case passwordTextFieldEditingDidEnd
  }
  
  enum Mutation {
    case setPassword(String)
    case setVerfiyPassword(String)
    case setValidateTextCount(Bool)
    case setValidateCompoundCondition(Bool)
    case setValidateAllConditions(Bool)
    case setValidationStates(count: Bool, compound: Bool)
  }
  
  struct State {
    var viewType: ViewType
    var password: String = ""
    var verifyPassword: String = ""
    var isValidatedToTextCount: Bool = false
    var isValidatedToCompoundCondition: Bool = false
    var isValidatedAllConditions: Bool = false
    var validationStates: (count: Bool, compound: Bool)?
  }
  
  // MARK: - Properties
  
  var initialState: State
  
  // MARK: - Initializer
  
  init(_ viewType: ViewType) {
    self.initialState = State(viewType: viewType)
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .passwordTextFieldDidChange(let password):
      return .concat([
        .just(.setPassword(password)),
        .just(.setValidateTextCount(password.count >= 8 && password.count <= 15)),
        .just(.setValidateCompoundCondition(
          ValidationManager.validate(password, validationType: .password)
        ))
      ])
      
    case .verifyPasswordTextFieldDidChange(let password):
      return .just(.setVerfiyPassword(password))
      
    case .passwordTextFieldEditingDidEnd:
      return .just(.setValidationStates(
        count: self.currentState.isValidatedToTextCount,
        compound: self.currentState.isValidatedToCompoundCondition
      ))
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setPassword(let password):
      newState.password = password
      
    case .setVerfiyPassword(let password):
      newState.verifyPassword = password
      
    case .setValidateTextCount(let isValidated):
      newState.isValidatedToTextCount = isValidated
      
    case .setValidateCompoundCondition(let isValidated):
      newState.isValidatedToCompoundCondition = isValidated
      
    case .setValidateAllConditions(let isValidated):
      newState.isValidatedAllConditions = isValidated
      
    case let .setValidationStates(count, compound):
      newState.validationStates = (count, compound)
    }
    
    return newState
  }
}
