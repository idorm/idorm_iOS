import RxSwift

protocol ViewModel {
  associatedtype Input
  associatedtype Output
  
  var input: Input { get }
  var output: Output { get set }
  var disposeBag: DisposeBag { get }
  init()
  func bind()
}
