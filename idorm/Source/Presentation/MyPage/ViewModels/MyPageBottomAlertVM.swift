import RxSwift
import RxCocoa

final class MyPageBottomAlertViewModel: ViewModel {
  struct Input {
    // Interaction
    let xmarkButtonTapped = PublishSubject<Void>()
    let deleteButtonTapped = PublishSubject<Void>()
    let reportButtonTapped = PublishSubject<Void>()
  }
  
  struct Output {
    // Presentation
    let dismissVC = PublishSubject<Void>()
  }
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  init() {
    bind()
  }
  
  func bind() {
    
    // 취소 버튼 클릭 -> 뒤로가기
    input.xmarkButtonTapped
      .bind(to: output.dismissVC)
      .disposed(by: disposeBag)
    
    // 멤버 삭제 버튼 클릭 -> 매칭 멤버 삭제 API 요청
    input.deleteButtonTapped
      .bind(onNext: { [unowned self] in
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - Network

extension MyPageBottomAlertViewModel {
  private func requestDeleteMatchingMemberAPI() {
    
  }
}
