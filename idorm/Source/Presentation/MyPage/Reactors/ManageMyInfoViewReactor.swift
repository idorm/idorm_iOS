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
  }
  
  enum Mutation {
    case updateIsOpenedNicknameVC(Bool)
    case updateIsOpenedConfirmPwVC(Bool)
    case updateIsOpenedWithDrawalVC(Bool)
    case updateCurrentNickname(String)
    case updateCurrentEmail(String)
  }
  
  struct State {
    var isOpenedNicknameVC: Bool = false
    var isOpenedConfirmPwVC: Bool = false
    var isOpenedWithDrawVC: Bool = false
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
        .just(.updateCurrentNickname(nickName)),
        .just(.updateCurrentEmail(email))
      ])
      
    case .didTapNicknameButton:
      return .concat([
        .just(.updateIsOpenedNicknameVC(true)),
        .just(.updateIsOpenedNicknameVC(false))
      ])
      
    case .didTapChangePwButton:
      return .concat([
        .just(.updateIsOpenedConfirmPwVC(true)),
        .just(.updateIsOpenedConfirmPwVC(false))
      ])
      
    case .didTapWithDrawalButton:
      return .concat([
        .just(.updateIsOpenedWithDrawalVC(true)),
        .just(.updateIsOpenedWithDrawalVC(false))
      ])
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .updateIsOpenedNicknameVC(let isOpened):
      newState.isOpenedNicknameVC = isOpened
    
    case .updateIsOpenedConfirmPwVC(let isOpened):
      newState.isOpenedConfirmPwVC = isOpened
      
    case .updateIsOpenedWithDrawalVC(let isOpened):
      newState.isOpenedWithDrawVC = isOpened
      
    case .updateCurrentEmail(let email):
      newState.currentEmail = email
      
    case .updateCurrentNickname(let nickname):
      newState.currentNickname = nickname
    }
    
    return newState
  }
}
