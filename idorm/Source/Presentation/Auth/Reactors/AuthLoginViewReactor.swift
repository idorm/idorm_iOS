//
//  LoginViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2022/12/21.
//

import Foundation
import OSLog

import RxSwift
import RxCocoa
import RxMoya
import ReactorKit

final class AuthLoginViewReactor: Reactor {
  
  enum Action {
    case loginButtonDidTap
    case emailTextFieldDidChange(String)
    case passwordTextFieldDidChange(String)
    case signUpButtonDidTap
    case forgotPasswordButtonDidTap
  }
  
  enum Mutation {
    case setEmail(String)
    case setPassword(String)
    case setTabBarVC(Bool)
    case setEmailVC(AuthProcess)
  }
  
  struct State {
    var email: String = ""
    var password: String = ""
    @Pulse var shouldPresentToTabBarVC: Bool = false
    @Pulse var shouldNavigateToEmailVC: AuthProcess?
  }
  
  // MARK: - Properties
  
  var initialState: State = State()
  private let memberNetworkService = NetworkService<MemberAPI>()
  private let matchingInfoNetworkService = NetworkService<MatchingInfoAPI>()
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .emailTextFieldDidChange(let email):
      return .just(.setEmail(email))
      
    case .passwordTextFieldDidChange(let password):
      return .just(.setPassword(password))
      
    case .loginButtonDidTap:
      let email = self.currentState.email
      let password = self.currentState.password
      return self.memberNetworkService.requestAPI(to: .login(
        email: email,
        password: password
      ))
      .flatMap { response in
        let responseDTO = NetworkUtility.decode(
          ResponseDTO<MemberSingleResponseDTO>.self,
          data: response.data
        ).data
        let token = response.response?.headers["authorization"]
        // 멤버의 정보를 저장합니다.
        UserStorage.shared.member = Member(responseDTO)
        // 멤버의 토큰을 저장합니다.
        UserStorage.shared.token = token!
        os_log(.info, "🔓 로그인에 성공하였습니다. 이메일: \(email), 비밀번호: \(password)")
        return self.requestMatchingInfo()
      }
      .catch { error in 
        os_log(.error, "🔐 로그인에 실패하였습니다. 이메일: \(email), 비밀번호: \(password), 실패요인: \(error.localizedDescription)")
        return .empty()
      }
      
    case .forgotPasswordButtonDidTap:
      return .just(.setEmailVC(.findPw))
      
    case .signUpButtonDidTap:
      return .just(.setEmailVC(.signUp))
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setEmail(let email):
      newState.email = email
      
    case .setPassword(let password):
      newState.password = password
       
    case .setEmailVC(let authProcess):
      newState.shouldNavigateToEmailVC = authProcess
      
    case .setTabBarVC(let state):
      newState.shouldPresentToTabBarVC = state
    }
    
    return newState
  }
}

// MARK: - Privates

private extension AuthLoginViewReactor {
  func requestMatchingInfo() -> Observable<Mutation> {
    return self.matchingInfoNetworkService.requestAPI(to: .getMatchingInfo)
      .map(ResponseDTO<MatchingInfoResponseDTO>.self)
      .flatMap { responseDTO in
        // 매칭 정보 저장
        UserStorage.shared.matchingInfo = MatchingInfo(responseDTO.data)
        return Observable<Mutation>.just(.setTabBarVC(true))
      }
  }
}
