import Foundation

import RxSwift
import RxCocoa

final class CompleteSignUpViewModel: ViewModel {
  struct Input {
    // Interaction
    let continueButtonTapped = PublishSubject<Void>()
  }
  
  struct Output {
    // Presentation
    let showOnboardingVC = PublishSubject<Void>()
    
    // UI
    let animationState = PublishSubject<Bool>()
  }
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  init() {
    bind()
  }
  
  func bind() {
    
    // 로그인 버튼 클릭 -> 회원가입API 요청
    input.continueButtonTapped
      .bind(onNext: { [weak self] in
        self?.LoginAPI()
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - Network

extension CompleteSignUpViewModel {
  
  /// 로그인 요청 API
  func LoginAPI() {
    guard let email = Logger.instance.email else { return }
    guard let password = Logger.instance.password else { return }
    output.animationState.onNext(true)
    
    MemberService.shared.LoginAPI(email: email, password: password)
      .subscribe(onNext: { [weak self] response in
        guard let statusCode = response.response?.statusCode else { return }
        guard let data = response.data else { return }
        switch statusCode {
        case 200:
          struct LoginResponseModel: Codable {
            struct Response: Codable {
              let loginToken: String
            }
            let data: Response
          }
          let token = APIService.decode(LoginResponseModel.self, data: data).data.loginToken
          TokenStorage.shared.saveToken(token: token)
          self?.requestMemberAPI()
          self?.requestMatchingInfo()
          self?.output.showOnboardingVC.onNext(Void())
        default:
          fatalError("LoginAPI ERROR!")
        }
        self?.output.animationState.onNext(false)
      })
      .disposed(by: disposeBag)
  }
  
  /// 멤버 단건 조회 API 요청
  func requestMemberAPI() {
    MemberService.shared.memberAPI()
      .subscribe(onNext: { response in
        guard let statusCode = response.response?.statusCode else { return }
        switch statusCode {
        case 200: // 멤버 단건 조회 완료
          guard let data = response.data else { return }
          struct ResponseModel: Codable {
            let data: MemberInfo
          }
          let memberInformation = APIService.decode(ResponseModel.self, data: data).data
          MemberInfoStorage.shared.memberInfo.accept(memberInformation)
        default: break
        }
      })
      .disposed(by: disposeBag)
  }
  
  /// 매칭 정보 확인 API
  func requestMatchingInfo() {
    OnboardingService.shared.matchingInfoAPI_Get()
      .subscribe(onNext: { response in
        guard let statusCode = response.response?.statusCode else { return }
        switch statusCode {
        case 200:
          guard let data = response.data else { return }
          struct ResponseModel: Codable {
            let data: MatchingInfo_Lookup
          }
          let matchingInfo = APIService.decode(ResponseModel.self, data: data).data
          MemberInfoStorage.shared.matchingInfo.accept(matchingInfo)
        case 409:
          break
        default: // 서버 오류 & 로그인 오류
          fatalError()
        }
      })
      .disposed(by: disposeBag)
  }
}
