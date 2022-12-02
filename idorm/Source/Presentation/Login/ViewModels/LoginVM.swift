import RxSwift
import RxCocoa
import RxMoya

final class LoginViewModel: ViewModel {
  struct Input {
    let loginButtonDidTap = PublishSubject<Void>()
    let forgotButtonDidTap = PublishSubject<Void>()
    let signUpButtonDidTap = PublishSubject<Void>()
    let emailTextFieldDidChange = PublishSubject<String>()
    let passwordTextFieldDidChange = PublishSubject<String>()
  }
  
  struct Output {
    let pushToPutEmailVC = PublishSubject<RegisterVCTypes.PutEmailVCType>()
    let presentPopupVC = PublishSubject<String>()
    let presentTabBarVC = PublishSubject<Void>()
    let isLoading = PublishSubject<Bool>()
  }
  
  // MARK: - Properties
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  var currentEmail = BehaviorRelay<String>(value: "")
  var currentPassword = BehaviorRelay<String>(value: "")
  
  // MARK: - Bind
  
  init() {
    mutate()
    
    // 비밀번호 찾기 버튼 클릭 -> PutEmialVC 이동
    input.forgotButtonDidTap
      .map { .findPW }
      .bind(to: output.pushToPutEmailVC)
      .disposed(by: disposeBag)
    
    // 회원가입 버튼 클릭 -> PutEmailVC로 이동
    input.signUpButtonDidTap
      .map { .signUp }
      .bind(to: output.pushToPutEmailVC)
      .disposed(by: disposeBag)
    
    // 로그인 버튼 클릭 -> 로그인 시도 서버로 요청
    input.loginButtonDidTap
      .map { [weak self] in (self?.currentEmail.value ?? "" , self?.currentPassword.value ?? "") }
      .do(onNext: { [weak self] _ in self?.output.isLoading.onNext(true) })
      .flatMap { APIService.memberProvider.rx.request(.login(id: $0.0, pw: $0.1)) }
      .do(onNext: { [weak self] _ in self?.output.isLoading.onNext(false) })
      .subscribe(onNext: { [weak self] response in
        switch response.statusCode {
        case 200: // 로그인 성공
          let data = response.data
          let responseModel = APIService.decode(ResponseModel<MemberModel.MyInformation>.self, data: data).data
          TokenStorage.instance.saveToken(token: responseModel.loginToken ?? "")
          MemberInfoStorage.instance.saveMyInformation(from: responseModel)
          SharedAPI.instance.retrieveMyOnboarding()
          self?.output.presentTabBarVC.onNext(Void())
        case 400:
          self?.output.presentPopupVC.onNext("이메일 입력은 필수입니다.")
        case 404:
          self?.output.presentPopupVC.onNext("등록 혹은 가입되지 않은 이메일입니다.")
        case 409:
          self?.output.presentPopupVC.onNext("올바르지 않은 비밀번호입니다.")
        default: break
        }
      })
      .disposed(by: disposeBag)
  }
  
  func mutate() {
    
    input.emailTextFieldDidChange
      .bind(to: currentEmail)
      .disposed(by: disposeBag)
    
    input.passwordTextFieldDidChange
      .bind(to: currentPassword)
      .disposed(by: disposeBag)
  }
}
