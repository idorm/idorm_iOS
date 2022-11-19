import RxSwift
import RxCocoa

final class MyRoommateViewModel: ViewModel {
  struct Input {
    // LifeCycle
    let loadViewObserver = PublishSubject<MyPageVCTypes.MyRoommateVCType>()
    
    // Request
    let requestRetrieveLikeAPI = PublishSubject<Void>()
    let requestRetrieveDislikeAPI = PublishSubject<Void>()
    let requestDeleteLikeAPI = PublishSubject<MatchingModel.Member>()
    let requestDeleteDislikeAPI = PublishSubject<MatchingModel.Member>()
    
    // Interaction
    let deleteButtonTapped = PublishSubject<(MyPageVCTypes.MyRoommateVCType, MatchingModel.Member)>()
    let reportButtonTapped = PublishSubject<Void>()
  }
  
  struct Output {
    // State
    let matchingMembers = BehaviorRelay<[MatchingModel.Member]>(value: [])
    
    // Presentation
    let dismissAlertVC = PublishSubject<Void>()
    
    // UI
    let reloadData = PublishSubject<Void>()
    let indicatorState = PublishSubject<Bool>()
  }
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  var members: [MatchingModel.Member] { return output.matchingMembers.value }
  
  init() {
    bind()
  }
  
  func bind() {
    
    // 화면 최초 접속 -> 멤버 조회 요청
    input.loadViewObserver
      .subscribe(onNext: { [weak self] in
        switch $0 {
        case .dislike:
          self?.input.requestRetrieveDislikeAPI.onNext(Void())
        case .like:
          self?.input.requestRetrieveLikeAPI.onNext(Void())
        }
      })
      .disposed(by: disposeBag)
        
    // 삭제 버튼 클릭 -> 특정 멤버 삭제 API
    input.deleteButtonTapped
      .subscribe(onNext: { [weak self] in
        switch $0.0 {
        case .like:
          self?.input.requestDeleteLikeAPI.onNext($0.1)
        case .dislike:
          self?.input.requestDeleteDislikeAPI.onNext($0.1)
        }
      })
      .disposed(by: disposeBag)
        
    // 좋아요 한 멤버 요청
    input.requestRetrieveLikeAPI
      .do(onNext: { [weak self] in
        self?.output.indicatorState.onNext(true)
      })
      .flatMap { APIService.matchingProvider.rx.request(.retrieveLiked) }
      .subscribe(onNext: { [weak self] response in
        switch response.statusCode {
        case 200:
          let members = APIService.decode(MatchingModel.MatchingResponseModel.self, data: response.data).data
          self?.output.matchingMembers.accept(members)
          self?.output.reloadData.onNext(Void())
        case 204:
          self?.output.matchingMembers.accept([])
          self?.output.reloadData.onNext(Void())
        default:
          fatalError("좋아요한 멤버를 조회하지 못했습니다,,,")
        }
        self?.output.indicatorState.onNext(false)
        self?.output.dismissAlertVC.onNext(Void())
      })
      .disposed(by: disposeBag)
    
    // 싫어요 한 멤버 요청
    input.requestRetrieveDislikeAPI
      .do(onNext: { [weak self] in
        self?.output.indicatorState.onNext(true)
      })
      .flatMap { APIService.matchingProvider.rx.request(.retrieveDisliked) }
      .subscribe(onNext: { [weak self] response in
        switch response.statusCode {
        case 200:
          let members = APIService.decode(MatchingModel.MatchingResponseModel.self, data: response.data).data
          self?.output.matchingMembers.accept(members)
          self?.output.reloadData.onNext(Void())
        case 204:
          self?.output.matchingMembers.accept([])
          self?.output.reloadData.onNext(Void())
        default:
          fatalError("좋아요한 멤버를 조회하지 못했습니다,,,")
        }
        self?.output.indicatorState.onNext(false)
        self?.output.dismissAlertVC.onNext(Void())
      })
      .disposed(by: disposeBag)
    
    // 좋아요한 멤버 삭제 요청
    input.requestDeleteLikeAPI
      .do(onNext: { [weak self] _ in
        self?.output.indicatorState.onNext(true)
      })
      .flatMap { APIService.matchingProvider.rx.request(.deleteLiked($0.memberId)) }
      .subscribe(onNext: { [weak self] response in
        switch response.statusCode {
        case 200:
          self?.input.requestRetrieveLikeAPI.onNext(Void())
        default:
          fatalError("멤버를 삭제하지 못했습니다...")
        }
        self?.output.indicatorState.onNext(false)
      })
      .disposed(by: disposeBag)
    
    // 좋아요한 멤버 삭제 요청
    input.requestDeleteDislikeAPI
      .do(onNext: { [weak self] _ in
        self?.output.indicatorState.onNext(true)
      })
      .flatMap { APIService.matchingProvider.rx.request(.deleteDisliked($0.memberId)) }
      .subscribe(onNext: { [weak self] response in
        switch response.statusCode {
        case 200:
          self?.input.requestRetrieveDislikeAPI.onNext(Void())
        default:
          fatalError("멤버를 삭제하지 못했습니다...")
        }
        self?.output.indicatorState.onNext(false)
      })
      .disposed(by: disposeBag)
  }
}
