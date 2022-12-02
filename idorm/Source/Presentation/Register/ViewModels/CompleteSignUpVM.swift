import Foundation

import RxSwift
import RxCocoa

final class CompleteSignUpViewModel: ViewModel {
  struct Input {
    let continueButtonDidTap = PublishSubject<Void>()
  }
  
  struct Output {
    let presentOnboardingVC = PublishSubject<Void>()
    let isLoading = PublishSubject<Bool>()
  }
  
  // MARK: - Properties
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  init() {
    
    let email = Logger.instance.currentEmail.value
    let password = Logger.instance.currentPassword.value
    
    // 로그인 버튼 클릭 -> 회원가입API 요청
    input.continueButtonDidTap
      .do(onNext: { [weak self] in self?.output.isLoading.onNext(true) })
      .flatMap { APIService.memberProvider.rx.request(.login(id: email, pw: password)) }
      .map(ResponseModel<MemberModel.MyInformation>.self)
      .do(onNext: { [weak self] _ in self?.output.isLoading.onNext(false) })
      .subscribe(onNext: { [weak self] response in
        let token = response.data.loginToken
        TokenStorage.instance.saveToken(token: token ?? "")
        SharedAPI.instance.retrieveMyInformation()
        SharedAPI.instance.retrieveMyOnboarding()
        self?.output.presentOnboardingVC.onNext(Void())
      })
      .disposed(by: disposeBag)
  }
}
