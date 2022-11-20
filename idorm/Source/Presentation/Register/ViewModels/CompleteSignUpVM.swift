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
    let indicatorState = PublishSubject<Bool>()
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
      .flatMap { [weak self] in
        self?.output.indicatorState.onNext(true)
        let id = Logger.instance.email!
        let password = Logger.instance.password!
        return APIService.memberProvider.rx.request(.login(id: id, pw: password))
      }
      .map(MemberModel.LoginResponseModel.self)
      .subscribe(onNext: { [weak self] response in
        let token = response.data.loginToken
        TokenStorage.instance.saveToken(token: token ?? "")
        SharedAPI.instance.retrieveMyInformation()
        SharedAPI.instance.retrieveMyOnboarding()
        self?.output.indicatorState.onNext(false)
        self?.output.showOnboardingVC.onNext(Void())
      })
      .disposed(by: disposeBag)
  }
}

