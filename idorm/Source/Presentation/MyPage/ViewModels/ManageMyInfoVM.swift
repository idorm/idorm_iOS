import RxSwift
import RxCocoa

final class ManageMyInfoViewModel: ViewModel {
  struct Input {
    let nicknameButtonTapped = PublishSubject<Void>()
  }
  
  struct Output {
    let showChangeNicknameVC = PublishSubject<Void>()
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
      .bind(to: output.showChangeNicknameVC)
      .disposed(by: disposeBag)
  }
}
