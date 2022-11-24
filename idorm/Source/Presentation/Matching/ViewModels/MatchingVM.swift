import UIKit

import RxSwift
import RxCocoa

final class MatchingViewModel: ViewModel {
  
  // MARK: - Properties
  
  struct Input {
    // Interaction
    let cancelButtonDidTap = PublishSubject<Void>()
    let backButtonDidTap = PublishSubject<Void>()
    let messageButtonDidTap = PublishSubject<Void>()
    let heartButtonDidTap = PublishSubject<Void>()
    let filterButtonDidTap = PublishSubject<Void>()
    let resetFilterButtonDidTap = PublishSubject<Void>()
    let confirmFilterButtonDidTap = PublishSubject<Void>()
    let swipeDidEnd = PublishSubject<MatchingSwipeType>()
    let swipingCard = PublishSubject<MatchingType>()
    
    // Popup Interaction
    let kakaoLinkButtonDidTap = PublishSubject<Void>()
    let publicButtonDidTap = PublishSubject<Void>()
    
    // Observing
    let updatePublicState = PublishSubject<Bool>()
    let hasMatchingInfo = PublishSubject<Bool>()
    let viewDidLoad = PublishSubject<Void>()
  }
  
  struct Output {
    // UI
    let onChangedTopBackgroundColor = PublishSubject<MatchingType>()
    let onChangedTopBackgroundColor_WithTouch = PublishSubject<MatchingType>()
    let drawBackTopBackgroundColor = PublishSubject<Void>()
    let informationImageViewStatus = PublishSubject<MatchingImageViewType>()
    let indicatorState = PublishSubject<Bool>()
    let reloadCardStack = PublishSubject<Void>()
    
    // Presentation
    let pushToFilterVC = PublishSubject<Void>()
    let presentFirstPopupVC = PublishSubject<Void>()
    let presentNoSharePopupVC = PublishSubject<Void>()
    let presentKakaoPopupVC = PublishSubject<Void>()
    let presentSafari = PublishSubject<Void>()
    let dismissNoSharePopupVC = PublishSubject<Void>()
    let dismissKakaoLinkVC = PublishSubject<Void>()
  }
  
  struct State {
    let addlikeAPI = PublishSubject<Int>()
    let addDislikeAPI = PublishSubject<Int>()
    let matchingMembers = BehaviorRelay<[MatchingModel.Member]>(value: [])
  }
  
  var input = Input()
  var output = Output()
  var state = State()
  var disposeBag = DisposeBag()
  
  // MARK: - Bind
  
  private func bindState() {
    
    // 싫어요 멤버 스와이프, 버튼 이벤트 -> 싫어요 멤버 추가 API 호출
    state.addDislikeAPI
      .do(onNext: { [weak self] _ in self?.output.indicatorState.onNext(true) })
      .flatMap { return APIService.matchingProvider.rx.request(.addDisliked($0)) }
      .subscribe(onNext: { [weak self] response in
        self?.output.indicatorState.onNext(false)
        switch response.statusCode {
        case 200:
          break
        default:
          fatalError("멤버를 추가할 수 없습니다.")
        }
      })
      .disposed(by: disposeBag)
    
    // 좋아요 멤버 스와이프, 버튼 이벤트 -> 좋아요 멤버 추가 API 호출
      state.addlikeAPI
      .do(onNext: { [weak self] _ in
        self?.output.indicatorState.onNext(true)
      })
      .flatMap {
        return APIService.matchingProvider.rx.request(.addLiked($0))
      }
      .subscribe(onNext: { [weak self] response in
        self?.output.indicatorState.onNext(false)
        switch response.statusCode {
        case 200:
          break
        default:
          fatalError("멤버를 추가할 수 없습니다.")
        }
      })
      .disposed(by: disposeBag)
  }
  
