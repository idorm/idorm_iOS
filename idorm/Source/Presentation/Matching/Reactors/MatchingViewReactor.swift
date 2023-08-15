//
//  MatchingViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2022/12/20.
//

import Foundation

import Moya
import RxSwift
import RxCocoa
import RxMoya
import ReactorKit

final class MatchingViewReactor: Reactor {
  
  enum MatchingTextImage {
    /// 자신의 매칭 정보가 없을 떄
    case noMatchingInformation
    /// 상대방의 카드가 더이상 존재하지 않을 떄
    case noMatchingCardInformation
    /// 공유 버튼이 활성화가 되어 있지 않을 때
    case noShareState
    
    var imageName: String {
      switch self {
      case .noMatchingInformation: return "text_noMatchingInfo"
      case .noMatchingCardInformation: return "text_noMatchingCard"
      case .noShareState: return "text_noShare"
      }
    }
  }
  
  enum Action {
    case viewDidLoad
    case viewWillAppear
    case didTapFilterButton
    case didTapRefreshButton
    case didTapPublicButton
    case didTapMakeProfileButton
    case didTapKakaoLinkButton
    case didTapOptionButton
    case dislikeCard(Int)
    case likeCard(Int)
    case didTapHeartButton
    case didTapXmarkButton
    case didTapSpeechBubbleButton(Int)
    case didChangeFilter
  }
  
  enum Mutation {
    case setLoading(Bool)
    case setCurrentTextImage(MatchingTextImage)
    case setNoPublicPopup(Bool)
    case setNoMatchingInfoPopup(Bool)
    case setNoMatchingInfoPopup_initial(Bool)
    case setFilterVC(Bool)
    case setOnboardingVC(Bool)
    case setKakaoPopup(Bool, String)
    case setBasicPopup(Bool)
    case setWeb(Bool)
    case setMatchingMembers([MatchingResponseModel.Member])
    case setDismissPopup(Bool)
    case setBottomSheet(Bool)
    case setGreenBackgroundColor(Bool)
    case setRedBackgroundColor(Bool)
  }
  
  struct State {
    var matchingMembers: [MatchingResponseModel.Member] = []
    var isLoading: Bool = false
    var isOpenedNoPublicPopup: Bool = false
    var isOpenedNoMatchingInfoPopup: Bool = false
    var isOpenedNoMatchingInfoPopup_Initial: Bool = false
    var isOpenedKakaoPopup: (Bool, String) = (false, "")
    var isOpenedBasicPopup: Bool = false
    var isOpenedFilterVC: Bool = false
    var isOpenedOnboardingVC: Bool = false
    var isOpenedWeb: Bool = false
    var isOpenedBottomSheet: Bool = false
    var isDismissedPopup: Bool = false
    var currentTextImage: MatchingTextImage = .noMatchingCardInformation
    var isGreenBackgroundColor: Bool = false
    var isRedBackgroundColor: Bool = false
  }
  
  let initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    let userStorage = UserStorage.shared
    
