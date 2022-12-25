//
//  CompleteSignupViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2022/12/25.
//

import Foundation

import RxSwift
import RxCocoa
import RxMoya
import ReactorKit

final class CompleteSignupViewReactor: Reactor {
  
  enum Action {
    case didTapContinueButton
  }
  
  enum Mutation {
    case setLoading(Bool)
    case setOnboardingVC(Bool)
  }
  
  struct State {
    var isLoading: Bool = false
    var isOpendOnboardingVC: Bool = false
  }
  
  var initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    let email = Logger.shared.email
    let password = Logger.shared.password
    
    switch action {
    case .didTapContinueButton:
      return .concat([
        .just(.setLoading(true)),
        APIService.memberProvider.rx.request(.login(id: email, pw: password))
          .asObservable()
          .retry()
          .map(ResponseModel<MemberDTO.Retrieve>.self)
          .flatMap { member -> Observable<Mutation> in
            let member = member.data
            TokenStorage.saveToken(token: member.loginToken ?? "")
            MemberStorage.shared.saveMember(member)
            return .concat([
              .just(.setLoading(false)),
              .just(.setOnboardingVC(true)),
              .just(.setOnboardingVC(false))
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
      
    case .setOnboardingVC(let isOpened):
      newState.isOpendOnboardingVC = isOpened
    }
    
    return newState
  }
}