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
  
  enum Action {
    case didChangeTextField(String)
    case editingDidBeginTf
    case editingDidEndTf
    case didTapConfirmButton
  }
  
  enum Mutation {
    case setBorderColorTf(UIColor)
    case setCountLabelTextColor(UIColor)
    case setCompoundLabelTextColor(UIColor)
    case setSpacingLabelTextColor(UIColor)
    case setCheckmark(Bool)
    case setNickname(String)
    case setTextCount(Int)
    case setPopup(Bool)
    case setLoading(Bool)
    case setPopVC(Bool)
    case setCompleteSignupVC(Bool)
  }
  
  struct State {
    var currentNickname: String = ""
    var currentBorderColorTf: UIColor = .idorm_gray_300
    var currentCountLabelTextColor: UIColor = .idorm_gray_400
    var currentCompoundLabelTextColor: UIColor = .idorm_gray_400
    var currentSpacingLabelTextColor: UIColor = .idorm_gray_400
    var currentTextCount: Int = 0
    var isHiddenCheckmark: Bool = true
    var isOpenedPopup: (Bool) = false
    var isOpenedCompleteSignupVC: Bool = false
    var popVC: Bool = false
    var isLoading: Bool = false
  }
  
  var initialState: State = State()
  private let type: RegisterEnumerations.Nickname
  
  init(_ type: RegisterEnumerations.Nickname) {
    self.type = type
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .didChangeTextField(let text):
      let countCondition: Observable<Mutation>
      let compoundCondition: Observable<Mutation>
      let spacingCondition: Observable<Mutation>
      
      if text.count >= 2 && text.count <= 8 {
        countCondition = .just(.setCountLabelTextColor(.idorm_blue))
      } else {
        countCondition = .just(.setCountLabelTextColor(.idorm_gray_400))
      }
      
      if text.contains(" ") {
        spacingCondition = .just(.setSpacingLabelTextColor(.idorm_gray_400))
      } else {
        spacingCondition = .just(.setSpacingLabelTextColor(.idorm_blue))
      }
      
      if text.isValidNickname {
        compoundCondition = .just(.setCompoundLabelTextColor(.idorm_blue))
      } else {
        compoundCondition = .just(.setCompoundLabelTextColor(.idorm_gray_400))
      }
      
      return .concat([
        countCondition,
        compoundCondition,
        spacingCondition,
        .just(.setTextCount(text.count)),
        .just(.setNickname(text))
      ])
      
    case .editingDidEndTf:
      let countCondition: Observable<Mutation>
      let compoundCondition: Observable<Mutation>
      let spacingCondition: Observable<Mutation>
      let text = currentState.currentNickname
      
      if (text.count >= 2 && text.count <= 8) {
        countCondition = .just(.setCountLabelTextColor(.idorm_blue))
      } else {
        countCondition = .just(.setCountLabelTextColor(.idorm_red))
      }
      
      if text.contains(" ") {
        spacingCondition = .just(.setSpacingLabelTextColor(.idorm_red))
      } else {
        spacingCondition = .just(.setSpacingLabelTextColor(.idorm_blue))
      }
      
      if text.isValidNickname == false {
        compoundCondition = .just(.setCompoundLabelTextColor(.idorm_red))
      } else {
        compoundCondition = .just(.setCompoundLabelTextColor(.idorm_blue))
      }
      
      if text.count >= 2 && text.count <= 8,
         text.contains(" ") == false,
         text.isValidNickname {
        return .concat([
          countCondition,
          compoundCondition,
          spacingCondition,
          .just(.setBorderColorTf(.idorm_gray_300)),
          .just(.setCheckmark(false))
        ])
      } else {
        return .concat([
          countCondition,
          compoundCondition,
          spacingCondition,
          .just(.setBorderColorTf(.idorm_red)),
          .just(.setCheckmark(true))
        ])
      }
      
    case .editingDidBeginTf:
      return .concat([
        .just(.setBorderColorTf(.idorm_blue)),
        .just(.setCheckmark(true))
      ])
      
    case .didTapConfirmButton:
      let email = Logger.shared.email
      let password = Logger.shared.password
      let nickname = currentState.currentNickname
      
      if nickname.isValidNickname,
         nickname.count >= 2 && nickname.count <= 8,
         nickname.contains(" ") == false {
        switch type {
        case .signUp:
          return .concat([
            .just(.setLoading(true)),
            APIService.memberProvider.rx.request(.register(id: email, pw: password, nickname: nickname))
              .asObservable()
              .retry()
              .filterSuccessfulStatusCodes()
              .flatMap { _ -> Observable<Mutation> in
                return .concat([
                  .just(.setLoading(false)),
                  .just(.setCompleteSignupVC(true)),
                  .just(.setCompleteSignupVC(false))
                ])
              }
          ])
          
        case .modify:
          return .concat([
            .just(.setLoading(true)),
            APIService.memberProvider.rx.request(.changeNickname(nickname: nickname))
              .asObservable()
              .retry()
              .map(ResponseModel<MemberDTO.Retrieve>.self)
              .flatMap { response -> Observable<Mutation> in
                MemberStorage.shared.saveMember(response.data)
                return .concat([
                  .just(.setLoading(false)),
                  .just(.setPopVC(true)),
                  .just(.setPopVC(false))
                ])
              }
          ])
        }
      } else {
        return .concat([
          .just(.setPopup(true)),
          .just(.setPopup(false))
        ])
      }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setPopVC(let isPop):
      newState.popVC = isPop
      
    case .setLoading(let isLoading):
      newState.isLoading = isLoading
      
    case .setPopup(let isOpened):
      newState.isOpenedPopup = isOpened
      
    case .setCompleteSignupVC(let isOpened):
      newState.isOpenedCompleteSignupVC = isOpened
      
    case .setTextCount(let count):
      newState.currentTextCount = count
      
    case .setCompoundLabelTextColor(let color):
      newState.currentCompoundLabelTextColor = color
      
    case .setCountLabelTextColor(let color):
      newState.currentCountLabelTextColor = color
      
    case .setCheckmark(let isHidden):
      newState.isHiddenCheckmark = isHidden
      
    case .setBorderColorTf(let color):
      newState.currentBorderColorTf = color
      
    case .setSpacingLabelTextColor(let color):
      newState.currentSpacingLabelTextColor = color
      
    case .setNickname(let text):
      newState.currentNickname = text
    }
    
    return newState
  }
}
