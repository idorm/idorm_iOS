//
//  MyPageViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2022/12/21.
//

import Foundation

import RxSwift
import RxCocoa
import ReactorKit
import RxMoya

final class ProfileViewReactor: Reactor {
  
  enum Action {
    case viewWillAppear
    case gearButtonDidTap
    case publicButtonDidTap
    case managementButtonDidTap(ProfileSectionItem)
  }
  
  enum Mutation {
    case setManagementMyInfoVC
    case setManagementVC(ProfileSectionItem)
  }
  
  struct State {
    var sections: [ProfileSection] = []
    var items: [[ProfileSectionItem]] = []
    var isPublicMatchingInfo: Bool = false
    @Pulse var navigateToManagementMyInfoVC: Bool = false
    @Pulse var navigateToManagementVC: ProfileSectionItem?
  }
  
  // MARK: - Properties
  
  let initialState: State = State()
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .gearButtonDidTap:
      return .just(.setManagementMyInfoVC)
    case .managementButtonDidTap(let item):
      switch item {
      case .matchingImage:
        if UserStorage.shared.hasMatchingInfo {
          return .empty()
        } else {
          ModalManager.presentPopupVC(.noMatchingInfo)
          return .empty()
        }
      default:
        return .just(.setManagementVC(item))
      }
    case .publicButtonDidTap:
      if UserStorage.shared.hasMatchingInfo {
        return .empty()
      } else {
        ModalManager.presentPopupVC(.noMatchingInfo)
        return .empty()
      }
    default:
      return .empty()
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setManagementMyInfoVC:
      newState.navigateToManagementMyInfoVC = true
    case .setManagementVC(let item):
      newState.navigateToManagementVC = item
    }
    
    return newState
  }
  
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      
      //      guard let member = UserStorage.shared.member else { return newState }
      var member = Member()
      member.nickname = "김응철"
      let isPublic = UserStorage.shared.isPublicMatchingInfo
      
      newState.sections =
      [.profile, .roommate, .publicSetting, .community]
      newState.items =
      [
        [.profile(imageURL: member.profilePhotoURL ?? "", nickname: member.nickname)],
        [.matchingImage, .dislikedRoommate, .likedRoommate],
        [.publicSetting(isPublic: isPublic)],
        [.myPost, .myComment, .recommendedPost]
      ]
      
      return newState
    }
  }
}
