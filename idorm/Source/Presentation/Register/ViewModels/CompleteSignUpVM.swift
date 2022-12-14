import Foundation

import RxSwift
import RxCocoa
import RxMoya

final class CompleteSignUpViewModel: ViewModel {
  struct Input {
    let continueButtonDidTap = PublishSubject<Void>()
  }
  
  struct Output {
    let presentOnboardingVC = PublishSubject<Void>()
    let presentPopupVC = PublishSubject<String>()
    let isLoading = PublishSubject<Bool>()
  }
  
  // MARK: - Properties
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  init() {
    
    let email = Logger.instance.currentEmail.value
    let password = Logger.instance.currentPassword.value
    
    // 로그인 버튼 클릭 -> 로그인 API 요청
    input.continueButtonDidTap
      .withUnretained(self)
      .do { $0.0.output.isLoading.onNext(true) }
      .flatMap { _ in
        APIService.memberProvider.rx.request(.login(id: email, pw: password))
          .asObservable()
          .materialize()
      }
      .withUnretained(self)
      .subscribe { owner, event in
        owner.output.isLoading.onNext(false)
        
        switch event {
        case .next(let response):
          if response.statusCode == 200 {
            let info = APIService.decode(
              ResponseModel<MemberModel.MyInformation>.self,
              data: response.data
            ).data
            MemberInfoStorage.instance.saveMyInformation(from: info)
            TokenStorage.instance.saveToken(token: info.loginToken ?? "")
            owner.output.presentOnboardingVC.onNext(Void())
          } else {
            let error = APIService.decode(ErrorResponseModel.self, data: response.data)
            owner.output.presentPopupVC.onNext(error.message)
          }
        case .error:
          owner.output.presentPopupVC.onNext("네트워크를 다시 확인해주세요.")
        case .completed:
          break
        }
      }
      .disposed(by: disposeBag)
  }
}
