import UIKit

import RxSwift
import RxCocoa

final class MatchingViewModel: ViewModel {
  struct Input {
    // Interaction
    let cancelButtonObserver = PublishSubject<Void>()
    let backButtonObserver = PublishSubject<Void>()
    let messageButtonObserver = PublishSubject<Void>()
    let heartButtonObserver = PublishSubject<Void>()
    let filterButtonObserver = PublishSubject<Void>()
    let resetFilterButtonTapped = PublishSubject<Void>()
    let confirmFilteringButtonTapped = PublishSubject<Void>()
    
    // Popup
    let publicButtonTapped = PublishSubject<Void>()
        
    // Card
    let swipeObserver = PublishSubject<MatchingType>()
    let didEndSwipeObserver = PublishSubject<MatchingSwipeType>()
    
    let likeMemberObserver = PublishSubject<Int>()
    let dislikeMemberObserver = PublishSubject<Int>()
    
    // Observing
    let isUpdatedPublicState = PublishSubject<Bool>()
    let hasMatchingInfo = PublishSubject<Bool>()
    let viewDidLoad = PublishSubject<Void>()
  }
  
  struct Output {
    // UI
    let onChangedTopBackgroundColor = PublishSubject<MatchingType>()
    let onChangedTopBackgroundColor_WithTouch = PublishSubject<MatchingType>()
    let drawBackTopBackgroundColor = PublishSubject<Void>()
    let informationImageViewStatus = PublishSubject<MatchingImageViewType>()
    
    // Presentation
    let showFilterVC = PublishSubject<Void>()
    let showFirstPopupVC = PublishSubject<Void>()
    let showNoSharePopupVC = PublishSubject<Void>()
    
    let dismissNoSharePopupVC = PublishSubject<Void>()
    
    // Loading
    let indicatorState = PublishSubject<Bool>()
    
    // Card
    let reloadCardStack = PublishSubject<Void>()
    let matchingMembers = BehaviorRelay<[MatchingMember]>(value: [])
  }
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  init() {
    bind()
  }
  
  // MARK: - Bind
  
