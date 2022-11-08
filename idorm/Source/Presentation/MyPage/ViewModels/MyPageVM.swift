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
  }
}
