import RxSwift
import RxCocoa

final class ManageMyInfoViewModel: ViewModel {
  
  // MARK: - Properties
  
  struct Input {
    // Interaction
    let nicknameButtonTapped = PublishSubject<Void>()
    let changedPWButtonTapped = PublishSubject<Void>()
    let withdrawalButtonDidTap = PublishSubject<Void>()
  }
  
  struct Output {
    // Presentation
    let pushToChangeNicknameVC = PublishSubject<Void>()
    let pushToPutEmailVC = PublishSubject<Void>()
    let pushToWithdrawalVC = PublishSubject<Void>()
  }
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  // MARK: - Bind
  
  init() {
    
    // 닉네임 버튼 클릭 -> ChangeNicknameVC 보여주기
    input.nicknameButtonTapped
      .bind(to: output.pushToChangeNicknameVC)
      .disposed(by: disposeBag)
    
    // 비밀번호 변경 벼튼 클릭 -> PutEmailVC로 이동
    input.changedPWButtonTapped
      .bind(to: output.pushToPutEmailVC)
      .disposed(by: disposeBag)
    
    // 회원탈퇴 버튼 클릭 -> 회원탈퇴 페이지로 이동
    input.withdrawalButtonDidTap
      .bind(to: output.pushToWithdrawalVC)
      .disposed(by: disposeBag)
  }
}
