import RxSwift
import RxCocoa

final class AuthViewModel: ViewModel {
  struct Input {
    let backButtonDidTap = PublishSubject<Void>()
    let portalButtonDidTap = PublishSubject<Void>()
    let confirmButtonDidTap = PublishSubject<Void>()
  }
  
  struct Output {
    let dismissVC = PublishSubject<Void>()
    let presentPortalWeb = PublishSubject<Void>()
    let pushToAuthNumberVC = PublishSubject<Void>()
  }
  
  // MARK: - Properties
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  // MARK: - Bind
  
  init() {
    
    // 뒤로가기 버튼 클릭 -> 화면 닫기
    input.backButtonDidTap
      .bind(to: output.dismissVC)
      .disposed(by: disposeBag)
    
    // 메일함 바로가기 버튼 -> 웹메일 사이트 보여주기
    input.portalButtonDidTap
      .bind(to: output.presentPortalWeb)
      .disposed(by: disposeBag)
    
    // 인증번호 입력 버튼 -> AuthNumberVC 이동
    input.confirmButtonDidTap
      .bind(to: output.pushToAuthNumberVC)
      .disposed(by: disposeBag)
  }
}
