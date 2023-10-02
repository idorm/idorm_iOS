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

final class AuthPasswordViewReactor: Reactor {
  
  enum ViewType {
    case findPassword
    case changePassword
    case signUp
  }
  
  enum Action {
    case passwordTextFieldDidChange(String)
    case verifyPasswordTextFieldDidChange(String)
    case passwordTextFieldEditingDidEnd
    case verifyPasswordTextFieldEditingDidEnd
    case continueButtonDidTap
  }
  
  enum Mutation {
    case setPassword(String)
    case setVerfiyPassword(String)
    case setValidateTextCount(Bool)
    case setValidateCompoundCondition(Bool)
    case setValidateAllConditions(Bool)
    case setValidationStates(count: Bool, compound: Bool)
    case setSameAsPassword(Bool)
    case setNicknameVC(Bool)
    case setRootVC(Bool)
  }
  
  struct State {
    var viewType: ViewType
    var password: String = ""
    var verifyPassword: String = ""
    var isValidatedToTextCount: Bool = false
    var isValidatedToCompoundCondition: Bool = false
    var isValidatedAllConditions: Bool = false
    var isSameAsPassword: Bool = false
    @Pulse var navigateToRootVC: Bool = false
    @Pulse var navigateToNicknameVC: Bool = false
    @Pulse var validationStates: (count: Bool, compound: Bool)?
  }
  
  // MARK: - Properties
  
  var initialState: State
  private let memberNetworkService = NetworkService<MemberAPI>()
  
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
      
    case .verifyPasswordTextFieldEditingDidEnd:
      return .just(.setSameAsPassword(
        self.currentState.password == self.currentState.verifyPassword
      ))
      
    case .passwordTextFieldEditingDidEnd:
      return .just(.setValidationStates(
        count: self.currentState.isValidatedToTextCount,
        compound: self.currentState.isValidatedToCompoundCondition
      ))
      
    case .continueButtonDidTap:
      guard self.currentState.isValidatedAllConditions else {
        ModalManager.presentPopupVC(.alert(.oneButton(contents: "조건을 다시 확인해주세요.")))
        return .empty()
      }
      switch self.currentState.viewType {
      case .findPassword: // 비밀번호 찾기
        return self.memberNetworkService.requestAPI(to: .updatePassword(
          email: Logger.shared.email,
          password: self.currentState.password
        )).flatMap { _ in
          return Observable<Mutation>.just(.setRootVC(true))
        }
        
      case .changePassword: // 비밀번호 변경
        return self.memberNetworkService.requestAPI(to: .updatePassword(
          email: UserStorage.shared.email!,
          password: self.currentState.password
        )).flatMap { _ in
          return Observable<Mutation>.just(.setRootVC(true))
        }
        
      case .signUp: // 회원 가입
        Logger.shared.savePassword(self.currentState.password)
        return .just(.setNicknameVC(true))
      }
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
      
    case .setSameAsPassword(let isSame):
      newState.isSameAsPassword = isSame
      
    case .setNicknameVC(let state):
      newState.navigateToNicknameVC = state
      
    case .setRootVC(let state):
      newState.navigateToRootVC = state
    }
    
    return newState
  }
  
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      
      newState.isSameAsPassword = state.password == state.verifyPassword ? true : false
      
      if newState.isSameAsPassword,
         newState.isValidatedToTextCount,
         newState.isValidatedToCompoundCondition {
        newState.isValidatedAllConditions = true
      } else {
        newState.isValidatedAllConditions = false
      }
      
      return newState
    }
  }
}
