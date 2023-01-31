//
//  PrivacyPolicyBottomSheetReactor.swift
//  idorm
//
//  Created by 김응철 on 2023/01/02.
//

import RxSwift
import RxCocoa
import ReactorKit
import RxMoya

final class PrivacyPolicyBottomSheetReactor: Reactor {
  
  enum Action {
    case didTapConfirmButton
  }
  
  enum Mutation {
    case setCompleteSignUpVC(Bool)
    case setLoading(Bool)
    case setPopup(Bool, String)
  }
  
  struct State {
    var isOpenedCompleteSignUpVC: Bool = false
    var isLoading: Bool = false
    var isOpenedPopup: (Bool, String) = (false, "")
  }
  
  var initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    let email = Logger.shared.email
    let password = Logger.shared.password
    let nickname = Logger.shared.nickname

    switch action {
    case .didTapConfirmButton:
      return .concat([
        .just(.setLoading(true)),
        MemberAPI.provider.rx.request(
          .register(id: email, pw: password, nickname: nickname)
        )
          .asObservable()
          .retry()
          .flatMap { response -> Observable<Mutation> in
            switch response.statusCode {
            case 200..<300:
              return .concat([
                .just(.setLoading(false)),
                .just(.setCompleteSignUpVC(true)),
                .just(.setCompleteSignUpVC(false))
              ])
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
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case let .setPopup(isOpened, message):
      newState.isOpenedPopup = (isOpened, message)
      
    case .setLoading(let isLoading):
      newState.isLoading = isLoading
      
    case .setCompleteSignUpVC(let isOpened):
      newState.isOpenedCompleteSignUpVC = isOpened
    }
    
    return newState
  }
}
