import RxSwift
import RxCocoa

final class HomeViewModel: ViewModel {
  struct Input {
    let startMatchingButtonTapped = PublishSubject<Void>()
  }
  
  struct Output {
    let showMatchingPage = PublishSubject<Void>()
  }
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  init() {
    
    // 매칭 시작 버튼 클릭 -> 매칭 페이지 전환
    input.startMatchingButtonTapped
      .bind(to: output.showMatchingPage)
      .disposed(by: disposeBag)
  }
}
