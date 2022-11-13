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
          self?.output.showOnboardingVC.onNext(Void())
        default:
          fatalError("LoginAPI ERROR!")
        }
        self?.output.animationState.onNext(false)
      })
      .disposed(by: disposeBag)
  }
}
