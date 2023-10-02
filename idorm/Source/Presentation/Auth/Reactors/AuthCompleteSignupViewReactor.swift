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

final class AuthCompleteSignupViewReactor: Reactor {
  
  enum Action {
    case continueButtonDidTap
  }
  
  enum Mutation {
    case setOnboardingVC(Bool)
  }
  
  struct State {
    @Pulse var navigateToOnboardingVC: Bool = false
  }
  
  // MARK: - Properties
  
  var initialState: State = State()
  private let memberNetworkService = NetworkService<MemberAPI>()
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    let email = Logger.shared.email
    let password = Logger.shared.password
    switch action {
    case .continueButtonDidTap:
      return self.memberNetworkService.requestAPI(
        to: .login(email: email, password: password)
      )
      .flatMap { response in
        do {
          let response = try response.filterSuccessfulStatusCodes()
          let responseDTO = NetworkUtility.decode(
            ResponseDTO<MemberSingleResponseDTO>.self,
            data: response.data
          )
          let token = response.response?.headers["authorization"]
          UserStorage.shared.member = Member(responseDTO.data)
          UserStorage.shared.email = email
          UserStorage.shared.password = password
          UserStorage.shared.token = token!
          return Observable<Mutation>.just(.setOnboardingVC(true))
        } catch (let error) {
          print(error.localizedDescription)
          return .empty()
        }
      }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setOnboardingVC(let state):
      newState.navigateToOnboardingVC = state
    }
    
    return newState
  }
}
