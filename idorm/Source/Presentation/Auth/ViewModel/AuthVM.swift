import RxSwift
import RxCocoa

final class AuthViewModel: ViewModel {
  struct Input {
    // Interaction
    let backButtonTapped = PublishSubject<Void>()
    let portalButtonTapped = PublishSubject<Void>()
    let confirmButtonTapped = PublishSubject<Void>()
  }
  
  struct Output {
    // Presentation
    let dismissVC = PublishSubject<Void>()
    let showPortalWeb = PublishSubject<Void>()
    let showAuthNumberVC = PublishSubject<Void>()
  }
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  init() {
    bind()
  }
  
  func bind() {
    
    // 뒤로가기 버튼 클릭 -> 화면 닫기
    input.backButtonTapped
      .bind(to: output.dismissVC)
      .disposed(by: disposeBag)
    
    // 메일함 바로가기 버튼 -> 웹메일 사이트 보여주기
    input.portalButtonTapped
      .bind(to: output.showPortalWeb)
      .disposed(by: disposeBag)
    
    // 인증번호 입력 버튼 -> AuthNumberVC 이동
    input.confirmButtonTapped
      .bind(to: output.showAuthNumberVC)
      .disposed(by: disposeBag)
  }
}
