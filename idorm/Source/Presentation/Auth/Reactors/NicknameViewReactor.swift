//
//  NicknameViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2022/12/25.
//

import UIKit

import RxSwift
import RxCocoa
import RxMoya
import ReactorKit

final class NicknameViewReactor: Reactor {
  
  enum ViewType {
    case changeNickname
    case signUp
  }
  
  enum Action {
    case textFieldDidChange(String)
    case textFieldEditingDidEnd
    case continueButtonDidTap
  }
  
  enum Mutation {
    case setNickname(String)
    case setAllConditions
    case setPopping(Bool)
    case setPrivacyBottomSheet(Bool)
  }
  
  struct State {
    var viewType: ViewType
    var nickname: String = ""
    var isValidatedCountCondition: Bool = false
    var isValidatedCompoundCondition: Bool = false
    var isValidatedSpacingCondition: Bool = false
    var isValidatedAllConditions: Bool = false
    @Pulse var presentToPrivacyBottomSheet: Bool = false
    @Pulse var isPopping: Bool = false
  }
  
  // MARK: - Properties
  
  var initialState: State
  private let memberNetworkService = NetworkService<MemberAPI>()
  
  // MARK: - Initializer
  
  init(_ viewType: ViewType) {
    self.initialState = State(viewType: viewType)
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .textFieldDidChange(let nickname):
      return .just(.setNickname(nickname))
      
    case .textFieldEditingDidEnd:
      return .just(.setAllConditions)
      
    case .continueButtonDidTap:
      guard self.currentState.isValidatedAllConditions else {
        AlertManager.shared.showAlertPopup("조건을 다시 확인해주세요.")
        return .empty()
      }
      if case .changeNickname = self.currentState.viewType {
        return self.memberNetworkService.requestAPI(
          to: .changeNickname(nickname: self.currentState.nickname)
        ).flatMap { _ in
          // TODO: 변경된 닉네임으로 업데이트
          return Observable<Mutation>.just(.setPopping(true))
        }
      } else {
        return .just(.setPrivacyBottomSheet(true))
      }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setNickname(let nickname):
      newState.nickname = nickname
      // 글자 수 조건
      newState.isValidatedCountCondition =
      nickname.count >= 2 && nickname.count <= 8 ? true : false
      // 글자 조합 조건
      newState.isValidatedCompoundCondition =
      ValidationManager.validate(nickname, validationType: .nickname)
      // 글자 공백 조건
      newState.isValidatedSpacingCondition = !nickname.contains(" ")
      
    case .setAllConditions:
      newState.isValidatedAllConditions =
      state.isValidatedCountCondition &&
      state.isValidatedCompoundCondition &&
      state.isValidatedSpacingCondition
      
    case .setPopping(let isPopping):
      newState.isPopping = isPopping
      
    case .setPrivacyBottomSheet(let isPresented):
      newState.presentToPrivacyBottomSheet = isPresented
    }
    
    return newState
  }
}
