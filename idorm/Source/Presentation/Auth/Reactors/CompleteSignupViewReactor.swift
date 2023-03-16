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
        MemberAPI.provider.rx.request(
          .login(email: email, password: password, fcmToken: "")
        )
          .asObservable()
          .retry()
          .flatMap { response -> Observable<Mutation> in
            switch response.statusCode {
            case 200..<300:
              let responseModel = MemberAPI.decode(
                ResponseModel<MemberResponseModel.Member>.self,
                data: response.data
              ).data
              let token = response.response?.headers["authorization"]
              UserStorage.shared.saveMember(responseModel)
              UserStorage.shared.saveToken(token)
              return .concat([
                .just(.setLoading(false)),
                .just(.setOnboardingVC(true)),
                .just(.setOnboardingVC(false))
              ])
            default:
              fatalError("Login is Failed!")
            }
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
