//
//  ConfirmPwViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2022/12/23.
//

import UIKit

import RxSwift
import RxCocoa
import RxMoya
import ReactorKit

final class ConfirmPwViewReactor: Reactor {
  
  enum Action {
    case didChangeTextField1(String)
    case didChangeTextField2(String)
    case editingDidBeginTf1
    case editingDidBeginTf2
    case editingDidEndTf1
    case editingDidEndTf2
    case didTapConfirmButton
  }
  
  enum Mutation {
    case setBorderColorTf1(UIColor)
    case setBorderColorTf2(UIColor)
    case setCountLabelColor(UIColor)
    case setCompoundLabelColor(UIColor)
    case setInfoLabelTextColor(UIColor)
    case setInfoLabel2TextColor(UIColor)
    case setInfoLabel2Text(String)
    case setTf1Checkmark(Bool)
    case setTf2Checkmark(Bool)
    case setPassword1(String)
    case setPassword2(String)
    case setPopup(Bool, String)
    case setNicknameVC(Bool)
    case setLoading(Bool)
    case setLoginVC(Bool)
  }
  
  struct State {
    var currentBorderColorTf1: UIColor = .idorm_gray_400
    var currentBorderColorTf2: UIColor = .idorm_gray_400
    var currentCountLabelColor: UIColor = .idorm_gray_400
    var currentCompoundLabelColor: UIColor = .idorm_gray_400
    var currentInfoLabelTextColor: UIColor = .black
    var currentInfoLabel2TextColor: UIColor = .black
    var currentInfoLabel2Text: String = "비밀번호 확인"
    var isHiddenTf1Checkmark: Bool = true
    var isHiddenTf2Checkmark: Bool = true
    var currentPassword1: String = ""
    var currentPassword2: String = ""
    var isOpenedPopup: (Bool, String) = (false, "")
    var isOpenedNicknameVC: Bool = false
    var isOpenedLoginVC: Bool = false
    var isLoading: Bool = false
  }
  
  var initialState: State = State()
  private let type: RegisterEnumerations
  
