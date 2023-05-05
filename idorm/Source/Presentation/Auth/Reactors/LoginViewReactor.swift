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
    case signIn(String, String)
    case signUp
    case forgotPassword
  }
  
  enum Mutation {
    case setLoading(Bool)
    case setPopup(Bool, String)
    case setMainVC(Bool)
    case setPutEmailVC(Bool , AuthProcess)
  }
  
  struct State {
    var isLoading: Bool = false
    var isOpenedPopup: (Bool, String) = (false, "")
    var isOpenedMainVC: Bool = false
    var isOpenedPutEmailVC: (Bool, AuthProcess) = (false, .findPw)
  }
  
  var initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
//      TokenStorage.removeToken()
      return .empty()
      
    case let .signIn(email, password):
      return .concat([
        .just(.setLoading(true)),
        MemberAPI.provider.rx.request(
          .login(email: email, password: password, fcmToken: TokenManager.shared.fcmToken!)
        )
          .asObservable()
          .withUnretained(self)
          .flatMap { owner, response -> Observable<Mutation> in
            switch response.statusCode {
            case 200..<300: // 로그인 성공
              let member = MemberAPI.decode(
                ResponseModel<MemberResponseModel.Member>.self,
                data: response.data
              ).data
              let token = response.response?.headers.value(for: "authorization")
              UserStorage.shared.saveMember(member)
              UserStorage.shared.saveEmail(email)
              UserStorage.shared.savePassword(password)
              UserStorage.shared.saveToken(token!)
              
              return owner.lookUpMatchingInfo()
            default: // 로그인 실패
              let errorMessage = MemberAPI.decode(
                ErrorResponseModel.self,
                data: response.data
              ).responseMessage
              return .concat([
                .just(.setLoading(false)),
                .just(.setPopup(true, errorMessage)),
                .just(.setPopup(false, ""))
              ])
            }
          }
      ])
      
    case .signUp:
      return .concat([
        .just(.setPutEmailVC(true, .signUp)),
        .just(.setPutEmailVC(false, .signUp))
      ])
      
    case .forgotPassword:
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
  private func lookUpMatchingInfo() -> Observable<Mutation> {
    MatchingInfoAPI.provider.rx.request(.retrieve)
      .asObservable()
      .flatMap { response -> Observable<Mutation> in
        switch response.statusCode {
        case 200..<300: // 조회 성공
          let matchingInfo = MatchingInfoAPI.decode(
            ResponseModel<MatchingInfoResponseModel.MatchingInfo>.self,
            data: response.data
          ).data
          UserStorage.shared.saveMatchingInfo(matchingInfo)
          return .concat([
            .just(.setLoading(false)),
            .just(.setMainVC(true)),
            .just(.setMainVC(false))
          ])
        default: // 조회 실패
          return .concat([
            .just(.setLoading(false)),
            .just(.setMainVC(true)),
            .just(.setMainVC(false))
          ])
        }
      }
  }
}