  init() {
    bindState()
    
    // ViewDidLoad -> 매칭 초기 상태 판단
    input.viewDidLoad
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        let storage = MemberInfoStorage.instance
        
        if storage.hasMatchingInfo {
          
          if storage.isPublicMatchingInfo {
            self.output.informationImageViewStatus.onNext(.noMatchingCardInformation)
            self.retrieveMemberAPI()
            
          } else {
            self.output.informationImageViewStatus.onNext(.noShareState)
            self.output.presentNoSharePopupVC.onNext(Void())
          }
          
        } else {
          self.output.informationImageViewStatus.onNext(.noMatchingInformation)
          self.output.presentFirstPopupVC.onNext(Void())
        }
      })
      .disposed(by: disposeBag)
    
    // 메세지 버튼 클릭 -> 오픈채팅 팝업 Present
    input.messageButtonDidTap
      .bind(to: output.presentKakaoPopupVC)
      .disposed(by: disposeBag)
    
    // 자신의 공유 상태 업데이트 반응 -> 매칭 화면 상태 업데이트
    input.updatePublicState
      .subscribe(onNext: { [weak self] in
        let filterStorage = MatchingFilterStorage.shared
        if $0 {
          
          if filterStorage.hasFilter {
            self?.requestFilteredMemberAPI()
          } else {
            self?.retrieveMemberAPI()
          }
          self?.output.informationImageViewStatus.onNext(.noMatchingCardInformation)
          
        } else {
          self?.state.matchingMembers.accept([])
          self?.output.reloadCardStack.onNext(Void())
          self?.output.informationImageViewStatus.onNext(.noShareState)
        }
      })
      .disposed(by: disposeBag)
        
    // 스와이프 액션 -> 배경화면 컬러 감지
    input.swipingCard
      .bind(to: output.onChangedTopBackgroundColor)
      .disposed(by: disposeBag)
    
    // 스와이프 액션 끝내기 -> 배경화면 컬러 되돌리기
    input.swipeDidEnd
      .map { _ in Void() }
      .bind(to: output.drawBackTopBackgroundColor)
      .disposed(by: disposeBag)
    
    // 취소 버튼 클릭 -> 배경화면 컬러 변경
    input.cancelButtonDidTap
      .map { MatchingType.cancel }
      .bind(to: output.onChangedTopBackgroundColor_WithTouch)
      .disposed(by: disposeBag)
    
    // 좋아요 버튼 클릭 -> 배경화면 컬러 변경
    input.heartButtonDidTap
      .map { MatchingType.heart }
      .bind(to: output.onChangedTopBackgroundColor_WithTouch)
      .disposed(by: disposeBag)
    
    // 필터 버튼 클릭 -> 매칭 필터 VC 전환
    input.filterButtonDidTap
      .bind(to: output.pushToFilterVC)
      .disposed(by: disposeBag)
    
    // 공개 허용 버튼 클릭 -> 공개 요청 API 요청 후, 카드 불러오기
    input.publicButtonDidTap
      .do(onNext: { [weak self] in self?.output.indicatorState.onNext(true) })
      .flatMap { return APIService.onboardingProvider.rx.request(.modifyPublic(true)) }
      .map(OnboardingModel.LookupOnboardingResponseModel.self)
      .subscribe(onNext: { [weak self] response in
        let newValue = response.data
        MemberInfoStorage.instance.myOnboarding.accept(newValue)
        self?.retrieveMemberAPI()
      })
      .disposed(by: disposeBag)
    
    // 필터 선택 초기화 버튼 클릭 -> 매칭 멤버 초기화
    input.resetFilterButtonDidTap
      .subscribe(onNext: { [weak self] in
        if MemberInfoStorage.instance.isPublicMatchingInfo {
          self?.retrieveMemberAPI()
        } else {
          self?.output.presentNoSharePopupVC.onNext(Void())
        }
      })
      .disposed(by: disposeBag)
    
    // 필터링 완료 버튼 클릭 -> 필터된 매칭 멤버 조회
    input.confirmFilterButtonDidTap
      .subscribe(onNext: { [weak self] in
        if MemberInfoStorage.instance.isPublicMatchingInfo {
          self?.requestFilteredMemberAPI()
        } else {
          self?.output.presentNoSharePopupVC.onNext(Void())
        }
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - Network

extension MatchingViewModel {
  /// 매칭 멤버 조회 요청
  func retrieveMemberAPI() {
    output.indicatorState.onNext(true)
    APIService.matchingProvider.rx.request(.retrieve)
      .asObservable()
      .subscribe(onNext: { [weak self] response in
        guard let self = self else { return }
        switch response.statusCode {
        case 200: // 매칭멤버 조회 완료
          let newMembers = APIService.decode(MatchingModel.MatchingResponseModel.self, data: response.data).data
          self.state.matchingMembers.accept(newMembers)
        case 204: // 매칭되는 멤버가 없습니다.
          self.state.matchingMembers.accept([])
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
    guard let filter = MatchingFilterStorage.shared.matchingFilterObserver.value else { return }
    
    APIService.matchingProvider.rx.request(.retrieveFiltered(filter: filter)).asObservable()
      .do(onNext: { [weak self] _ in
        self?.output.indicatorState.onNext(true)
      })
      .subscribe(onNext: { [weak self] response in
        switch response.statusCode {
        case 200:
          let members = APIService.decode(MatchingModel.MatchingResponseModel.self, data: response.data).data
          self?.state.matchingMembers.accept(members)
        case 204:
          self?.state.matchingMembers.accept([])
        default:
          fatalError("필터링을 실패했습니다,,,")
        }
        self?.output.reloadCardStack.onNext(Void())
        self?.output.indicatorState.onNext(false)
      })
      .disposed(by: disposeBag)
  }
}
