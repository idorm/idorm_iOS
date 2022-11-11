import RxSwift
import RxCocoa

final class MyRoommateViewModel: ViewModel {
  struct Input {
    // LifeCycle
    let loadViewObserver = PublishSubject<MyRoommateVCType>()
    
    // Interaction
    let deleteButtonTapped = PublishSubject<(MyRoommateVCType, MatchingMember)>()
    let reportButtonTapped = PublishSubject<Void>()
  }
  
  struct Output {
    // State
    let matchingMembers = BehaviorRelay<[MatchingMember]>(value: [])
    
    // Presentation
    let dismissAlertVC = PublishSubject<Void>()
    
    // UI
    let reloadData = PublishSubject<Void>()
    let indicatorState = PublishSubject<Bool>()
  }
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  var matchingMembers: [MatchingMember] { return output.matchingMembers.value }
  
  init() {
    bind()
  }
  
  func bind() {
    
    // 화면 최초 접속 -> 멤버 조회 요청
    input.loadViewObserver
      .subscribe(onNext: { [weak self] in
        self?.output.indicatorState.onNext(true)
        self?.requestLookupMatchingMembers($0)
      })
      .disposed(by: disposeBag)
    
    input.deleteButtonTapped
      .subscribe(onNext: { [weak self] in
        self?.requestRemoveMatchingMember(type: $0.0, matchingMember: $0.1)
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - Network

extension MyRoommateViewModel {
  
  /// 좋아요 & 싫어요 한 멤버를 조회합니다.
  func requestLookupMatchingMembers(_ type: MyRoommateVCType) {
    struct ResponseModel: Codable {
      let data: [MatchingMember]
    }
    switch type {
    case .like:
      MatchingService.shared.matchingLikedMembers_GET()
        .subscribe(onNext: { [weak self] response in
          guard let statusCode = response.response?.statusCode else { return }
          switch statusCode {
          case 200:
            guard let data = response.data else { return }
            let result = APIService.decode(ResponseModel.self, data: data).data
            self?.output.matchingMembers.accept(result)
            self?.output.reloadData.onNext(Void())
          case 204:
            self?.output.matchingMembers.accept([])
            self?.output.reloadData.onNext(Void())
          default:
            fatalError()
          }
          self?.output.indicatorState.onNext(false)
          self?.output.dismissAlertVC.onNext(Void())
        })
        .disposed(by: disposeBag)
    case .dislike:
      MatchingService.shared.matchingDislikedMembers_GET()
        .subscribe(onNext: { [weak self] response in
          guard let statusCode = response.response?.statusCode else { return }
          switch statusCode {
          case 200:
            guard let data = response.data else { return }
            let result = APIService.decode(ResponseModel.self, data: data).data
            self?.output.matchingMembers.accept(result)
            self?.output.reloadData.onNext(Void())
          case 204:
            self?.output.matchingMembers.accept([])
            self?.output.reloadData.onNext(Void())
          default:
            fatalError()
          }
          self?.output.indicatorState.onNext(false)
          self?.output.dismissAlertVC.onNext(Void())
        })
        .disposed(by: disposeBag)
    }
  }
  
  /// 좋아요 & 싫어요 한 멤버를 삭제합니다.
  func requestRemoveMatchingMember(type: MyRoommateVCType, matchingMember: MatchingMember) {
    output.indicatorState.onNext(true)
    switch type {
    case .like:
      MatchingService.shared.matchingLikedMembers_Delete(matchingMember.memberId)
        .subscribe(onNext: { [weak self] response in
          guard let statusCode = response.response?.statusCode else { return }
          switch statusCode {
          case 200:
            self?.requestLookupMatchingMembers(.like)
          default:
            fatalError()
          }
        })
        .disposed(by: disposeBag)
    case .dislike:
      MatchingService.shared.matchingDislikedMembers_Delete(matchingMember.memberId)
        .subscribe(onNext: { [weak self] response in
          guard let statusCode = response.response?.statusCode else { return }
          switch statusCode {
          case 200:
            self?.requestLookupMatchingMembers(.dislike)
          default:
            fatalError()
          }
        })
        .disposed(by: disposeBag)
    }
  }
}

