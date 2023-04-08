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
    case didTapRoommateButton(Roommate)
    case didTapShareButton(Bool)
    case didTapMakeProfileButton
  }
  
  enum Mutation {
    case setLoading(Bool)
    case setManageMyInfoVC(Bool)
    case setOnboardingVC(Bool)
    case setRoommateVC(Bool, Roommate)
    case setNoMatchingInfoPopup(Bool)
    case setOnboardingDetailVC(Bool)
    case setShareButton(Bool)
    case setCurrentNickname(String)
    case setDismissPopup(Bool)
  }
  
  struct State {
    var isOpenedManageMyInfoVC: Bool = false
    var isOpenedOnboardingVC: Bool = false
    var isOpenedOnboardingDetailVC: (Bool, MatchingResponseModel.Member) = (false, .init())
    var isOpenedLikedRoommateVC: Bool = false
    var isOpenedDislikedRoommateVC: Bool = false
    var isOpenedNoMatchingInfoPopup: Bool = false
    var isLoading: Bool = false
    var isSelectedShareButton: Bool = false
    var currentNickname: String = ""
    var isDismissedPopup: Bool = false
  }
  
  let initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
      
    case .viewWillAppear:
      let currentNickname = UserStorage.shared.member?.nickname ?? ""
      let isPublic = UserStorage.shared.isPublicMatchingInfo
      
      return .concat([
        .just(.setShareButton(isPublic)),
        .just(.setCurrentNickname(currentNickname))
      ])
      
    case .didTapGearButton:
      return .concat([
        .just(.setManageMyInfoVC(true)),
        .just(.setManageMyInfoVC(false))
      ])
      
    case .didTapMatchingImageButton:
      if UserStorage.shared.hasMatchingInfo {
        return .concat([
          .just(.setOnboardingDetailVC(true)),
          .just(.setOnboardingDetailVC(false))
        ])
      } else {
        return .concat([
          .just(.setNoMatchingInfoPopup(true)),
          .just(.setNoMatchingInfoPopup(false))
        ])
      }
      
    case .didTapRoommateButton(let type):
      return .concat([
        .just(.setRoommateVC(true, type)),
        .just(.setRoommateVC(false, type))
      ])
      
    case .didTapShareButton(let isPublic):
      if UserStorage.shared.hasMatchingInfo {
        return .concat([
          .just(.setLoading(true)),
          MatchingInfoAPI.provider.rx.request(
            .modifyPublic(isPublic)
          )
            .asObservable()
            .retry()
            .filterSuccessfulStatusCodes()
            .flatMap { _ -> Observable<Mutation> in
              SharedAPI.retrieveMatchingInfo()
              return .concat([
                .just(.setLoading(false)),
                .just(.setShareButton(isPublic))
              ])
            }
        ])
      } else {
        return .concat([
          .just(.setNoMatchingInfoPopup(true)),
          .just(.setNoMatchingInfoPopup(false))
        ])
      }
      
    case .didTapMakeProfileButton:
      return .concat([
        .just(.setNoMatchingInfoPopup(false)),
        .just(.setOnboardingVC(true)),
        .just(.setOnboardingVC(false)),
        .just(.setDismissPopup(true)),
        .just(.setDismissPopup(false))
      ])
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setManageMyInfoVC(let isOpened):
      newState.isOpenedManageMyInfoVC = isOpened
      
    case .setNoMatchingInfoPopup(let isOpened):
      newState.isOpenedNoMatchingInfoPopup = isOpened
      
    case .setOnboardingVC(let isOpened):
      newState.isOpenedOnboardingVC = isOpened
      
    case let .setOnboardingDetailVC(isOpened):
      guard let matchingInfo = UserStorage.shared.matchingInfo else { return newState }
      let member = TransformUtils.transfer(matchingInfo)
      newState.isOpenedOnboardingDetailVC = (isOpened, member)
      
    case let .setRoommateVC(isOpened, type):
      switch type {
      case .like:
        newState.isOpenedLikedRoommateVC = isOpened
      case .dislike:
        newState.isOpenedDislikedRoommateVC = isOpened
      }
      
    case .setLoading(let isLoading):
      newState.isLoading = isLoading
      
    case .setShareButton(let isSelected):
      newState.isSelectedShareButton = isSelected
      
    case .setCurrentNickname(let nickName):
      newState.currentNickname = nickName
      
    case .setDismissPopup(let isDismissed):
      newState.isDismissedPopup = isDismissed
    }
    
    return newState
  }
}
