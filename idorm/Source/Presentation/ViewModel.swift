import RxSwift

protocol ViewModel {
  /// 사용자의 인터렉션
  associatedtype Input
  /// View로 실질적인 값 전달
  associatedtype Output
  
  var input: Input { get }
  var output: Output { get set }
  var disposeBag: DisposeBag { get }
  
  /// Stream을 관리하는 메서드입니다.
  func bind()
}
