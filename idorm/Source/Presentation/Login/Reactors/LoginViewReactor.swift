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
    case didTapLoginButton(String, String)
    case didTapForgotPwButton
    case didTapSignupButton
  }
  
  enum Mutation {
    case setLoading(Bool)
    case setPopup(Bool, String)
    case setMainVC(Bool)
    case setPutEmailVC(Bool , RegisterEnumerations)
  }
  
  struct State {
    var isLoading: Bool = false
    var isOpenedPopup: (Bool, String) = (false, "")
    var isOpenedMainVC: Bool = false
    var isOpenedPutEmailVC: (Bool, RegisterEnumerations) = (false, .findPw)
  }
  
  var initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case let .didTapLoginButton(id, pw):
      return .concat([
        .just(.setLoading(true)),
        APIService.memberProvider.rx.request(.login(id: id, pw: pw))
          .asObservable()
          .retry()
          .flatMap { response -> Observable<Mutation> in
            switch response.statusCode {
            case 200:
              let data = APIService.decode(ResponseModel<MemberDTO.Retrieve>.self, data: response.data).data
              MemberStorage.shared.saveMember(data)
              TokenStorage.saveToken(token: data.loginToken ?? "")
              return .concat([
                .just(.setLoading(false)),
                .just(.setMainVC(true)),
                .just(.setMainVC(false))
              ])
            default:
              let message = APIService.decode(ErrorResponseModel.self, data: response.data).message
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