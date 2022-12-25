//
//  PutEmailViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2022/12/23.
//

import Foundation

import RxSwift
import ReactorKit
import RxMoya

final class PutEmailViewReactor: Reactor {
  
  enum Action {
    case didTapReceiveButton(String, RegisterEnumerations)
  }
  
  enum Mutation {
    case setLoading(Bool)
    case setAuthVC(Bool)
    case setPopup(Bool, String)
  }
  
  struct State {
    var isLoading: Bool = false
    var isOpenedAuthVC: Bool = false
    var isOpenedPopup: (Bool, String) = (false, "")
  }
  
  var initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case let .didTapReceiveButton(email, type):
      Logger.shared.saveEmail(email)
      switch type {
      case .signUp:
        return .concat([
          .just(.setLoading(true)),
          APIService.emailProvider.rx.request(.emailAuthentication(email: email))
            .asObservable()
            .retry()
            .flatMap { response -> Observable<Mutation> in
              switch response.statusCode {
              case 200:
                Logger.shared.saveAuthenticationType(.signUp)
                return .concat([
                  .just(.setLoading(false)),
                  .just(.setAuthVC(true)),
                  .just(.setAuthVC(false))
                ])
              default:
                let errorMessage = APIService.decode(ErrorResponseModel.self, data: response.data).message
                return .concat([
                  .just(.setLoading(false)),
                  .just(.setPopup(true, errorMessage)),
                  .just(.setPopup(false, errorMessage))
                ])
              }
            }
        ])
      default:
        return .concat([
          .just(.setLoading(true)),
          APIService.emailProvider.rx.request(.pwAuthentication(email: email))
            .asObservable()
            .retry()
            .flatMap { response -> Observable<Mutation> in
              switch response.statusCode {
              case 200:
                Logger.shared.saveAuthenticationType(.findPw)
                return .concat([
                  .just(.setLoading(false)),
                  .just(.setAuthVC(true)),
                  .just(.setAuthVC(false))
                ])
              default:
                let errorMessage = APIService.decode(ErrorResponseModel.self, data: response.data).message
                return .concat([
                  .just(.setLoading(false)),
                  .just(.setPopup(true, errorMessage)),
                  .just(.setPopup(false, errorMessage))
                ])
              }
            }
        ])
      }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case let .setPopup(isOpened, message):
      newState.isOpenedPopup = (isOpened, message)
      
    case .setLoading(let isLoading):
      newState.isLoading = isLoading
      
    case .setAuthVC(let isOpened):
      newState.isOpenedAuthVC = isOpened
    }
    
    return newState
  }
}
