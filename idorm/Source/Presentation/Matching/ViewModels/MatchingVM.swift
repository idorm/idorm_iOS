import UIKit

import RxSwift
import RxCocoa

final class MatchingViewModel: ViewModel {
  struct Input {
    // UI
    let cancelButtonObserver = PublishSubject<Void>()
    let backButtonObserver = PublishSubject<Void>()
    let messageButtonObserver = PublishSubject<Void>()
    let heartButtonObserver = PublishSubject<Void>()
    let filterButtonObserver = PublishSubject<Void>()
        
    // LifeCycle
    let viewDidLoadObserver = PublishSubject<Void>()
    
    // Card
    let swipeObserver = PublishSubject<MatchingType>()
    let didEndSwipeObserver = PublishSubject<MatchingSwipeType>()
    
    let likeMemberObserver = PublishSubject<Int>()
    let dislikeMemberObserver = PublishSubject<Int>()
  }
  
  struct Output {
    // UI
    let onChangedTopBackgroundColor = PublishSubject<MatchingType>()
    let onChangedTopBackgroundColor_WithTouch = PublishSubject<MatchingType>()
    let drawBackTopBackgroundColor = PublishSubject<Void>()
    let informationImageViewStatus = PublishSubject<MatchingImageViewType>()
    
    // Presentation
    let showFliterVC = PublishSubject<Void>()
    let showFirstPopupVC = PublishSubject<Void>()
    
    // Loading
    let startLoading = PublishSubject<Void>()
    let stopLoading = PublishSubject<Void>()
    
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
    
    // 화면 처음 진입 -> 매칭 정보 유무 체크
    input.viewDidLoadObserver
      .bind(onNext: {
        self.requestMatchingInfoAPI()
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
      .bind(to: output.showFliterVC)
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
  }
}

// MARK: - Network

extension MatchingViewModel {
  
  /// 첫 화면 진입 시 매칭 정보 유무 확인 API
  func requestMatchingInfoAPI() {
    OnboardingService.matchingInfoAPI_Get()
      .bind(onNext: { [unowned self] response in
        guard let statusCode = response.response?.statusCode else { return }
        switch statusCode {
        case 200:
          // 매칭 정보가 있으면 매칭멤버 조회하기
          self.requestMatchingAPI()
        default:
          // 매칭 정보가 없을 시에 팝업 창 띄우기
          self.output.showFirstPopupVC.onNext(Void())
          self.output.informationImageViewStatus.onNext(.noMatchingInformation)
        }
      })
      .disposed(by: disposeBag)
  }
  
  /// 멤버들의 매칭 정보 불러오기 API
  func requestMatchingAPI() {
    self.output.startLoading.onNext(Void())
    MatchingService.matchingAPI()
      .bind(onNext: { [unowned self] response in
        guard let statusCode = response.response?.statusCode else { return }
        guard let data = response.data else { return }
        switch statusCode {
        case 200: // 매칭멤버 조회 완료
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
        case 500: // 서버 에러 발생
          break
        default:
          break
        }
        self.output.stopLoading.onNext(Void())
        self.output.reloadCardStack.onNext(Void())
        self.output.informationImageViewStatus.onNext(.noMatchingCard)
      })
      .disposed(by: disposeBag)
  }
  
  /// 필터링된 매칭 멤버 조회
  func requestFilteredMemberAPI() {
    guard let filter = MatchingFilterStates.shared.matchingFilterObserver.value else { return }
    MatchingService.filteredMatchingAPI(filter)
      .bind(onNext: { [unowned self] response in
        guard let statusCode = response.response?.statusCode else { return }
        guard let data = response.data else { return }
        print(statusCode)
        switch statusCode {
        case 200: // 매칭 멤버 조회 완료
          struct ResponseModel: Codable {
            let data: [MatchingMember]
          }
          let newMembers = APIService.decode(ResponseModel.self, data: data).data
          self.output.matchingMembers.accept(newMembers)
        case 204: // 매칭되는 멤버가 없습니다.
          break
        case 401: // 로그인한 멤버가 존재하지 않습니다.
          break
        case 409: // 매칭정보가 존재하지 않습니다.
          break
        default: // 서버오류
          break
        }
      })
      .disposed(by: disposeBag)
  }
  
  /// 좋아요 멤버 추가 API
  func requestMatchingLikedMembers_POST(_ memberId: Int) {
    MatchingService.matchingLikedMembers_Post(memberId)
      .bind(onNext: { [unowned self] response in
        guard let statusCode = response.response?.statusCode else { return }
        switch statusCode {
        case 200: break
        case 401: break
        case 409: break
        case 500: break
        default: break
        }
      })
      .disposed(by: disposeBag)
  }
  
  /// 싫어요 멤버 추가 API
  func requestMatchingDislikedMembers_POST(_ memberId: Int) {
    MatchingService.matchingDislikedMembers_Post(memberId)
      .bind(onNext: { [unowned self] response in
        guard let statusCode = response.response?.statusCode else { return }
        print(statusCode)
        switch statusCode {
        case 200: break
        case 401: break
        case 409: break
        case 500: break
        default: break
        }
      })
      .disposed(by: disposeBag)
  }
}
