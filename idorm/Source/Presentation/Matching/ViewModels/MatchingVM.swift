import UIKit

import RxSwift
import RxCocoa
import RxMoya

final class MatchingViewModel: ViewModel {
  
  // MARK: - Properties
  
  struct Input {
    let cancelButtonDidTap = PublishSubject<Void>()
    let backButtonDidTap = PublishSubject<Void>()
    let messageButtonDidTap = PublishSubject<Int>()
    let heartButtonDidTap = PublishSubject<Void>()
    let filterButtonDidTap = PublishSubject<Void>()
    let refreshButtonDidTap = PublishSubject<Void>()
    let resetFilterButtonDidTap = PublishSubject<Void>()
    let confirmFilterButtonDidTap = PublishSubject<Void>()
    let kakaoLinkButtonDidTap = PublishSubject<Int>()
    let swipeDidEnd = PublishSubject<MatchingSwipeType>()
    let leftSwipeDidEnd = PublishSubject<Int>()
    let rightSwipeDidEnd = PublishSubject<Int>()
    let swipingCard = PublishSubject<MatchingType>()
    let publicButtonDidTap = PublishSubject<Void>()
    let publicStateDidChange = PublishSubject<Bool>()
    let viewDidLoad = PublishSubject<Void>()
  }
  
  struct Output {
    let onChangedTopBackgroundColor = PublishSubject<MatchingType>()
    let onChangedTopBackgroundColor_WithTouch = PublishSubject<MatchingType>()
    let drawBackTopBackgroundColor = PublishSubject<Void>()
    let informationImageViewStatus = PublishSubject<MatchingImageViewType>()
    let isLoading = BehaviorRelay<Bool>(value: false)
    let reloadCardStack = PublishSubject<Void>()
    let pushToFilterVC = PublishSubject<Void>()
    let presentMatchingPopupVC = PublishSubject<Void>()
    let presentNoSharePopupVC = PublishSubject<Void>()
    let presentKakaoPopupVC = PublishSubject<Int>()
    let presentSafari = PublishSubject<String>()
    let dismissNoSharePopupVC = PublishSubject<Void>()
    let dismissKakaoLinkVC = PublishSubject<Void>()
  }
  
  // MARK: - Properties
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  let matchingMembers = BehaviorRelay<[MatchingModel.Member]>(value: [])
  
  // MARK: - Bind

