//
//  TermsOfServiceViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2023/01/02.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift
import RxMoya

final class AuthTermsOfServiceViewReactor: Reactor {
  
  enum Action {
    case continueButtonDidTap
    case termsOfServiceButtonDidTap
    case viewLabelDidTap
  }
  
  enum Mutation {
    case setTermsOfServiceButton(Bool)
    case setCompleteSignUpVC(Bool)
  }
  
  struct State {
    @Pulse var isSelectedTermsOfServiceButton: Bool = false
    @Pulse var navigateToCompleteSignUpVC: Bool = false
  }
  
  // MARK: - Properties
  
  var initialState: State = State()
  private let memberNetworkService = NetworkService<MemberAPI>()
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    let email = Logger.shared.email
    let password = Logger.shared.password
    let nickname = Logger.shared.nickname
    
    switch action {
    case .termsOfServiceButtonDidTap:
      return .just(.setTermsOfServiceButton(!self.currentState.isSelectedTermsOfServiceButton))
      
    case .continueButtonDidTap:
      return self.memberNetworkService.requestAPI(
        to: .register(email: email, password: password, nickname: nickname)
      )
      .map(ResponseDTO<MemberSingleResponseDTO>.self)
      .flatMap { responseDTO in
        UserStorage.shared.member = Member(responseDTO.data)
        return Observable<Mutation>.just(.setCompleteSignUpVC(true))
      }
      
    case .viewLabelDidTap:
//      UIApplication.shared.open(
//        URL(string: "https://idorm.notion.site/e5a42262cf6b4665b99bce865f08319b")
//      )
      return .empty()
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setTermsOfServiceButton(let isSelected):
      newState.isSelectedTermsOfServiceButton = isSelected
      
    case .setCompleteSignUpVC(let isNavigated):
      newState.navigateToCompleteSignUpVC = isNavigated
    }
    
    return newState
  }
}
