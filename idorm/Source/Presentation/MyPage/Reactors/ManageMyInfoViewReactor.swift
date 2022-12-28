//
//  ManageMyInfoViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2022/12/21.
//

import Foundation

import RxSwift
import RxCocoa
import ReactorKit

final class ManageMyInfoViewReactor: Reactor {
  
  enum Action {
    case viewWillAppear
    case didTapNicknameButton
    case didTapChangePwButton
    case didTapWithDrawalButton
    case didTapLogoutButton
  }
  
  enum Mutation {
    case setNicknameVC(Bool)
    case setConfirmPwVC(Bool)
    case setWithDrawalVC(Bool)
    case setCurrentNickname(String)
    case setCurrentEmail(String)
    case setLoginVC(Bool)
  }
  
  struct State {
    var isOpenedNicknameVC: Bool = false
    var isOpenedConfirmPwVC: Bool = false
    var isOpenedWithDrawVC: Bool = false
    var isOpenedLoginVC: Bool = false
    var currentNickname: String = ""
    var currentEmail: String = ""
  }
  
  var initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewWillAppear:
      let nickName = MemberStorage.shared.member?.nickname ?? ""
      let email = MemberStorage.shared.member?.email ?? ""
      
      return .concat([
        .just(.setCurrentNickname(nickName)),
        .just(.setCurrentEmail(email))
      ])
      
    case .didTapNicknameButton:
      return .concat([
        .just(.setNicknameVC(true)),
        .just(.setNicknameVC(false))
      ])
      
    case .didTapChangePwButton:
      return .concat([
        .just(.setConfirmPwVC(true)),
        .just(.setConfirmPwVC(false))
      ])
      
    case .didTapWithDrawalButton:
      return .concat([
        .just(.setWithDrawalVC(true)),
        .just(.setWithDrawalVC(false))
      ])
      
    case .didTapLogoutButton:
      return .concat([
        .just(.setLoginVC(true)),
        .just(.setLoginVC(false))
      ])
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setNicknameVC(let isOpened):
      newState.isOpenedNicknameVC = isOpened
    
    case .setConfirmPwVC(let isOpened):
      newState.isOpenedConfirmPwVC = isOpened
      
    case .setWithDrawalVC(let isOpened):
      newState.isOpenedWithDrawVC = isOpened
      
    case .setCurrentEmail(let email):
      newState.currentEmail = email
      
    case .setCurrentNickname(let nickname):
      newState.currentNickname = nickname
      
    case .setLoginVC(let isOpened):
      newState.isOpenedLoginVC = isOpened
    }
    
    return newState
  }
}