    switch action {
    case .viewDidLoad:
      if userStorage.hasMatchingInfo {
        if userStorage.isPublicMatchingInfo {
          return Observable.concat([
            .just(.setLoading(true)),
            fetchMatchingMembers()
          ])
        } else {
          return Observable.concat([
            .just(.setNoPublicPopup(true)),
            .just(.setNoPublicPopup(false))
          ])
        }
      } else {
        if UserDefaults.standard.bool(forKey: "launchedBefore") {
          UserDefaults.standard.set(true, forKey: "launchedBefore")
          return Observable.concat([
            .just(.setNoMatchingInfoPopup_initial(true)),
            .just(.setNoMatchingInfoPopup_initial(false))
          ])
        } else {
          return .empty()
        }
      }
      
    case .viewWillAppear:
      if userStorage.hasMatchingInfo {
        if userStorage.isPublicMatchingInfo {
           return .just(.setCurrentTextImage(.noMatchingCardInformation))
        } else {
          return .concat([
            .just(.setCurrentTextImage(.noShareState)),
            .just(.setMatchingMembers([]))
          ])
        }
      } else {
        return .just(.setCurrentTextImage(.noMatchingInformation))
      }
      
    case .didTapOptionButton:
      return .concat([
        .just(.setBottomSheet(true)),
        .just(.setBottomSheet(false))
      ])
      
    case .didChangeFilter:
      if FilterStorage.shared.hasFilter {
        return .concat([
          .just(.setLoading(true)),
          fetchFilteredMembers()
        ])
      } else {
        return .concat([
          .just(.setLoading(true)),
          fetchMatchingMembers()
        ])
      }
      
    case .didTapPublicButton:
      return .concat([
        .just(.setDismissPopup(true)),
        .just(.setDismissPopup(false)),
        .just(.setLoading(true)),
        MatchingInfoAPI.provider.rx.request(.modifyPublic(true))
          .asObservable()
          .retry()
          .filterSuccessfulStatusCodes()
          .withUnretained(self)
          .flatMap { owner, _ -> Observable<Mutation> in
            SharedAPI.retrieveMatchingInfo()
            if FilterStorage.shared.hasFilter {
              return .concat([
                .just(.setNoPublicPopup(false)),
                owner.fetchFilteredMembers()
              ])
            } else {
              return .concat([
                .just(.setNoPublicPopup(false)),
                owner.fetchMatchingMembers()
              ])
            }
          }
      ])
      
    case .didTapMakeProfileButton:
      return .concat([
        .just(.setDismissPopup(true)),
        .just(.setDismissPopup(false)),
        .just(.setOnboardingVC(true)),
        .just(.setOnboardingVC(false))
      ])
      
    case .didTapFilterButton:
      if userStorage.hasMatchingInfo {
        if userStorage.isPublicMatchingInfo {
          return Observable.concat([
            .just(.setFilterVC(true)),
            .just(.setFilterVC(false))
          ])
        } else {
          return Observable.concat([
            .just(.setNoPublicPopup(true)),
            .just(.setNoPublicPopup(false))
          ])
        }
      } else {
        return Observable.concat([
          .just(.setNoMatchingInfoPopup(true)),
          .just(.setNoMatchingInfoPopup(false))
        ])
      }
      
    case .didTapRefreshButton:
      if userStorage.hasMatchingInfo {
        if userStorage.isPublicMatchingInfo {
          if FilterStorage.shared.hasFilter {
            return Observable.concat([
              .just(.setMatchingMembers([])),
              .just(.setLoading(true)),
              fetchFilteredMembers()
            ])
          } else {
            return Observable.concat([
              .just(.setMatchingMembers([])),
              .just(.setLoading(true)),
              fetchMatchingMembers()
            ])
          }
        } else {
          return Observable.concat([
            .just(.setNoPublicPopup(true)),
            .just(.setNoPublicPopup(false))
          ])
        }
      } else {
        return Observable.concat([
          .just(.setNoMatchingInfoPopup(true)),
          .just(.setNoMatchingInfoPopup(false))
        ])
      }
      
    case .dislikeCard(let id):
      return Observable.concat([
        MatchingAPI.provider.rx.request(.addMember(false, id))
          .asObservable()
          .retry()
          .flatMap { _ -> Observable<Mutation> in
            return Observable.concat([
              .just(.setLoading(false))
            ])
          }
      ])
      
    case .likeCard(let id):
      return Observable.concat([
        MatchingAPI.provider.rx.request(.addMember(true, id))
          .asObservable()
          .retry()
          .debug()
          .flatMap { response -> Observable<Mutation> in
            return Observable.concat([
              .just(.setLoading(false))
            ])
          }
      ])
      
    case .didTapHeartButton:
      return .concat([
        .just(.setGreenBackgroundColor(true)),
        .just(.setGreenBackgroundColor(false))
      ])
      
    case .didTapXmarkButton:
      return .concat([
        .just(.setRedBackgroundColor(true)),
        .just(.setRedBackgroundColor(false))
      ])
      
    case .didTapSpeechBubbleButton(let index):
      guard currentState.matchingMembers.indices.contains(index) else { return .empty() }
      let link = currentState.matchingMembers[index].openKakaoLink
      return .concat([
        .just(.setKakaoPopup(true, link)),
        .just(.setKakaoPopup(false, ""))
      ])
      
    case .didTapKakaoLinkButton:
      return .concat([
        .just(.setDismissPopup(true)),
        .just(.setDismissPopup(false)),
        .just(.setWeb(true)),
        .just(.setWeb(false))
      ])
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setLoading(let isLoading):
      newState.isLoading = isLoading
      
    case .setFilterVC(let isOpened):
      newState.isOpenedFilterVC = isOpened
      
    case .setOnboardingVC(let isOpened):
      newState.isOpenedOnboardingVC = isOpened
      
    case .setNoPublicPopup(let isOpened):
      newState.isOpenedNoPublicPopup = isOpened
      
    case .setNoMatchingInfoPopup(let isOpened):
      newState.isOpenedNoMatchingInfoPopup = isOpened
      
    case .setNoMatchingInfoPopup_initial(let isOpened):
      newState.isOpenedNoMatchingInfoPopup_Initial = isOpened
      
    case .setMatchingMembers(let members):
      newState.matchingMembers = members
      newState.isLoading = false
      
    case let .setKakaoPopup(isOpened, link):
      newState.isOpenedKakaoPopup = (isOpened, link)
      
    case .setCurrentTextImage(let imageType):
      newState.currentTextImage = imageType
      
    case .setWeb(let isOpened):
      newState.isOpenedWeb = isOpened
      
    case .setBasicPopup(let isOpened):
      newState.isOpenedBasicPopup = isOpened
      
    case .setDismissPopup(let isDismissed):
      newState.isDismissedPopup = isDismissed
      
    case .setBottomSheet(let isOpened):
      newState.isOpenedBottomSheet = isOpened
      
    case .setGreenBackgroundColor(let isActivated):
      newState.isGreenBackgroundColor = isActivated
      
    case .setRedBackgroundColor(let isActivated):
      newState.isRedBackgroundColor = isActivated
    }
    
    return newState
  }
}

extension MatchingViewReactor {
  private func fetchMatchingMembers() -> Observable<Mutation> {
    return MatchingAPI.provider.rx.request(.lookupMembers)
      .asObservable()
      .retry()
      .filterSuccessfulStatusCodes()
      .flatMap { response -> Observable<Mutation> in
        switch response.statusCode {
        case 200:
          let members = MatchingAPI.decode(
            ResponseDTO<[MatchingResponseModel.Member]>.self,
            data: response.data
          ).data
          return .just(.setMatchingMembers(members))
        default:
          return .just(.setMatchingMembers([]))
        }
      }
  }
  
  private func fetchFilteredMembers() -> Observable<Mutation> {
    let filter = FilterStorage.shared.filter
    return MatchingAPI.provider.rx.request(
      .lookupFilterMembers(filter: filter)
    )
      .asObservable()
      .retry()
      .debug()
      .filterSuccessfulStatusCodes()
      .flatMap { response -> Observable<Mutation> in
        switch response.statusCode {
        case 200:
          let members = MatchingAPI.decode(
            ResponseDTO<[MatchingResponseModel.Member]>.self,
            data: response.data
          ).data
          return .just(.setMatchingMembers(members))
        default:
          return .just(.setMatchingMembers([]))
        }
      }
  }
}
