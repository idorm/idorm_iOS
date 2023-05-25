//
//  OnboardingDetailViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2022/12/25.
//

import Foundation

import RxSwift
import RxCocoa
import RxMoya
import ReactorKit

final class OnboardingDetailViewReactor: Reactor {
  
  enum Action {
    case didTapLeftButton
    case didTapRightButton(MatchingResponseModel.Member)
  }
  
  enum Mutation {
    case setLoading(Bool)
    case setOnboardingVC(Bool)
    case setPopVC(Bool)
    case setMainVC(Bool)
    case setPopupMessage(Bool, String)
  }
  
  struct State {
    var isLoading: Bool = false
    var isOpenedOnboardingVC: Bool = false
    var popVC: Bool = false
    var isOpenedMainVC: Bool = false
    var popupMessage: (Bool, String) = (false, "")
  }
  
  var initialState: State = State()
  private let type: Onboarding
  
  init(_ type: Onboarding) {
    self.type = type
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .didTapLeftButton:
      switch type {
      case .modify:
        return .concat([
          .just(.setOnboardingVC(true)),
          .just(.setOnboardingVC(false))
        ])
        
      case .initial, .main:
        return .concat([
          .just(.setPopVC(true)),
          .just(.setPopVC(false))
        ])
      }
      
    case .didTapRightButton(let member):
      switch type {
      case .modify:
        return .concat([
          .just(.setPopVC(true)),
          .just(.setPopVC(false))
        ])
        
      case .main, .initial:
        let requestModel = TransformUtils.transfer(member)
        return .concat([
          .just(.setLoading(true)),
          MatchingInfoAPI.provider.rx.request(.save(requestModel))
            .asObservable()
            .retry()
            .flatMap { response -> Observable<Mutation> in
              switch response.statusCode {
              case 200..<300:
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
              default:
                let message = MatchingInfoAPI.decode(
                  ErrorResponseModel.self,
                  data: response.data
                ).responseMessage
                return .concat([
                  .just(.setLoading(false)),
                  .just(.setPopupMessage(true, message)),
                  .just(.setPopupMessage(false, ""))
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
    case .setMainVC(let isOpened):
      newState.isOpenedMainVC = isOpened
      
    case .setOnboardingVC(let isOpened):
      newState.isOpenedOnboardingVC = isOpened
      
    case .setLoading(let isLoading):
      newState.isLoading = isLoading
      
    case .setPopVC(let isPoped):
      newState.popVC = isPoped
      
    case let .setPopupMessage(state, message):
      newState.popupMessage = (state, message)
    }
    
    return newState
  }
}
