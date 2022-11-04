import RxSwift
import RxCocoa

final class HomeViewModel: ViewModel {
  struct Input {
    // UI
    let startMatchingButtonTapped = PublishSubject<Void>()
  }
  
  struct Output {
    // UI
    let showMatchingPage = PublishSubject<Void>()
  }
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  init() {
    bind()
  }
  
  func bind() {
    
    // 매칭 시작 버튼 클릭 -> 매칭 페이지 전환
    input.startMatchingButtonTapped
      .bind(to: output.showMatchingPage)
      .disposed(by: disposeBag)
  }
}
