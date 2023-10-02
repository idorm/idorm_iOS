//
//  ManagementMyInfoViewReactor.swift
//  idorm
//
//  Created by 김응철 on 9/29/23.
//

import Foundation

import ReactorKit

final class ManagementMyInfoViewReactor: Reactor {
  
  enum Action {
    case viewWillAppear
    case itemDidSelected(ManagementMyInfoSectionItem)
    case withDrawlButtonDidTap
    case logoutButtonDidTap
    case profileImageViewDidTap
    case removeProfileButtonDidTap
  }
  
  enum Mutation {
    case setAuthNicknameVC
    case setAuthPasswordVC
    case setManagementAccount
    case setTermsOfServicePage
    case setAuthLoginVC
  }
  
  struct State {
    var sections: [ManagementMyInfoSection] = []
    var items: [[ManagementMyInfoSectionItem]] = []
    @Pulse var navigateToAuthNicknameVC: Bool = false
    @Pulse var navigateToAuthPasswordVC: Bool = false
    @Pulse var navigateToManagementAccountVC: Bool = false
    @Pulse var presentToTermsOfServicePage: Bool = false
    @Pulse var navigateToAuthLoginVC: Bool = false
  }
  
  // MARK: - Properties
  
  var initialState: State = State()
  private let memberService = NetworkService<MemberAPI>()
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewWillAppear:
      return .empty()
    case .itemDidSelected(let item):
      switch item {
      case .nickname:
        return .just(.setAuthNicknameVC)
      case .changePassword:
        return .just(.setAuthPasswordVC)
      case .terms:
        return .just(.setTermsOfServicePage)
      default:
        return .empty()
      }
    case .withDrawlButtonDidTap:
      return .just(.setManagementAccount)
    case .profileImageViewDidTap:
      if UserStorage.shared.hasProfileImage {
        ModalManager.presentChangeProfileImageAlert(
          removeHandler: { [weak self] in self?.action.onNext(.removeProfileButtonDidTap)},
          updateHandler: { [weak self] in self?.presentToImagePickerVC() }
        )
        return .empty()
      } else {
        self.presentToImagePickerVC()
        return .empty()
      }
    case .removeProfileButtonDidTap:
      return self.memberService.requestAPI(to: .deleteProfilePhoto)
        .map(ResponseDTO<MemberSingleResponseDTO>.self)
        .flatMap {
          UserStorage.shared.member = Member($0.data)
          return Observable<Mutation>.empty()
        }
    case .logoutButtonDidTap:
      return self.memberService.requestAPI(to: .logout)
        .flatMap { _ in return Observable<Mutation>.just(.setAuthLoginVC) }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setAuthNicknameVC:
      newState.navigateToAuthNicknameVC = true
    case .setAuthPasswordVC:
      newState.navigateToAuthPasswordVC = true
    case .setManagementAccount:
      newState.navigateToManagementAccountVC = true 
    case .setTermsOfServicePage:
      break
    case .setAuthLoginVC:
      newState.navigateToAuthLoginVC = true 
    }
    
    return newState
  }
  
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      
      let member = UserStorage.shared.member ?? .init()
      newState.sections = [.profileImage, .main, .service, .membership]
      newState.items = [
        [.profileImage(imageURL: member.profilePhotoURL)],
        [.nickname(nickname: member.nickname), .changePassword, .email(email: member.email)],
        [.terms, .version],
        [.membership]
      ]
      
      return newState
    }
  }
}

private extension ManagementMyInfoViewReactor {
  func presentToImagePickerVC() {
    ModalManager.presentImagePickerVC(.singleSelection) {
      $0
    }
  }
}
