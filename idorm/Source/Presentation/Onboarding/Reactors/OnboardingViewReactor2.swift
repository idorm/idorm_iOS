//
//  OnboardingViewReactor2.swift
//  idorm
//
//  Created by 김응철 on 9/15/23.
//

import Foundation

import ReactorKit
import RxCocoa
import RxSwift

final class OnboardingViewReactor2: Reactor {
  
  enum ViewType {
    /// 회원가입 직후
    case signUp
    /// 홈에 들어간 이후
    case theFirstTime
    /// 수정
    case correction
  }
  
  enum Action {
    case itemDidChange(OnboardingSectionItem)
  }
  
  enum Mutation {
    case setDormitory(Dormitory)
    case setGender(Gender)
    case setJoinPeriod(JoinPeriod)
    case setSnoring(Bool)
    case setGrinding(Bool)
    case setSmoking(Bool)
    case setAllowedFood(Bool)
    case setAllowedEarphones(Bool)
    case setAge(String)
    case setWakeUpTime(String)
    case setShowerTime(String)
    case setArrangement(String)
    case setKakaoLink(String)
    case setMBTI(String)
    case setWantToSay(String)
  }
  
  struct State {
    let viewType: ViewType
    
    // 변화하는 상태 값을 저장하기 위함입니다.
    var dormitory: Dormitory = .no1
    var gender: Gender = .male
    var joinPeriod: JoinPeriod = .period_16
    var isSnoring: Bool = false
    var isGrinding: Bool = false
    var isSmoking: Bool = false
    var isAllowedFood: Bool = false
    var isAllowedEarphones: Bool = false
    var age: String = ""
    var wakeUpTime: String = ""
    var showerTime: String = ""
    var arrangement: String = ""
    var kakaoLink: String = ""
    var mbti: String = ""
    var wantToSay: String = ""
    
    /// 이 값은 최초로 뷰를 업데이트할 때와 서버에 해당 데이터를 전송할 때만 사용됩니다.
    var matchingInfo: MatchingInfo = .init()
    
    var sections: [OnboardingSection] = []
    var items: [[OnboardingSectionItem]] = []
  }
  
  // MARK: - Properties
  
  var initialState: State
  
  // MARK: - Initializer
  
  init(_ viewType: ViewType) {
    self.initialState = State(viewType: viewType)
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .itemDidChange(let item):
      switch item {
      case let .dormitory(dormitory, _):
        return .just(.setDormitory(dormitory))
      case .gender(let gender, _):
        return .just(.setGender(gender))
      case .period(let joinPeriod, _):
        return .just(.setJoinPeriod(joinPeriod))
      case let .habit(habit, isSelected):
        switch habit {
        case .snoring:
          return .just(.setSnoring(!isSelected))
        case .grinding:
          return .just(.setGrinding(!isSelected))
        case .smoking:
          return .just(.setSmoking(!isSelected))
        case .allowedFood:
          return .just(.setAllowedFood(!isSelected))
        case .allowedEarphone:
          return .just(.setAllowedEarphones(!isSelected))
        }
      case .age(let age):
        return .just(.setAge(age))
      case .wakeUpTime(let wakeUpTime):
        return .just(.setWakeUpTime(wakeUpTime))
      case .arrangement(let arrangement):
        return .just(.setArrangement(arrangement))
      case .showerTime(let showerTime):
        return .just(.setShowerTime(showerTime))
      case .kakao(let kakaoLink):
        return .just(.setKakaoLink(kakaoLink))
      case .mbti(let mbti):
        return .just(.setMBTI(mbti))
      case .wantToSay(let wantToSay):
        return .just(.setWantToSay(wantToSay))
      }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setDormitory(let dormitory):
      newState.dormitory = dormitory
      
    case .setGender(let gender):
      newState.gender = gender
      
    case .setJoinPeriod(let joinPeriod):
      newState.joinPeriod = joinPeriod
      
    case .setSnoring(let isSnoring):
      newState.isSnoring = isSnoring
      
    case .setGrinding(let isGrinding):
      newState.isGrinding = isGrinding
      
    case .setSmoking(let isSmoking):
      newState.isSmoking = isSmoking
      
    case .setAllowedFood(let isAllowed):
      newState.isAllowedFood = isAllowed
      
    case .setAllowedEarphones(let isAllowed):
      newState.isAllowedEarphones = isAllowed
      
    case .setAge(let age):
      newState.age = age
      
    case .setWakeUpTime(let wakeUpTime):
      newState.wakeUpTime = wakeUpTime
      
    case .setShowerTime(let showerTime):
      newState.showerTime = showerTime
      
    case .setArrangement(let arrangement):
      newState.arrangement = arrangement
      
    case .setKakaoLink(let kakaoLink):
      newState.kakaoLink = kakaoLink
      
    case .setMBTI(let mbti):
      newState.mbti = mbti
      
    case .setWantToSay(let wantToSay):
      newState.wantToSay = wantToSay
    }
    
    return newState
  }
  
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      let matchingInfo = state.matchingInfo
      var items: [[OnboardingSectionItem]] = []
      
      items = [
        // 기숙사
        Dormitory.allCases.map { .dormitory($0, isSelected: $0 == state.dormitory) },
        // 성별
        Gender.allCases.map { .gender($0, isSelected: $0 == state.gender) },
        // 입사 기간
        JoinPeriod.allCases.map { .period($0, isSelected: $0 == state.joinPeriod) },
        // 내 습관
        [
          .habit(.snoring, isSelected: state.isSnoring),
          .habit(.grinding, isSelected: state.isGrinding),
          .habit(.smoking, isSelected: state.isSmoking),
          .habit(.allowedFood, isSelected: state.isAllowedFood),
          .habit(.allowedEarphone, isSelected: state.isAllowedEarphones)
        ],
        // 나이
        [.age(matchingInfo.age)],
        // 기상시간
        [.wakeUpTime(matchingInfo.wakeUpTime)],
        // 정리 정돈
        [.arrangement(matchingInfo.cleanUpStatus)],
        // 샤워 시간
        [.showerTime(matchingInfo.showerTime)],
        // 오픈채팅 링크
        [.kakao(matchingInfo.openKakaoLink)],
        // MBTI
        [.mbti(matchingInfo.mbti)],
        // 하고싶은 말
        [.wantToSay(matchingInfo.wishText)]
      ]
      
      newState.sections = OnboardingSection.allCases
      newState.items = items
      
      return newState
    }
  }
}
