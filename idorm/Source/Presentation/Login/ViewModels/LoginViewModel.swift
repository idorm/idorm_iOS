import RxSwift
import RxCocoa

final class LoginViewModel: ViewModel {
  struct Input {
    // UI
    let loginButtonTapped = PublishSubject<Void>()
    let forgotButtonTapped = PublishSubject<Void>()
    let signUpButtonTapped = PublishSubject<Void>()
    let emailText = BehaviorRelay<String>(value: "")
    let passwordText = BehaviorRelay<String>(value: "")
  }
  
  struct Output {
    // Presentation
    let showPutEmailVC = PublishSubject<PutEmailVCType>()
    let showErrorPopupVC = PublishSubject<String>()
    let showTabBarVC = PublishSubject<Void>()
    
    // UI
    let startAnimation = PublishSubject<Void>()
    let stopAnimation = PublishSubject<Void>()
  }
  
  init() {
    bind()
  }
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  var emailText: String {
    return input.emailText.value
  }
  
  var passwordText: String {
    return input.passwordText.value
  }
  
  func bind() {
    
    // 비밀번호 찾기 버튼 클릭 -> PutEmialVC 이동
    input.forgotButtonTapped
      .map { .findPW }
      .bind(to: output.showPutEmailVC)
      .disposed(by: disposeBag)
    
    // 회원가입 버튼 클릭 -> PutEmailVC로 이동
    input.signUpButtonTapped
      .map { .signUp }
      .bind(to: output.showPutEmailVC)
      .disposed(by: disposeBag)
    
    // 로그인 버튼 클릭 -> 로그인 시도 서버로 요청
    input.loginButtonTapped
      .bind(onNext: { [weak self] in
        self?.requestLoginAPI()
      })
      .disposed(by: disposeBag)
    
    // 로그인 버튼 클릭 -> Animation 시작
    input.loginButtonTapped
      .bind(to: output.startAnimation)
      .disposed(by: disposeBag)
  }
}

// MARK: - Network

extension LoginViewModel {
  
  /// 로그인을 요청합니다.
  private func requestLoginAPI() {
    MemberService.shared.LoginAPI(email: self.emailText, password: self.passwordText)
      .subscribe(onNext: { [weak self] response in
        guard let statusCode = response.response?.statusCode else { return }
        guard let data = response.data else { return }
        self?.output.stopAnimation.onNext(Void())
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
          self?.output.showTabBarVC.onNext(Void())
        case 400:
          self?.output.showErrorPopupVC.onNext("가입되지 않은 이메일입니다.")
        case 401:
          self?.output.showErrorPopupVC.onNext("올바르지 않은 비밀번호입니다.")
        default:
          self?.output.showErrorPopupVC.onNext("이메일과 비밀번호를 다시 한번 확인해주세요.")
        }
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
