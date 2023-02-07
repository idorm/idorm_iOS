//
//  LoginViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2022/12/21.
//

import Foundation

import RxSwift
import RxCocoa
import RxMoya
import ReactorKit

final class LoginViewReactor: Reactor {
  
  enum Action {
    case viewDidLoad
    case didTapLoginButton(String, String)
    case didTapForgotPwButton
    case didTapSignupButton
  }
  
  enum Mutation {
    case setLoading(Bool)
    case setPopup(Bool, String)
    case setMainVC(Bool)
    case setPutEmailVC(Bool , Register)
  }
  
  struct State {
    var isLoading: Bool = false
    var isOpenedPopup: (Bool, String) = (false, "")
    var isOpenedMainVC: Bool = false
    var isOpenedPutEmailVC: (Bool, Register) = (false, .findPw)
  }
  
  var initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {      
    case .viewDidLoad:
      TokenStorage.removeToken()
      return .empty()
      
    case let .didTapLoginButton(id, pw):
      return .concat([
        .just(.setLoading(true)),
        MemberAPI.provider.rx.request(.login(id: id, pw: pw))
          .asObservable()
          .retry()
          .withUnretained(self)
          .flatMap { owner, response -> Observable<Mutation> in
            switch response.statusCode {
            case 200..<300:
              UserStorage.saveEmail(from: id)
              UserStorage.savePassword(from: pw)
              MemberAPI.loginProcess(response)
              return owner.retrieveMatchingInfo()
            default:
              let message = MemberAPI.decode(
                ErrorResponseModel.self,
                data: response.data
              ).message
              return .concat([
                .just(.setLoading(false)),
                .just(.setPopup(true, message)),
                .just(.setPopup(false, ""))
              ])
            }
          }
      ])
      
    case .didTapSignupButton:
      return .concat([
        .just(.setPutEmailVC(true, .signUp)),
        .just(.setPutEmailVC(false, .signUp))
      ])
      
    case .didTapForgotPwButton:
      return .concat([
        .just(.setPutEmailVC(true, .findPw)),
        .just(.setPutEmailVC(false, .findPw))
      ])
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setLoading(let isLoading):
      newState.isLoading = isLoading
      
    case let .setPopup(isOpened, message):
      newState.isOpenedPopup = (isOpened, message)
      
    case .setMainVC(let isOpened):
      newState.isOpenedMainVC = isOpened
      
    case let .setPutEmailVC(isOpened, type):
      newState.isOpenedPutEmailVC = (isOpened, type)
    }
    
    return newState
  }
}

extension LoginViewReactor {
  private func retrieveMatchingInfo() -> Observable<Mutation> {
    MatchingInfoAPI.provider.rx.request(.retrieve)
      .asObservable()
      .retry()
      .flatMap { response -> Observable<Mutation> in
        switch response.statusCode {
        case 200..<300:
          let matchingInfo = MatchingInfoAPI.decode(
            ResponseModel<MatchingInfoResponseModel.MatchingInfo>.self,
            data: response.data
          ).data
          MemberStorage.shared.saveMatchingInfo(matchingInfo)
          return .concat([
            .just(.setLoading(false)),
            .just(.setMainVC(true)),
            .just(.setMainVC(false))
          ])
        default:
          return .concat([
            .just(.setLoading(false)),
            .just(.setMainVC(true)),
            .just(.setMainVC(false))
          ])
        }
      }
  }
}
