import RxSwift
import RxCocoa
import RxOptional

final class ManageMyInfoViewModel: ViewModel {
  
  // MARK: - Properties
  
  struct Input {
    let nicknameButtonDidTap = PublishSubject<Void>()
    let changePWButtonDidTap = PublishSubject<Void>()
    let withdrawalButtonDidTap = PublishSubject<Void>()
    let viewWillAppear = PublishSubject<Void>()
  }
  
  struct Output {
    let pushToChangeNicknameVC = PublishSubject<Void>()
    let pushToPutEmailVC = PublishSubject<Void>()
    let pushToWithdrawalVC = PublishSubject<Void>()
    let updateEmail = PublishSubject<String>()
    let updateNickname = PublishSubject<String>()
  }
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  // MARK: - Bind
  
  init() {
    
    // 닉네임 버튼 클릭 -> ChangeNicknameVC 보여주기
    input.nicknameButtonDidTap
      .bind(to: output.pushToChangeNicknameVC)
      .disposed(by: disposeBag)
    
    // 비밀번호 변경 벼튼 클릭 -> PutEmailVC로 이동
    input.changePWButtonDidTap
      .bind(to: output.pushToPutEmailVC)
      .disposed(by: disposeBag)
    
    // 회원탈퇴 버튼 클릭 -> 회원탈퇴 페이지로 이동
    input.withdrawalButtonDidTap
      .bind(to: output.pushToWithdrawalVC)
      .disposed(by: disposeBag)
    
    // 화면 최초 접속 -> 닉네임 업데이트
    input.viewWillAppear
      .map { MemberInfoStorage.instance.myInformation.value?.nickname }
      .filterNil()
      .bind(to: output.updateNickname)
      .disposed(by: disposeBag)
    
    // 화면 최초 접속 -> 이메일 업데이트
    input.viewWillAppear
      .map { MemberInfoStorage.instance.myInformation.value?.email }
      .filterNil()
      .bind(to: output.updateEmail)
      .disposed(by: disposeBag)
  }
}
