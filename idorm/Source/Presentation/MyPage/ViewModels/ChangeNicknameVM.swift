import RxSwift
import RxCocoa

final class ChangeNicknameViewModel: ViewModel {
  struct Input {
    // Interaction
    let confirmButtonTapped = PublishSubject<String>()
  }
  
  struct Output {
    // Presentation
    let popVC = PublishSubject<Void>()
    let showPopUpVC = PublishSubject<String>()
    
    // UI
    let isEnableInteraction = PublishSubject<Bool>()
  }
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  init() {
    bind()
  }
  
  func bind() {
    
    // 완료 버튼 클릭 -> 닉네임 변경 API 요청
    input.confirmButtonTapped
      .bind(onNext: { [unowned self] nickname in
        self.requestChangeNicknameAPI(from: nickname)
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - Network

extension ChangeNicknameViewModel {
  func requestChangeNicknameAPI(from nickname: String) {
    output.isEnableInteraction.onNext(false)
    MemberService.instance.changeNicknameAPI(from: nickname)
      .subscribe(onNext: { [unowned self] response in
        guard let statusCode = response.response?.statusCode else { return }
        switch statusCode {
        case 200: // 닉네임 변경 완료
          var newInfo = MemberInfoStorage.instance.myInformation.value
          newInfo.nickname = nickname
          MemberInfoStorage.instance.myInformation.accept(newInfo)
          self.output.popVC.onNext(Void())
        case 400: // 닉네임 입력은 필수입니다.
          break
        case 401: // 로그인이 필요합니다.
          break
        case 409: // 기존의 닉네임과 같습니다. 혹은 이미 존재하는 닉네임입니다.
          break
        default: // 서버에러
          break
        }
        self.output.isEnableInteraction.onNext(true)
      })
      .disposed(by: disposeBag)
  }
}
