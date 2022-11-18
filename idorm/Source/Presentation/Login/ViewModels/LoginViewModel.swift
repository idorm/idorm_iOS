import RxSwift
import RxCocoa
import RxMoya

final class LoginViewModel: ViewModel {
  struct Input {
    // Interaction
    let loginButtonTapped = PublishSubject<(id: String, pw: String)>()
    let forgotButtonTapped = PublishSubject<Void>()
    let signUpButtonTapped = PublishSubject<Void>()
  }
  
  struct Output {
    // Presentation
    let showPutEmailVC = PublishSubject<RegisterVCTypes.PutEmailVCType>()
    let showErrorPopupVC = PublishSubject<String>()
    let showTabBarVC = PublishSubject<Void>()
    
    // UI
    let isLoading = PublishSubject<Bool>()
  }
  
  init() {
    bind()
  }
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
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
      .do(onNext: { [weak self] _ in
        self?.output.isLoading.onNext(true)
      })
        .flatMap {
          return APIService.memberProvider.rx.request(.login(id: $0.id, pw: $0.pw))
      }
      .do(onNext: { [weak self] _ in
        self?.output.isLoading.onNext(false)
      })
      .subscribe(onNext: { [weak self] response in
        switch response.statusCode {
        case 200: // 로그인 성공
          let data = response.data
          let responseModel = APIService.decode(MemberModel.LoginResponseModel.self, data: data).data
          TokenStorage.instance.saveToken(token: responseModel.loginToken)
          MemberInfoStorage.instance.myInformation.accept(responseModel)
          SharedAPI.instance.retrieveMyOnboarding()
          self?.output.showTabBarVC.onNext(Void())
        case 400:
          self?.output.showErrorPopupVC.onNext("이메일 입력은 필수입니다.")
        case 404:
          self?.output.showErrorPopupVC.onNext("등록 혹은 가입되지 않은 이메일입니다.")
        case 409:
          self?.output.showErrorPopupVC.onNext("올바르지 않은 비밀번호입니다.")
        default: break
        }
      })
      .disposed(by: disposeBag)
    }
}
