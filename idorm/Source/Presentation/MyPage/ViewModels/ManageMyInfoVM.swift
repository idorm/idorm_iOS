import RxSwift
import RxCocoa

final class ManageMyInfoViewModel: ViewModel {
  struct Input {
    // Interaction
    let nicknameButtonTapped = PublishSubject<Void>()
    let changedPWButtonTapped = PublishSubject<Void>()
  }
  
  struct Output {
    // Presentation
    let pushToChangeNicknameVC = PublishSubject<Void>()
    let pushToPutEmailVC = PublishSubject<Void>()
  }
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  init() {
    bind()
  }
  
  func bind() {
    
    // 닉네임 버튼 클릭 -> ChangeNicknameVC 보여주기
    input.nicknameButtonTapped
      .bind(to: output.pushToChangeNicknameVC)
      .disposed(by: disposeBag)
    
    // 비밀번호 변경 벼튼 클릭 -> PutEmailVC로 이동
    input.changedPWButtonTapped
      .bind(to: output.pushToPutEmailVC)
      .disposed(by: disposeBag)
  }
}