  init(_ type: RegisterEnumerations) {
    self.type = type
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .didChangeTextField1(let password):
      if password.count < 8 && password.isValidCompoundCondition() == false {
        return .concat([
          .just(.setPassword1(password)),
          .just(.setCountLabelColor(.idorm_gray_400)),
          .just(.setCompoundLabelColor(.idorm_gray_400))
        ])
      } else if password.count >= 8 && password.isValidCompoundCondition() == false {
        return .concat([
          .just(.setPassword1(password)),
          .just(.setCountLabelColor(.idorm_blue)),
          .just(.setCompoundLabelColor(.idorm_gray_400))
        ])
      } else if password.count < 8 && password.isValidCompoundCondition() {
        return .concat([
          .just(.setPassword1(password)),
          .just(.setCompoundLabelColor(.idorm_blue)),
          .just(.setCountLabelColor(.idorm_gray_400))
        ])
      } else {
        return .concat([
          .just(.setPassword1(password)),
          .just(.setCountLabelColor(.idorm_blue)),
          .just(.setCompoundLabelColor(.idorm_blue))
        ])
      }
      
    case .didChangeTextField2(let password):
      return .just(.setPassword2(password))
      
    case .editingDidBeginTf1:
      return .concat([
        .just(.setBorderColorTf1(.idorm_blue)),
        .just(.setTf1Checkmark(true))
        ])
      
    case .editingDidBeginTf2:
      return .concat([
        .just(.setBorderColorTf2(.idorm_blue)),
        .just(.setTf2Checkmark(true))
      ])
      
    case .editingDidEndTf1:
      let currentPw = currentState.currentPassword1
      
      if currentPw.count >= 8 && currentPw.isValidCompoundCondition() {
        return .concat([
          .just(.setCountLabelColor(.idorm_gray_400)),
          .just(.setCompoundLabelColor(.idorm_gray_400)),
          .just(.setInfoLabelTextColor(.black)),
          .just(.setTf1Checkmark(false)),
          .just(.setBorderColorTf1(.idorm_gray_400))
        ])
      } else if currentPw.count < 8 && currentPw.isValidCompoundCondition() {
        return .concat([
          .just(.setCountLabelColor(.idorm_red)),
          .just(.setCompoundLabelColor(.idorm_gray_400)),
          .just(.setInfoLabelTextColor(.idorm_red)),
          .just(.setTf1Checkmark(true)),
          .just(.setBorderColorTf1(.idorm_red))
        ])
      } else if currentPw.count >= 8 && currentPw.isValidCompoundCondition() == false {
        return .concat([
          .just(.setCountLabelColor(.idorm_gray_400)),
          .just(.setCompoundLabelColor(.idorm_red)),
          .just(.setInfoLabelTextColor(.idorm_red)),
          .just(.setTf1Checkmark(true)),
          .just(.setBorderColorTf1(.idorm_red))
        ])
      } else {
        return .concat([
          .just(.setCountLabelColor(.idorm_red)),
          .just(.setCompoundLabelColor(.idorm_red)),
          .just(.setInfoLabelTextColor(.idorm_red)),
          .just(.setTf1Checkmark(true)),
          .just(.setBorderColorTf1(.idorm_red))
        ])
      }
      
    case .editingDidEndTf2:
      let password = currentState.currentPassword1
      let password2 = currentState.currentPassword2
      
      if password == password2 {
        return .concat([
          .just(.setBorderColorTf2(.idorm_gray_400)),
          .just(.setTf2Checkmark(false)),
          .just(.setInfoLabel2Text("비밀번호 확인")),
          .just(.setInfoLabel2TextColor(.black))
        ])
      } else {
        return .concat([
          .just(.setBorderColorTf2(.idorm_red)),
          .just(.setTf2Checkmark(true)),
          .just(.setInfoLabel2Text("비밀번호가 일치하지 않습니다. 다시 확인해주세요.")),
          .just(.setInfoLabel2TextColor(.idorm_red))
        ])
      }
      
    case .didTapConfirmButton:
      let password1 = currentState.currentPassword1
      let password2 = currentState.currentPassword2
      
      if password1 == password2,
         password1.isValidCompoundCondition(),
         password1.count >= 8 {
        switch type {
        case .signUp:
          UserStorage.savePassword(from: password1)
          Logger.shared.savePassword(password1)
          return .concat([
            .just(.setNicknameVC(true)),
            .just(.setNicknameVC(false))
          ])
          
        case .findPw:
          let email = Logger.shared.email
          return .concat([
            .just(.setLoading(true)),
            APIService.memberProvider.rx.request(.changePassword_Logout(id: email, pw: password1))
              .asObservable()
              .retry()
              .flatMap { response -> Observable<Mutation> in
                switch response.statusCode {
                case 200:
                  return .concat([
                    .just(.setLoading(false)),
                    .just(.setLoginVC(true)),
                    .just(.setLoginVC(false))
                  ])
                default:
                  fatalError()
                }
              }
              .subscribe(on: MainScheduler.asyncInstance)
          ])
          
        case .modifyPw:
          return .concat([
            .just(.setLoading(true)),
            APIService.memberProvider.rx.request(.changePassword_Login(pw: password1))
              .asObservable()
              .retry()
              .flatMap { response -> Observable<Mutation> in
                switch response.statusCode {
                case 200:
                  return .concat([
                    .just(.setLoading(false)),
                    .just(.setLoginVC(true)),
                    .just(.setLoginVC(false))
                  ])
                default:
                  fatalError()
                }
              }
          ])
        }
      } else {
        return .concat([
          .just(.setPopup(true, "조건을 다시 확인해주세요.")),
          .just(.setPopup(false, ""))
        ])
      }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setPassword1(let password):
      newState.currentPassword1 = password
      
    case .setPassword2(let password):
      newState.currentPassword2 = password
      
    case .setBorderColorTf1(let color):
      newState.currentBorderColorTf1 = color
      
    case .setBorderColorTf2(let color):
      newState.currentBorderColorTf2 = color
      
    case .setTf1Checkmark(let isHidden):
      newState.isHiddenTf1Checkmark = isHidden
      
    case .setTf2Checkmark(let isHidden):
      newState.isHiddenTf2Checkmark = isHidden
      
    case .setCountLabelColor(let color):
      newState.currentCountLabelColor = color
    
    case .setCompoundLabelColor(let color):
      newState.currentCompoundLabelColor = color
      
    case .setInfoLabel2Text(let text):
      newState.currentInfoLabel2Text = text
      
    case .setInfoLabel2TextColor(let color):
      newState.currentInfoLabel2TextColor = color
      
    case .setInfoLabelTextColor(let color):
      newState.currentInfoLabelTextColor = color
      
    case let .setPopup(isOpened, message):
      newState.isOpenedPopup = (isOpened, message)
      
    case .setNicknameVC(let isOpened):
      newState.isOpenedNicknameVC = isOpened
      
    case .setLoading(let isLoading):
      newState.isLoading = isLoading
      
    case .setLoginVC(let isOpened):
      newState.isOpenedLoginVC = isOpened
    }
    
    return newState
  }
}
