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

final class MatchingInfoCardViewReactor: Reactor {
  
  enum ViewType {
    /// 회원 가입
    case signUp
    /// 메인 화면에 들어간 직후
    case theFirstTime
    /// 수정
    case correction
  }
  
  enum Action {
    case leftButtonDidTap
    case rightButtonDidTap
  }
  
  enum Mutation {
    case setPopping(Bool)
    case setOnboardingVC(MatchingInfoSetupViewReactor.ViewType)
    case setTabBarVC(Bool)
  }
  
  struct State {
    let viewType: ViewType
    let matchingInfo: MatchingInfo
    @Pulse var isPopping: Bool = false
    @Pulse var naviagetToTabBarVC: Bool = false
    @Pulse var navigateToOnboardingVC: MatchingInfoSetupViewReactor.ViewType = .signUp
  }
  
  // MARK: - Properties
  
  var initialState: State
  private let networkService = NetworkService<MatchingInfoAPI>()
  
  // MARK: - Initializer
  
  init(_ viewType: ViewType, matchingInfo: MatchingInfo) {
    self.initialState = State(viewType: viewType, matchingInfo: matchingInfo)
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .leftButtonDidTap:
      switch self.currentState.viewType {
      case .signUp, .theFirstTime:
        return .just(.setPopping(true))
      case .correction:
        return .just(.setOnboardingVC(.correction(self.currentState.matchingInfo)))
      }
      
    case .rightButtonDidTap:
      switch self.currentState.viewType {
      case .signUp:
        return self.networkService.requestAPI(
          to: .createMatchingInfo(MatchingInfoRequestDTO(self.currentState.matchingInfo))
        )
        .map(ResponseDTO<MatchingInfoResponseDTO>.self)
        .flatMap { responseDTO in
          UserStorage.shared.saveMatchingInfo(MatchingInfo(responseDTO.data))
          return Observable<Mutation>.just(.setTabBarVC(true))
        }
      case .theFirstTime:
        return self.networkService.requestAPI(
          to: .createMatchingInfo(MatchingInfoRequestDTO(self.currentState.matchingInfo))
        )
        .map(ResponseDTO<MatchingInfoResponseDTO>.self)
        .flatMap { responseDTO in
          UserStorage.shared.saveMatchingInfo(MatchingInfo(responseDTO.data))
          return Observable<Mutation>.just(.setPopping(true))
        }
      case .correction:
        return .just(.setPopping(true))
      }
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setTabBarVC(let state):
      newState.naviagetToTabBarVC = state
      
    case .setPopping(let isPopping):
      newState.isPopping = isPopping
      
    case .setOnboardingVC(let viewType):
      newState.navigateToOnboardingVC = viewType
    }
    
    return newState
  }
}