  func bind() {
    
    // ViewDidLoad -> 매칭 초기 상태 판단
    input.viewDidLoad
      .subscribe(onNext: { [weak self] in
        let storage = MemberInfoStorage.shared
        
        if storage.hasMatchingInfo {
          
          if storage.isPublicMatchingInfo {
            self?.output.informationImageViewStatus.onNext(.noMatchingCardInformation)
            self?.requestMatchingAPI()
          } else {
            self?.output.informationImageViewStatus.onNext(.noShareState)
            self?.output.showNoSharePopupVC.onNext(Void())
          }
          
        } else {
          self?.output.informationImageViewStatus.onNext(.noMatchingInformation)
          self?.output.showFirstPopupVC.onNext(Void())
        }
      })
      .disposed(by: disposeBag)
    
    // 자신의 공유 상태 업데이트 반응 -> 매칭 화면 상태 업데이트
    input.isUpdatedPublicState
      .subscribe(onNext: { [weak self] in
        let filterStorage = MatchingFilterStorage.shared
        if $0 {
          
          if filterStorage.hasFilter {
            self?.requestFilteredMemberAPI()
          } else {
            self?.requestMatchingAPI()
          }
          self?.output.informationImageViewStatus.onNext(.noMatchingCardInformation)
          
        } else {
          self?.output.matchingMembers.accept([])
          self?.output.reloadCardStack.onNext(Void())
          self?.output.informationImageViewStatus.onNext(.noShareState)
        }
      })
      .disposed(by: disposeBag)
    
    // 스와이프 액션 -> 배경화면 컬러 감지
    input.swipeObserver
      .bind(to: output.onChangedTopBackgroundColor)
      .disposed(by: disposeBag)
    
    // 스와이프 액션 끝내기 -> 배경화면 컬러 되돌리기
    input.didEndSwipeObserver
      .map { _ in Void() }
      .bind(to: output.drawBackTopBackgroundColor)
      .disposed(by: disposeBag)
    
    // 취소 버튼 클릭 -> 배경화면 컬러 변경
    input.cancelButtonObserver
      .map { MatchingType.cancel }
      .bind(to: output.onChangedTopBackgroundColor_WithTouch)
      .disposed(by: disposeBag)
    
    // 좋아요 버튼 클릭 -> 배경화면 컬러 변경
    input.heartButtonObserver
      .map { MatchingType.heart }
      .bind(to: output.onChangedTopBackgroundColor_WithTouch)
      .disposed(by: disposeBag)
    
    // 필터 버튼 클릭 -> 매칭 필터 VC 전환
    input.filterButtonObserver
      .bind(to: output.showFilterVC)
      .disposed(by: disposeBag)
    
    // 싫어요 멤버 스와이프, 버튼 이벤트 -> 싫어요 멤버 추가 API 호출
    input.dislikeMemberObserver
      .bind(onNext: { [unowned self] memberId in
        self.requestMatchingDislikedMembers_POST(memberId)
      })
      .disposed(by: disposeBag)
    
    // 좋아요 멤버 스와이프, 버튼 이벤트 -> 좋아요 멤버 추가 API 호출
    input.likeMemberObserver
      .bind(onNext: { [unowned self] memberId in
        self.requestMatchingLikedMembers_POST(memberId)
      })
      .disposed(by: disposeBag)
    
    // 공개 허용 버튼 클릭 -> 공개 요청 API 요청 후, 카드 불러오기
    input.publicButtonTapped
      .subscribe(onNext: { [weak self] in
        self?.requestUpdateMatchingPublicInfoAPI(true)
      })
      .disposed(by: disposeBag)
    
    // 필터 선택 초기화 버튼 클릭 -> 매칭 멤버 초기화
    input.resetFilterButtonTapped
      .subscribe(onNext: { [weak self] in
        if MemberInfoStorage.shared.isPublicMatchingInfo {
          self?.requestMatchingAPI()
        } else {
          self?.output.showFilterVC.onNext(Void())
        }
      })
      .disposed(by: disposeBag)
    
    // 필터링 완료 버튼 클릭 -> 필터된 매칭 멤버 조회
    input.confirmFilteringButtonTapped
      .subscribe(onNext: { [weak self] in
        if MemberInfoStorage.shared.isPublicMatchingInfo {
          self?.requestFilteredMemberAPI()
        } else {
          self?.output.showFilterVC.onNext(Void())
        }
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - Network

extension MatchingViewModel {
  
  /// 매칭 공개 여부 수정 API 요청
  func requestUpdateMatchingPublicInfoAPI(_ isPublic: Bool) {
    OnboardingService.shared.matchingInfoAPI_Patch(isPublic)
      .subscribe(onNext: { [weak self] response in
        guard let statusCode = response.response?.statusCode else { return }
        switch statusCode {
        case 200:
          struct ResponseModel: Codable {
            let data: MatchingInfo_Lookup
          }
          guard let data = response.data else { return }
          let newInfo = APIService.decode(ResponseModel.self, data: data).data
          MemberInfoStorage.shared.matchingInfo.accept(newInfo)
          self?.requestMatchingAPI()
        default:
          fatalError()
        }
      })
      .disposed(by: disposeBag)
  }

  /// 멤버들의 매칭 정보 불러오기 API
  func requestMatchingAPI() {
    output.indicatorState.onNext(true)
    MatchingService.shared.matchingAPI()
      .subscribe(onNext: { [unowned self] response in
        guard let statusCode = response.response?.statusCode else { return }
        switch statusCode {
        case 200: // 매칭멤버 조회 완료
          guard let data = response.data else { return }
          struct ResponseModel: Codable {
            let data: [MatchingMember]
          }
          let newMembers = APIService.decode(ResponseModel.self, data: data).data
          self.output.matchingMembers.accept(newMembers)
        case 204: // 매칭되는 멤버가 없습니다.
          self.output.matchingMembers.accept([])
        default:
          fatalError()
        }
        self.output.dismissNoSharePopupVC.onNext(Void())
        self.output.indicatorState.onNext(false)
        self.output.reloadCardStack.onNext(Void())
        self.output.informationImageViewStatus.onNext(.noMatchingCardInformation)
      })
      .disposed(by: disposeBag)
  }
  
  /// 필터링된 매칭 멤버 조회
  func requestFilteredMemberAPI() {
    output.indicatorState.onNext(true)
    guard let filter = MatchingFilterStorage.shared.matchingFilterObserver.value else { return }
    MatchingService.shared.filteredMatchingAPI(filter)
      .subscribe(onNext: { [unowned self] response in
        guard let statusCode = response.response?.statusCode else { return }
        switch statusCode {
        case 200: // 매칭 멤버 조회 완료
          guard let data = response.data else { fatalError() }
          struct ResponseModel: Codable {
            let data: [MatchingMember]
          }
          let newMembers = APIService.decode(ResponseModel.self, data: data).data
          self.output.matchingMembers.accept(newMembers)
        case 204: // 매칭되는 멤버가 없습니다.
          self.output.matchingMembers.accept([])
        case 401: // 로그인한 멤버가 존재하지 않습니다.
          break
        case 409: // 매칭정보가 존재하지 않습니다.
          break
        default: // 서버오류
          break
        }
        self.output.reloadCardStack.onNext(Void())
        self.output.indicatorState.onNext(false)
      })
      .disposed(by: disposeBag)
  }
  
  /// 좋아요 멤버 추가 API
  func requestMatchingLikedMembers_POST(_ memberId: Int) {
    MatchingService.shared.matchingLikedMembers_Post(memberId)
      .subscribe(onNext: { response in
        guard let statusCode = response.response?.statusCode else { return }
        switch statusCode {
        case 200: // 좋아요 멤버 추가 완료
          break
        default: // 서버 에러 발생
          fatalError()
        }
      })
      .disposed(by: disposeBag)
  }
  
  /// 싫어요 멤버 추가 API
  func requestMatchingDislikedMembers_POST(_ memberId: Int) {
    MatchingService.shared.matchingDislikedMembers_Post(memberId)
      .subscribe(onNext: { response in
        guard let statusCode = response.response?.statusCode else { return }
        print(statusCode)
        switch statusCode {
        case 200: // 싫어요 멤버 추가 완료
          break
        default: // 서버 에러 발생
          fatalError()
        }
      })
      .disposed(by: disposeBag)
  }
}
