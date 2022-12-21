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

final class MyPageViewReactor: Reactor {
  
  enum Action {
    case viewWillAppear
    case didTapGearButton
    case didTapMatchingImageButton
    case didTapRoommateButton(MyPageEnumerations.Roommate)
    case didTapShareButton(Bool)
    case didTapMakeProfileButton
  }
  
  enum Mutation {
    case updateIsLoading(Bool)
    case updateIsOpenedManageMyInfoVC(Bool)
    case updateIsOpenedOnboardingVC(Bool)
    case updateIsOpenedRoommateVC(Bool, MyPageEnumerations.Roommate)
    case updateIsOpenedNoMatchingInfoPopup(Bool)
    case updateIsOpenedOnboardingDetailVC(Bool)
    case updateIsSelectedShareButton(Bool)
    case updateCurrentNickname(String)
  }
  
  struct State {
    var isOpenedManageMyInfoVC: Bool = false
    var isOpenedOnboardingVC: Bool = false
    var isOpenedOnboardingDetailVC: Bool = false
    var isOpenedLikedRoommateVC: Bool = false
    var isOpenedDislikedRoommateVC: Bool = false
    var isOpenedNoMatchingInfoPopup: Bool = false
    var isLoading: Bool = false
    var isSelectedShareButton: Bool = false
    var currentNickname: String = ""
  }
  
  let initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewWillAppear:
      let currentNickname = MemberStorage.shared.member?.nickname ?? ""
      let isPublic = MemberStorage.shared.isPublicMatchingInfo
      return .concat([
        .just(.updateIsSelectedShareButton(isPublic)),
        .just(.updateCurrentNickname(currentNickname))
      ])
      
    case .didTapGearButton:
      return .concat([
        .just(.updateIsOpenedManageMyInfoVC(true)),
        .just(.updateIsOpenedManageMyInfoVC(false))
      ])
      
    case .didTapMatchingImageButton:
      if MemberStorage.shared.hasMatchingInfo {
        return .concat([
          .just(.updateIsOpenedOnboardingDetailVC(true)),
          .just(.updateIsOpenedOnboardingDetailVC(false))
        ])
      } else {
        return .concat([
          .just(.updateIsOpenedNoMatchingInfoPopup(true)),
          .just(.updateIsOpenedNoMatchingInfoPopup(false))
        ])
      }
      
    case .didTapRoommateButton(let type):
      return .concat([
        .just(.updateIsOpenedRoommateVC(true, type)),
        .just(.updateIsOpenedRoommateVC(false, type))
      ])
      
    case .didTapShareButton(let isPublic):
      return .concat([
        .just(.updateIsLoading(true)),
        APIService.onboardingProvider.rx.request(.modifyPublic(isPublic))
          .asObservable()
          .retry()
          .filterSuccessfulStatusCodes()
          .flatMap { _ -> Observable<Mutation> in
            SharedAPI.retrieveMatchingInfo()
            return .concat([
              .just(.updateIsLoading(false)),
              .just(.updateIsSelectedShareButton(isPublic))
            ])
          }
      ])
      
    case .didTapMakeProfileButton:
      return .concat([
        .just(.updateIsOpenedNoMatchingInfoPopup(false)),
        .just(.updateIsOpenedOnboardingVC(true)),
        .just(.updateIsOpenedOnboardingVC(false))
      ])
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .updateIsOpenedManageMyInfoVC(let isOpened):
      newState.isOpenedManageMyInfoVC = isOpened
      
    case .updateIsOpenedNoMatchingInfoPopup(let isOpened):
      newState.isOpenedNoMatchingInfoPopup = isOpened
      
    case .updateIsOpenedOnboardingVC(let isOpened):
      newState.isOpenedOnboardingVC = isOpened
      
    case let .updateIsOpenedRoommateVC(isOpened, type):
      switch type {
      case .like:
        newState.isOpenedLikedRoommateVC = isOpened
      case .dislike:
        newState.isOpenedDislikedRoommateVC = isOpened
      }
      
    case .updateIsLoading(let isLoading):
      newState.isLoading = isLoading
      
    case .updateIsSelectedShareButton(let isSelected):
      newState.isSelectedShareButton = isSelected
      
    case .updateCurrentNickname(let nickName):
      newState.currentNickname = nickName
    }
    
    return newState
  }
}
