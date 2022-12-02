import RxSwift
import RxCocoa
import RxMoya

final class MyRoommateViewModel: ViewModel {
  
  // MARK: - Properties
  
  struct Input {
    let viewWillAppear = PublishSubject<MyPageVCTypes.MyRoommateVCType>()
    let deleteButtonDidTap = PublishSubject<(MyPageVCTypes.MyRoommateVCType, MatchingModel.Member)>()
    let reportButtonDidTap = PublishSubject<Void>()
    let lastestButtonDidTap = PublishSubject<MyRoommateSortType>()
    let pastButtonDidTap = PublishSubject<MyRoommateSortType>()
  }
  
  struct Output {
    let dismissAlertVC = PublishSubject<Void>()
    let reloadData = PublishSubject<Void>()
    let isLoading = PublishSubject<Bool>()
    let toggleSortButton = PublishSubject<MyRoommateSortType>()
  }
  
  // MARK: - Properties
    
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  var currentMembers = BehaviorRelay<[MatchingModel.Member]>(value: [])
  
  let requestRetrieveLikeAPI = PublishSubject<Void>()
  let requestRetrieveDislikeAPI = PublishSubject<Void>()
  let requestDeleteLikeAPI = PublishSubject<MatchingModel.Member>()
  let requestDeleteDislikeAPI = PublishSubject<MatchingModel.Member>()
  
  // MARK: - Bind
  
  init() {
    mutate()
    
    // 최신순 버튼 클릭 -> 버튼 토글
    input.lastestButtonDidTap
      .bind(to: output.toggleSortButton)
      .disposed(by: disposeBag)
    
    // 과거순 버튼 클릭 -> 버튼 토글
    input.pastButtonDidTap
      .bind(to: output.toggleSortButton)
      .disposed(by: disposeBag)
    
    // 현재 참조하고 있는 멤버 반응 -> 테이블뷰 리로드
    currentMembers
      .withUnretained(self)
      .map { _ in Void() }
      .bind(to: output.reloadData)
      .disposed(by: disposeBag)
        
    // 화면 최초 접속 -> 멤버 조회 요청
    input.viewWillAppear
      .withUnretained(self)
      .subscribe(onNext: { owner, type in
        switch type {
        case .dislike: owner.requestRetrieveDislikeAPI.onNext(Void())
        case .like: owner.requestRetrieveLikeAPI.onNext(Void())
        }
      })
      .disposed(by: disposeBag)
        
    // 삭제 버튼 클릭 -> 특정 멤버 삭제 API
    input.deleteButtonDidTap
      .withUnretained(self)
      .subscribe(onNext: { owner, data in
        switch data.0 {
        case .like: owner.requestDeleteLikeAPI.onNext(data.1)
        case .dislike: owner.requestDeleteDislikeAPI.onNext(data.1)
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func mutate() {
    
    // 정렬 타입 변경 감지 -> 정렬 바꾸기 요청
    Observable.merge(
      input.pastButtonDidTap.asObservable(),
      input.lastestButtonDidTap.asObservable()
    )
    .distinctUntilChanged()
    .withUnretained(self)
    .do(onNext: { $0.0.output.isLoading.onNext(true) })
    .map { $0.0.currentMembers.value.reversed() }
    .bind(to: currentMembers)
    .disposed(by: disposeBag)
    
    // 좋아요 한 멤버 요청
    requestRetrieveLikeAPI
      .withUnretained(self)
      .do(onNext: { $0.0.output.isLoading.onNext(true) })
      .flatMap { _ in APIService.matchingProvider.rx.request(.retrieveLiked) }
      .withUnretained(self)
      .do(onNext: { $0.0.output.isLoading.onNext(false) })
      .subscribe(onNext: { owner, response in
        switch response.statusCode {
        case 200:
          let members = APIService.decode(ResponseModel<[MatchingModel.Member]>.self, data: response.data).data
          owner.currentMembers.accept(members.reversed())
        case 204:
          owner.currentMembers.accept([])
        default:
          fatalError("좋아요한 멤버를 조회하지 못했습니다,,,")
        }
        owner.output.dismissAlertVC.onNext(Void())
      })
      .disposed(by: disposeBag)
        
    // 싫어요 한 멤버 요청
    requestRetrieveDislikeAPI
      .withUnretained(self)
      .do(onNext: { $0.0.output.isLoading.onNext(true) })
      .flatMap { _ in APIService.matchingProvider.rx.request(.retrieveDisliked) }
      .withUnretained(self)
      .do(onNext: { $0.0.output.isLoading.onNext(false) })
      .subscribe(onNext: { owner, response in
        switch response.statusCode {
        case 200:
          let members = APIService.decode(ResponseModel<[MatchingModel.Member]>.self, data: response.data).data
          owner.currentMembers.accept(members.reversed())
        case 204:
          owner.currentMembers.accept([])
        default:
          fatalError("싫어요한 멤버를 조회하지 못했습니다,,,")
        }
        owner.output.dismissAlertVC.onNext(Void())
      })
      .disposed(by: disposeBag)
    
    // 좋아요한 멤버 삭제 요청
    requestDeleteLikeAPI
      .withUnretained(self)
      .do(onNext: { $0.0.output.isLoading.onNext(true) })
      .flatMap { APIService.matchingProvider.rx.request(.deleteLiked($1.memberId)) }
      .filterSuccessfulStatusCodes()
      .withUnretained(self)
      .do(onNext: { $0.0.output.isLoading.onNext(false) })
      .map { _ in Void() }
      .bind(to: requestRetrieveLikeAPI)
      .disposed(by: disposeBag)
    
    // 좋아요한 멤버 삭제 요청
    requestDeleteDislikeAPI
      .withUnretained(self)
      .do(onNext: { $0.0.output.isLoading.onNext(true) })
      .flatMap { APIService.matchingProvider.rx.request(.deleteDisliked($1.memberId)) }
      .filterSuccessfulStatusCodes()
      .withUnretained(self)
      .do(onNext: { $0.0.output.isLoading.onNext(false) })
      .map { _ in Void() }
      .bind(to: requestRetrieveDislikeAPI)
      .disposed(by: disposeBag)
  }
}
