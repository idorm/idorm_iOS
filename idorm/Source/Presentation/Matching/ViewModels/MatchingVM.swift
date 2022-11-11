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
        
    // Card
    let swipeObserver = PublishSubject<MatchingType>()
    let didEndSwipeObserver = PublishSubject<MatchingSwipeType>()
    
    let likeMemberObserver = PublishSubject<Int>()
    let dislikeMemberObserver = PublishSubject<Int>()
    
    // Observing
    let isPublicMatchingInfo = PublishSubject<Bool>()
    let hasMatchingInfo = PublishSubject<Bool>()
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
    let showNoSharePopupVC = PublishSubject<Void>()
    
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
    
    input.hasMatchingInfo
      .subscribe(onNext: { [weak self] in
        if $0 {
          
        } else {
          self?.output.informationImageViewStatus.onNext(.noMatchingInformation)
          self?.output.showFirstPopupVC.onNext(Void())
        }
      })
      .disposed(by: disposeBag)
    
    // 매칭 정보 공유 정보 변경 -> 이미지 변경 & 팝업 창 띄우기
    input.isPublicMatchingInfo
      .subscribe(onNext: { [weak self] in
        if $0 {
          self?.output.informationImageViewStatus.onNext(.noMatchingCardInformation)
          self?.requestMatchingAPI()
        } else {
          self?.output.informationImageViewStatus.onNext(.noShareState)
          self?.output.showNoSharePopupVC.onNext(Void())
          self?.output.matchingMembers.accept([])
          self?.output.reloadCardStack.onNext(Void())
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
  
  /// 멤버들의 매칭 정보 불러오기 API
  func requestMatchingAPI() {
    self.output.startLoading.onNext(Void())
    MatchingService.shared.matchingAPI()
      .subscribe(onNext: { [unowned self] response in
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
        self.output.informationImageViewStatus.onNext(.noMatchingCardInformation)
      })
      .disposed(by: disposeBag)
  }
  
  /// 필터링된 매칭 멤버 조회
  func requestFilteredMemberAPI() {
    self.output.startLoading.onNext(Void())
    let filter = MatchingFilterStorage.shared.matchingFilterObserver.value
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
        self.output.stopLoading.onNext(Void())
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
