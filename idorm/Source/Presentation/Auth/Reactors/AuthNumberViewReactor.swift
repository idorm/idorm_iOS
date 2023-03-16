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
    case didTapConfirmButton(String)
    case didTapRequestAuthButton
  }
  
  enum Mutation {
    case setLoading(Bool)
    case setPopVC(Bool)
    case setPopup(Bool, String)
  }
  
  struct State {
    var isLoading: Bool = false
    var isOpenedPopup: (Bool, String) = (false, "")
    var popVC: Bool = false
  }
  
  var initialState: State = State()
  private let timer: MailTimerChecker
  
  init(_ timer: MailTimerChecker) {
    self.timer = timer
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    let email = Logger.shared.email
    
    switch action {
    case .didTapConfirmButton(let number):
      switch Logger.shared.authProcess {
      case .signUp:
        return .concat([
          .just(.setLoading(true)),
          MailAPI.provider.rx.request(
            .emailVerification(email: email, code: number)
          )
            .asObservable()
            .retry()
            .flatMap { response -> Observable<Mutation> in
              switch response.statusCode {
              case 200:
                return .concat([
                  .just(.setLoading(false)),
                  .just(.setPopVC(true))
                ])
              default:
                let message = MailAPI.decode(
                  ErrorResponseModel.self,
                  data: response.data
                ).responseMessage
                return .concat([
                  .just(.setLoading(false)),
                  .just(.setPopup(true, message)),
                  .just(.setPopup(false, ""))
                ])
              }
            }
        ])
        
      case .findPw:
        return .concat([
          .just(.setLoading(true)),
          MailAPI.provider.rx.request(
            .pwVerification(email: email, code: number)
          )
            .asObservable()
            .retry()
            .flatMap { response -> Observable<Mutation> in
              switch response.statusCode {
              case 200:
                return .concat([
                  .just(.setLoading(false)),
                  .just(.setPopVC(true))
                ])
              default:
                let message = MailAPI.decode(
                  ErrorResponseModel.self,
                  data: response.data
                ).responseMessage
                return .concat([
                  .just(.setLoading(false)),
                  .just(.setPopup(true, message)),
                  .just(.setPopup(false, ""))
                ])
              }
            }
        ])
      }
      
    case .didTapRequestAuthButton:
      switch Logger.shared.authProcess {
      case .signUp:
        return .concat([
          .just(.setLoading(true)),
          MailAPI.provider.rx.request(
            .emailAuthentication(email: email)
          )
            .asObservable()
            .retry()
            .filterSuccessfulStatusCodes()
            .withUnretained(self)
            .flatMap { owner, _ -> Observable<Mutation> in
              owner.timer.restart()
              return .just(.setLoading(false))
            }
        ])
        
      case .findPw:
        return .concat([
          .just(.setLoading(true)),
          MailAPI.provider.rx.request(
            .pwAuthentication(email: email)
          )
            .asObservable()
            .retry()
            .filterSuccessfulStatusCodes()
            .withUnretained(self)
            .flatMap { owner, _ -> Observable<Mutation> in
              owner.timer.restart()
              return .just(.setLoading(false))
            }
        ])
      }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setLoading(let isLoading):
      newState.isLoading = isLoading
      
    case let .setPopup(isOpened, message):
      newState.isOpenedPopup = (isOpened, message)
      
    case .setPopVC(let isOpened):
      newState.popVC = isOpened
    }
    
    return newState
  }
}