  init() {
    
    // ViewDidLoad -> 매칭 초기 상태 판단
    input.viewDidLoad
      .map { MemberInfoStorage.instance }
      .withUnretained(self)
      .subscribe(onNext: { owner, storage in
        if storage.hasMatchingInfo {
          if storage.isPublicMatchingInfo {
            owner.output.informationImageViewStatus.onNext(.noMatchingCardInformation)
            owner.retrieveMembers()
          } else {
            owner.output.informationImageViewStatus.onNext(.noShareState)
            owner.output.presentNoSharePopupVC.onNext(Void())
          }
        } else {
          owner.output.informationImageViewStatus.onNext(.noMatchingInformation)
          owner.output.presentMatchingPopupVC.onNext(Void())
        }
      })
      .disposed(by: disposeBag)

    // 새로고침 버튼 -> 팝업 창 띄우기
    input.refreshButtonDidTap
      .filter { MemberInfoStorage.instance.hasMatchingInfo == false }
      .bind(to: output.presentMatchingPopupVC)
      .disposed(by: disposeBag)
    
    // 새로고침 버튼 -> 공개 허용 요청 창 띄우기
    input.refreshButtonDidTap
      .filter { MemberInfoStorage.instance.hasMatchingInfo }
      .filter { MemberInfoStorage.instance.isPublicMatchingInfo == false }
      .bind(to: output.presentNoSharePopupVC)
      .disposed(by: disposeBag)
    
    // 새로고침 버튼 -> 멤버 새로 불러오기
    input.refreshButtonDidTap
      .filter { MemberInfoStorage.instance.hasMatchingInfo }
      .filter { MemberInfoStorage.instance.isPublicMatchingInfo }
      .withUnretained(self)
      .map { $0.0 }
      .bind { MatchingFilterStorage.shared.hasFilter ? $0.retrieveFilteredMembers() : $0.retrieveMembers() }
      .disposed(by: disposeBag)
    
    // 왼쪽 스와이프, 버튼 -> 싫어요 멤버 추가 API 요청
    input.leftSwipeDidEnd
      .withUnretained(self)
      .do(onNext: { $0.0.output.isLoading.accept(true) })
      .flatMap { APIService.matchingProvider.rx.request(.addDisliked($0.1)) }
      .filterSuccessfulStatusCodes()
      .map { _ in false }
      .bind(to: output.isLoading)
      .disposed(by: disposeBag)
    
    // 오른쪽 스와이프, 버튼 -> 좋아요 멤버 추가 API 요청
    input.rightSwipeDidEnd
      .withUnretained(self)
      .do(onNext: { $0.0.output.isLoading.accept(true) })
      .flatMap { APIService.matchingProvider.rx.request(.addLiked($0.1)) }
      .filterSuccessfulStatusCodes()
      .map { _ in false }
      .bind(to: output.isLoading)
      .disposed(by: disposeBag)
    
    // 메세지 버튼 클릭 -> 오픈채팅 팝업 Present
    input.messageButtonDidTap
      .bind(to: output.presentKakaoPopupVC)
      .disposed(by: disposeBag)
    
    // 자신의 공유 상태 업데이트 반응 -> 매칭 화면 상태 업데이트
    input.publicStateDidChange
      .withUnretained(self)
      .subscribe(onNext: { owner, state in
        let filterStorage = MatchingFilterStorage.shared
        if state {
          if filterStorage.hasFilter {
            owner.retrieveFilteredMembers()
          } else {
            owner.retrieveMembers()
          }
          owner.output.informationImageViewStatus.onNext(.noMatchingCardInformation)
        } else {
          owner.matchingMembers.accept([])
          owner.output.reloadCardStack.onNext(Void())
          owner.output.informationImageViewStatus.onNext(.noShareState)
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
      .withUnretained(self)
      .do(onNext: { $0.0.output.isLoading.accept(true) })
      .map { _ in true }
      .flatMap { APIService.onboardingProvider.rx.request(.modifyPublic($0)) }
      .map(ResponseModel<OnboardingModel.MyOnboarding>.self)
      .withUnretained(self)
      .subscribe(onNext: { owner, response in
        let newValue = response.data
        MemberInfoStorage.instance.myOnboarding.accept(newValue)
        owner.retrieveMembers()
      })
      .disposed(by: disposeBag)
    
    // 필터 선택 초기화 버튼 클릭 -> 매칭 멤버 초기화
    input.resetFilterButtonDidTap
      .withUnretained(self)
      .map { $0.0 }
      .subscribe(onNext: {
        if MemberInfoStorage.instance.isPublicMatchingInfo {
          $0.retrieveMembers()
        } else {
          $0.output.presentNoSharePopupVC.onNext(Void())
        }
      })
      .disposed(by: disposeBag)
    
    // 필터링 완료 버튼 클릭 -> 필터된 매칭 멤버 조회
    input.confirmFilterButtonDidTap
      .withUnretained(self)
      .map { $0.0 }
      .subscribe(onNext: {
        if MemberInfoStorage.instance.isPublicMatchingInfo {
          $0.retrieveFilteredMembers()
        } else {
          $0.output.presentNoSharePopupVC.onNext(Void())
        }
      })
      .disposed(by: disposeBag)
    
    // 오픈채팅 링크 바로가기 -> 사파리 열기
    input.kakaoLinkButtonDidTap
      .withUnretained(self)
      .map { owner, index in owner.matchingMembers.value[index].openKakaoLink }
      .bind(to: output.presentSafari)
      .disposed(by: disposeBag)
  }
}

// MARK: - Network

extension MatchingViewModel {
  /// 매칭 멤버 조회 요청
  func retrieveMembers() {
    output.isLoading.accept(true)
    APIService.matchingProvider.rx.request(.retrieve)
      .asObservable()
      .subscribe(onNext: { [weak self] response in
        guard let self = self else { return }
        switch response.statusCode {
        case 200: // 매칭멤버 조회 완료
          let newMembers = APIService.decode(ResponseModel<[MatchingModel.Member]>.self, data: response.data).data
          self.matchingMembers.accept(newMembers)
        case 204: // 매칭되는 멤버가 없습니다.
          self.matchingMembers.accept([])
        default:
          fatalError()
        }
        self.output.dismissNoSharePopupVC.onNext(Void())
        self.output.isLoading.accept(false)
        self.output.reloadCardStack.onNext(Void())
        self.output.informationImageViewStatus.onNext(.noMatchingCardInformation)
      })
      .disposed(by: disposeBag)
  }
  
  /// 필터링된 매칭 멤버 조회
  func retrieveFilteredMembers() {
    guard let filter = MatchingFilterStorage.shared.matchingFilterObserver.value else { return }
    
    APIService.matchingProvider.rx.request(.retrieveFiltered(filter: filter)).asObservable()
      .do(onNext: { [weak self] _ in
        self?.output.isLoading.accept(true)
      })
      .subscribe(onNext: { [weak self] response in
        switch response.statusCode {
        case 200:
          let members = APIService.decode(ResponseModel<[MatchingModel.Member]>.self, data: response.data).data
          self?.matchingMembers.accept(members)
        case 204:
          self?.matchingMembers.accept([])
        default:
          fatalError("필터링을 실패했습니다,,,")
        }
        self?.output.reloadCardStack.onNext(Void())
        self?.output.isLoading.accept(false)
      })
      .disposed(by: disposeBag)
  }
}
