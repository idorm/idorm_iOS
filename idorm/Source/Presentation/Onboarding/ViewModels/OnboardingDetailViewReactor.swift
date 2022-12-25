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
    case didTapRightButton(MatchingDTO.Retrieve)
  }
  
  enum Mutation {
    case setLoading(Bool)
    case setOnboardingVC(Bool)
    case setPopVC(Bool)
    case setMainVC(Bool)
  }
  
  struct State {
    var isLoading: Bool = false
    var isOpenedOnboardingVC: Bool = false
    var popVC: Bool = false
    var isOpenedMainVC: Bool = false
  }
  
  var initialState: State = State()
  private let type: OnboardingEnumerations
  
  init(_ type: OnboardingEnumerations) {
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
        let saveData = ModelTransformationManager.transformToMatchingInfoDTO_SAVE(member)
        return .concat([
          .just(.setLoading(true)),
          APIService.onboardingProvider.rx.request(.save(saveData))
            .asObservable()
            .retry()
            .map(ResponseModel<MatchingInfoDTO.Retrieve>.self)
            .flatMap { response -> Observable<Mutation> in
              MemberStorage.shared.saveMatchingInfo(response.data)
              return .concat([
                .just(.setLoading(false)),
                .just(.setMainVC(true)),
                .just(.setMainVC(false))
              ])
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
    }
    
    return newState
  }
}
