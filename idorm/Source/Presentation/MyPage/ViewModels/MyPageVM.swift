import RxSwift
import RxCocoa

final class MyPageViewModel: ViewModel {
  struct Input {
    // UI
    let gearButtonTapped = PublishSubject<Void>()
    let shareButtonTapped = PublishSubject<Bool>()
    
    // LifeCycle
    let viewWillAppearObserver = PublishSubject<Void>()
  }
  
  struct Output {
    // Presentation
    let pushManageMyInfoVC = PublishSubject<Void>()
  }
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  init() {
    bind()
  }
  
  func bind() {
    
    // 설정 버튼 클릭 -> 내 정보 관리 페이지로 이동
    input.gearButtonTapped
      .bind(to: output.pushManageMyInfoVC)
      .disposed(by: disposeBag)
    
    input.viewWillAppearObserver
      .bind(onNext: { [unowned self] in
        self.requestMemberAPI()
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - Network

extension MyPageViewModel {

  /// 멤버 단건 조회 API 요청
  func requestMemberAPI() {    
    MemberService.memberAPI()
      .subscribe(onNext: { [weak self] response in
        guard let statusCode = response.response?.statusCode else { return }
        switch statusCode {
        case 200: // 멤버 단건 조회 완료
          guard let data = response.data else { return }
          struct ResponseModel: Codable {
            let data: MemberInfomation
          }
          let memberInformation = APIService.decode(ResponseModel.self, data: data).data
          MemberInfomationState.shared.currentMemberInfomation.accept(memberInformation)
        default: break
        }
      })
      .disposed(by: disposeBag)
  }
}
