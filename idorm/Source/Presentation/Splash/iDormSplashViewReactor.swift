//
//  iDormSplashViewReactor.swift
//  idorm
//
//  Created by 김응철 on 8/26/23.
//

import Foundation
import OSLog

import ReactorKit
import Moya
import RxMoya

final class iDormSplashViewReactor: Reactor {
  
  enum Action {
    case requestFCMToken(fcmToken: String)
  }
  
  enum Mutation {
    case setLoginVC
    case setTabBarVC
  }
  
  struct State {
    @Pulse var shouldNavgiateToLoginVC: Bool = false
    @Pulse var shouldNavigateToTabBarVC: Bool = false
  }
  
  // MARK: - Properties
  
  var initialState: State = State()
  private let disposeBag = DisposeBag()
  private let memberNetworkService = NetworkService<MemberAPI>()
  private let matchingInfoNetworkService = NetworkService<MatchingInfoAPI>()
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .requestFCMToken(let fcmToken):
      return self.requestSingleMemberAPI(fcmToken)
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setLoginVC:
      newState.shouldNavgiateToLoginVC = true
      
    case .setTabBarVC:
      newState.shouldNavigateToTabBarVC = true
    }
    
    return newState
  }
}

// MARK: - Privates

private extension iDormSplashViewReactor {
  func requestSingleMemberAPI(_ token: String) -> Observable<Mutation> {
    let email = UserStorage.shared.email
    let password = UserStorage.shared.password
    return self.memberNetworkService.requestAPI(
      to: .login(email: email, password: password, fcmToken: token)
    ).flatMap { response in
      do {
        let response = try response.filterSuccessfulStatusCodes()
        let token = response.response?.headers["authorization"]
        let responseDTO = NetworkUtility.decode(
          ResponseDTO<MemberResponseModel.Member>.self,
          data: response.data
        ).data
        UserStorage.shared.saveMember(responseDTO)
        UserStorage.shared.saveToken(token)
        os_log(.info, "🔓 로그인에 성공하였습니다. 이메일: \(email), 비밀번호: \(password)")
        return self.requestMemberMatchingInfo()
      } catch (let error) {
        FilterStorage.shared.resetFilter()
        UserStorage.shared.reset()
        UserStorage.shared.resetToken()
        os_log(.error, "🔐 로그인에 실패하였습니다. 이메일: \(email), 비밀번호: \(password), 실패요인: \(error.localizedDescription)")
        return Observable<Mutation>.just(.setLoginVC)
      }
    }
  }
  
  /// 해당 회원의 매칭 정보를 가져옵니다.
  func requestMemberMatchingInfo() -> Observable<Mutation> {
    return self.matchingInfoNetworkService.requestAPI(to: .retrieve)
      .flatMap { response in
        do {
          let response = try response.filterSuccessfulStatusCodes()
          let responseDTO = NetworkUtility.decode(
            ResponseDTO<MatchingInfoResponseModel.MatchingInfo>.self,
            data: response.data
          ).data
          UserStorage.shared.saveMatchingInfo(responseDTO)
          return Observable<Mutation>.just(.setTabBarVC)
        } catch (let error) {
          FilterStorage.shared.resetFilter()
          UserStorage.shared.reset()
          UserStorage.shared.resetToken()
          os_log(.error, "🔴 회원의 매칭 정보르 조회를 실패했습니다. \(error.localizedDescription)")
          return Observable<Mutation>.just(.setLoginVC)
        }
      }
  }
}
