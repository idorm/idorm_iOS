//
//  ManageMyInfoViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2022/12/21.
//

import UIKit

import RxSwift
import RxCocoa
import RxMoya
import ReactorKit

final class ManageMyInfoViewReactor: Reactor {
  
  enum Action {
    case viewWillAppear
    case didTapNicknameButton
    case didTapChangePwButton
    case didTapWithDrawalButton
    case didTapLogoutButton
    case didPickProfileImage(UIImage)
  }
  
  enum Mutation {
    case setNicknameVC(Bool)
    case setConfirmPwVC(Bool)
    case setWithDrawalVC(Bool)
    case setCurrentNickname(String)
    case setCurrentEmail(String)
    case setLoginVC(Bool)
    case setLoading(Bool)
    case setProfileImageUrl(String?)
  }
  
  struct State {
    var isOpenedNicknameVC: Bool = false
    var isOpenedConfirmPwVC: Bool = false
    var isOpenedWithDrawVC: Bool = false
    var isOpenedLoginVC: Bool = false
    var currentNickname: String = ""
    var currentEmail: String = ""
    var isLoading: Bool = false
    var profileImageURL: String?
  }
  
  var initialState: State = State()

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewWillAppear:
      let nickName = UserStorage.shared.member?.nickname ?? ""
      let email = UserStorage.shared.member?.email ?? ""
      let profileURL = UserStorage.shared.member?.profilePhotoUrl
      
      return .concat([
        .just(.setCurrentNickname(nickName)),
        .just(.setCurrentEmail(email)),
        .just(.setProfileImageUrl(profileURL))
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
      TokenStorage.removeToken()
      return .concat([
        .just(.setLoginVC(true)),
        .just(.setLoginVC(false))
      ])
      
    case .didPickProfileImage(let image):
      return .concat([
        .just(.setLoading(true)),
        MemberAPI.provider.rx.request(.saveProfilePhoto(image: image))
          .asObservable()
          .filterSuccessfulStatusCodes()
          .withUnretained(self)
          .flatMap { owner, _ -> Observable<Mutation> in
            return owner.retrieveMember()
          }
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
      
    case .setLoading(let isLoading):
      newState.isLoading = isLoading
      
    case .setProfileImageUrl(let url):
      newState.profileImageURL = url
    }
    
    return newState
  }
}

private extension ManageMyInfoViewReactor {
  func retrieveMember() -> Observable<Mutation> {
    return MemberAPI.provider.rx.request(.retrieveMember)
      .asObservable()
      .flatMap { response -> Observable<Mutation> in
        let member = MemberAPI.decode(
          ResponseModel<MemberResponseModel.Member>.self,
          data: response.data
        ).data
        UserStorage.shared.saveMember(member)
        return .concat([
          .just(.setLoading(false)),
          .just(.setProfileImageUrl(member.profilePhotoUrl))
        ])
      }
  }
}
