//
//  MatchingInfoSetupViewReactor.swift
//  idorm
//
//  Created by 김응철 on 9/15/23.
//

import Foundation

import ReactorKit
import RxCocoa
import RxSwift

final class MatchingInfoSetupViewReactor: Reactor {
  
  enum ViewType {
    /// 회원가입 직후
    case signUp
    /// 홈에 들어간 이후
    case theFirstTime
    /// 수정
    case correction(MatchingInfo)
  }
  
  enum Action {
    case buttonDidChange(MatchingInfoSetupSectionItem)
    case textDidChange(MatchingInfoSetupSectionItem, String)
    case leftButtonDidTap
    case rightButtonDidTap
  }
  
  enum Mutation {
    case setButton(MatchingInfoSetupSectionItem)
    case setText(MatchingInfoSetupSectionItem, String)
    case setReset
    case setTabBarVC
    case setRootVC
    case setMatchingInfoCardVC
  }
  
  struct State {
    let viewType: ViewType
    var matchingInfo: MatchingInfo = .init()
    var sections: [MatchingInfoSetupSection] = []
    var items: [[MatchingInfoSetupSectionItem]] = []
    var isEnabledRightButton: Bool = false
    @Pulse var navigateToMatchingInfoCardVC: (MatchingInfo)?
    @Pulse var navigateToTabBarVC: Bool = false
    @Pulse var navigateToRootVC: Bool = false
    @Pulse var shouldReset: Bool = false
  }
  
  // MARK: - Properties
  
  var initialState: State
  private let networkService = NetworkService<MatchingInfoAPI>()
  
  // MARK: - Initializer
  
  init(_ viewType: ViewType) {
    switch viewType {
    case .signUp, .theFirstTime:
      self.initialState = State(viewType: viewType)
    case .correction(let matchingInfo):
      self.initialState = State(viewType: viewType, matchingInfo: matchingInfo)
    }
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .buttonDidChange(let item):
      return .just(.setButton(item))
    case let .textDidChange(item, text):
      return .just(.setText(item, text))
    case .rightButtonDidTap:
      switch self.currentState.viewType {
      case .signUp, .theFirstTime:
        return .just(.setMatchingInfoCardVC)
      case .correction:
        return self.networkService
          .requestAPI(to: .updateMatchingInfo(MatchingInfoRequestDTO(self.currentState.matchingInfo)))
          .map(ResponseDTO<MatchingInfoResponseDTO>.self)
          .flatMap { responseDTO in
            UserStorage.shared.matchingInfo = MatchingInfo(responseDTO.data)
            return Observable<Mutation>.just(.setRootVC)
          }
      }
    case .leftButtonDidTap:
      switch self.currentState.viewType {
      case .signUp: // 정보 입력 건너 뛰기
        return .just(.setTabBarVC)
      case .theFirstTime, .correction: // 입력 초기화
        return .just(.setReset)
      }
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setButton(let item):
      switch item {
      case .dormitory(let dormitory, _):
        newState.matchingInfo.dormCategory = dormitory
      case .gender(let gender, _):
        newState.matchingInfo.gender = gender
      case .period(let joinPeriod, _):
        newState.matchingInfo.joinPeriod = joinPeriod
      case let .habit(habit, isSelected):
        switch habit {
        case .snoring:
          newState.matchingInfo.isSnoring = !isSelected
        case .grinding:
          newState.matchingInfo.isGrinding = !isSelected
        case .smoking:
          newState.matchingInfo.isSmoking = !isSelected
        case .allowedFood:
          newState.matchingInfo.isAllowedFood = !isSelected
        case .allowedEarphone:
          newState.matchingInfo.isWearEarphones = !isSelected
        }
      default:
        break
      }
    case let .setText(item, text):
      switch item {
      case .age:
        newState.matchingInfo.age = text
      case .wakeUpTime:
        newState.matchingInfo.wakeUpTime = text
      case .arrangement:
        newState.matchingInfo.cleanUpStatus = text
      case .showerTime:
        newState.matchingInfo.showerTime = text
      case .kakao:
        newState.matchingInfo.openKakaoLink = text
      case .mbti:
        newState.matchingInfo.mbti = text
      case .wantToSay:
        newState.matchingInfo.wishText = text
      default:
        break
      }
    case .setTabBarVC:
      newState.navigateToTabBarVC = true
    case .setReset:
      newState.matchingInfo = .init()
      newState.shouldReset = true 
    case .setRootVC:
      newState.navigateToRootVC = true
    case .setMatchingInfoCardVC:
      newState.navigateToMatchingInfoCardVC = state.matchingInfo
    }
    return newState
  }
  
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      let matchingInfo = state.matchingInfo
      
      newState.sections =
      [
        .dormitory(isFilterSetupVC: false),
        .gender,
        .period,
        .habit(isFilterSetupVC: false),
        .age(isFilterSetupVC: false),
        .wakeUpTime,
        .arrangement,
        .showerTime,
        .kakao,
        .mbti,
        .wantToSay
      ]
      
      newState.items =
      [
        // 기숙사
        Dormitory.allCases.map { .dormitory($0, isSelected: $0 == matchingInfo.dormCategory) },
        // 성별
        Gender.allCases.map { .gender($0, isSelected: $0 == matchingInfo.gender) },
        // 입사 기간
        JoinPeriod.allCases.map { .period($0, isSelected: $0 == matchingInfo.joinPeriod) },
        // 내 습관
        [
          .habit(.snoring, isSelected: matchingInfo.isSnoring),
          .habit(.grinding, isSelected: matchingInfo.isGrinding),
          .habit(.smoking, isSelected: matchingInfo.isSmoking),
          .habit(.allowedFood, isSelected: matchingInfo.isAllowedFood),
          .habit(.allowedEarphone, isSelected: matchingInfo.isWearEarphones)
        ],
        // 나이 -> 정리정돈 -> 샤워시간 -> 오픈채팅 링크 -> MBTI -> 하고싶은 말
        [.age], [.wakeUpTime], [.arrangement], [.showerTime], [.kakao], [.mbti], [.wantToSay]
      ]
      
      if matchingInfo.age.isNotEmpty &&
         matchingInfo.wakeUpTime.isNotEmpty &&
         matchingInfo.cleanUpStatus.isNotEmpty &&
         matchingInfo.showerTime.isNotEmpty &&
         matchingInfo.openKakaoLink.isNotEmpty {
        newState.isEnabledRightButton = true
      } else {
        newState.isEnabledRightButton = false
      }
      
      return newState
    }
  }
}

