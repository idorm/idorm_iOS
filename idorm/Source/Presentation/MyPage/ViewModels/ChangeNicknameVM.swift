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
    let indicatorState = PublishSubject<Bool>()
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
      .do(onNext: { [weak self] _ in
        self?.output.indicatorState.onNext(true)
      })
      .flatMap { APIService.memberProvider.rx.request(.changeNickname(nickname: $0)) }
      .subscribe(onNext: { [weak self] response in
        switch response.statusCode {
        case 200:
          let newInformation = APIService.decode(MemberModel.LoginResponseModel.self, data: response.data).data
          MemberInfoStorage.instance.myInformation.accept(newInformation)
          self?.output.popVC.onNext(Void())
        case 409:
          self?.output.showPopUpVC.onNext("이미 존재하는 닉네임입니다.")
        default:
          fatalError("닉네임을 변경하지 못했습니다,,,")
        }
        self?.output.indicatorState.onNext(false)
      })
      .disposed(by: disposeBag)
  }
}
