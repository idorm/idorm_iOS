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

final class EmailViewReactor: Reactor {
  
  enum Action {
    case next(String, AuthProcess)
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
  
  // MARK: - PROPERTIES
  
  var initialState: State = State()
  
  // MARK: - HELPERS
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case let .next(email, authProcess):
      switch authProcess {
      case .signUp: // 회원가입
        return .concat([
          .just(.setLoading(true)),
          MailAPI.provider.rx.request(.emailAuthentication(email: email))
            .asObservable()
            .flatMap { response -> Observable<Mutation> in
              switch response.statusCode {
              case 200..<300: // 메일 전송 성공
                Logger.shared.saveAuthProcess(.signUp)
                Logger.shared.saveEmail(email)
                return .concat([
                  .just(.setLoading(false)),
                  .just(.setAuthVC(true)),
                  .just(.setAuthVC(false))
                ])
              default: // 메일 전송 실패
                let errorMessage = MailAPI.decode(
                  ErrorResponseModel.self,
                  data: response.data
                ).responseMessage
                return .concat([
                  .just(.setLoading(false)),
                  .just(.setPopup(true, errorMessage)),
                  .just(.setPopup(false, errorMessage))
                ])
              }
            }
        ])
      case .findPw: // 비밀번호 찾기
        return .concat([
          .just(.setLoading(true)),
          MailAPI.provider.rx.request(.pwAuthentication(email: email))
            .asObservable()
            .flatMap { response -> Observable<Mutation> in
              switch response.statusCode {
              case 200..<300: // 메일 전송 성공
                Logger.shared.saveAuthProcess(.findPw)
                Logger.shared.saveEmail(email)
                return .concat([
                  .just(.setLoading(false)),
                  .just(.setAuthVC(true)),
                  .just(.setAuthVC(false))
                ])
              default: // 메일 전송 실패
                let errorMessage = MailAPI.decode(
                  ErrorResponseModel.self,
                  data: response.data
                ).responseMessage
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
