import Foundation

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
      .withUnretained(self)
      .map { ($0.0.currentEmail.value, $0.0.currentPassword.value) }
      .withUnretained(self)
      .do(onNext: { $0.0.output.isLoading.onNext(true) })
      .flatMap {
        APIService.memberProvider.rx.request(.login(id: $0.1.0, pw: $0.1.1))
          .asObservable()
          .materialize()
      }
      .withUnretained(self)
      .do(onNext: { $0.0.output.isLoading.onNext(false) })
      .subscribe { owner, event in
        switch event {
        case .next(let response):
          if response.statusCode == 200 {
            let info = APIService.decode(
              ResponseModel<MemberModel.MyInformation>.self,
              data: response.data
            ).data
            TokenStorage.instance.saveToken(token: info.loginToken ?? "")
            MemberInfoStorage.instance.saveMyInformation(from: info)
            SharedAPI.instance.retrieveMyOnboarding()
            owner.output.presentTabBarVC.onNext(Void())
          } else {
            let error = APIService.decode(ErrorResponseModel.self, data: response.data)
            owner.output.presentPopupVC.onNext(error.message)
          }
        case .error:
          owner.output.presentPopupVC.onNext("네트워크를 다시 확인해주세요.")
        default: break
        }
      }
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
