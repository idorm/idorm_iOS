import UIKit

import RxSwift
import RxCocoa
import RxMoya
import RxOptional

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
    let makeProfileImageButtonDidTap = PublishSubject<Void>()
    let kakaoLinkButtonDidTap = PublishSubject<Int>()
    let swipeDidEnd = PublishSubject<MatchingSwipeType>()
    let leftSwipeDidEnd = PublishSubject<Int>()
    let rightSwipeDidEnd = PublishSubject<Int>()
    let swipingCard = PublishSubject<MatchingType>()
    let publicButtonDidTap = PublishSubject<Void>()
    let publicStateDidChange = PublishSubject<Bool>()
    let viewWillAppear = PublishSubject<Void>()
  }
  
  struct Output {
    let onChangedTopBackgroundColor = PublishSubject<MatchingType>()
    let onChangedTopBackgroundColor_WithTouch = PublishSubject<MatchingType>()
    let drawBackTopBackgroundColor = PublishSubject<Void>()
    let informationImageViewStatus = PublishSubject<MatchingImageViewType>()
    let isLoading = BehaviorRelay<Bool>(value: false)
    let reloadCardStack = PublishSubject<Void>()
    let pushToFilterVC = PublishSubject<Void>()
    let pushToOnboardingVC = PublishSubject<Void>()
    let presentMatchingPopupVC = PublishSubject<Void>()
    let presentNoSharePopupVC = PublishSubject<Void>()
    let presentKakaoPopupVC = PublishSubject<Int>()
    let presentSafari = PublishSubject<String>()
    let presentPopup = PublishSubject<String>()
    let dismissNoMatchingPopup = PublishSubject<Void>()
    let dismissNoSharePopupVC = PublishSubject<Void>()
    let dismissKakaoLinkVC = PublishSubject<Void>()
  }
  
  // MARK: - Properties
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  let matchingMembers = BehaviorRelay<[MatchingModel.Member]>(value: [])
  
  let retrieveMatchingMembers = PublishSubject<Void>()
  let retrieveFilterdMembers = PublishSubject<Void>()
  
  // MARK: - Bind
  
  init() {
    
    // 화면 초기 진입 -> UI 셋업
    input.viewWillAppear
      .take(1)
      .map { MemberInfoStorage.instance }
      .withUnretained(self)
      .bind { $0.0.reload() }
      .disposed(by: disposeBag)
    
    // 화면 진입 -> 이미지 상태 바꾸기
    input.viewWillAppear
      .withUnretained(self)
      .bind { $0.0.reloadInformationImage() }
      .disposed(by: disposeBag)
    
    // 새로고침 버튼 -> UI 셋업
    input.refreshButtonDidTap
      .withUnretained(self)
      .bind { $0.0.reload() }
      .disposed(by: disposeBag)
    
    // 왼쪽 스와이프, 버튼 -> 싫어요 멤버 추가 API 요청
    input.leftSwipeDidEnd
      .withUnretained(self)
      .do { $0.0.output.isLoading.accept(true) }
      .flatMap { APIService.matchingProvider.rx.request(.addDisliked($0.1)) }
      .map { _ in false }
      .bind(to: output.isLoading)
      .disposed(by: disposeBag)
    
    // 오른쪽 스와이프, 버튼 -> 좋아요 멤버 추가 API 요청
    input.rightSwipeDidEnd
      .withUnretained(self)
      .do { $0.0.output.isLoading.accept(true) }
      .flatMap { APIService.matchingProvider.rx.request(.addLiked($0.1)) }
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
        let filterStorage = FilterStorage.shared
        if state {
          if filterStorage.hasFilter {
            owner.retrieveFilterdMembers.onNext(Void())
          } else {
            owner.retrieveMatchingMembers.onNext(Void())
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
      .withUnretained(self)
      .filter { $0.0.reload_filter() }
      .map { _ in Void() }
      .bind(to: output.pushToFilterVC)
      .disposed(by: disposeBag)
    
    // 공개 허용 버튼 클릭 -> 공개 요청 API 요청 후, 카드 불러오기
    input.publicButtonDidTap
      .withUnretained(self)
      .do(onNext: { $0.0.output.isLoading.accept(true) })
      .map { _ in true }
      .flatMap {
        APIService.onboardingProvider.rx.request(.modifyPublic($0))
      }
      .retry()
      .withUnretained(self)
      .subscribe(onNext: { owner, response in
        owner.output.isLoading.accept(false)
        
        if response.statusCode == 204 {
          owner.retrieveMatchingMembers.onNext(Void())
          SharedAPI.instance.retrieveMyOnboarding()
        } else {
          fatalError() // TODO: 에러 처리하기
        }
      })
      .disposed(by: disposeBag)
    
    // 필터 선택 초기화 버튼 클릭 -> 매칭 멤버 초기화
    input.resetFilterButtonDidTap
      .withUnretained(self)
      .map { $0.0 }
      .subscribe(onNext: {
        if MemberInfoStorage.instance.isPublicMatchingInfo {
          $0.retrieveMatchingMembers.onNext(Void())
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
          $0.retrieveFilterdMembers.onNext(Void())
        } else {
          $0.output.presentNoSharePopupVC.onNext(Void())
        }
      })
      .disposed(by: disposeBag)
    
    // 오픈채팅 링크 바로가기 -> 사파리 열기
    input.kakaoLinkButtonDidTap
      .withUnretained(self)
      .map { $0.0.matchingMembers.value[$0.1].openKakaoLink }
      .filter { $0.isValidKakaoLink }
      .withUnretained(self)
      .subscribe { owner, link in
        owner.output.dismissKakaoLinkVC.onNext(Void())
        owner.output.presentSafari.onNext(link)
      }
      .disposed(by: disposeBag)
    
    // 오픈채팅 링크 바로가기 -> 팝업 오류
    input.kakaoLinkButtonDidTap
      .withUnretained(self)
      .map { $0.0.matchingMembers.value[$0.1].openKakaoLink }
      .filter { !$0.isValidKakaoLink }
      .map { _ in "해당 주소가 유효하지 않습니다." }
      .bind(to: output.presentPopup)
      .disposed(by: disposeBag)
    
    // 프로필 이미지 버튼 클릭 -> 팝업 창 닫기
    input.makeProfileImageButtonDidTap
      .bind(to: output.dismissNoMatchingPopup)
      .disposed(by: disposeBag)
    
    // 프로필 이미지 버튼 클릭 -> 온보딩 페이지로 이동
    input.makeProfileImageButtonDidTap
      .bind(to: output.pushToOnboardingVC)
      .disposed(by: disposeBag)
    
    // 매칭 멤버 불러오기 API
    retrieveMatchingMembers
      .withUnretained(self)
      .do { $0.0.output.isLoading.accept(true) }
      .flatMap { _ in
        APIService.matchingProvider.rx.request(.retrieve)
          .asObservable()
      }
      .withUnretained(self)
      .subscribe { owner, response in
        switch response.statusCode {
        case 200: // 매칭멤버 조회 완료
          let newMembers = APIService.decode(
            ResponseModel<[MatchingModel.Member]>.self,
            data: response.data
          ).data
          owner.matchingMembers.accept(newMembers)
        case 204: // 매칭되는 멤버가 없습니다.
          owner.matchingMembers.accept([])
        default:
          fatalError()
        }
        owner.output.dismissNoSharePopupVC.onNext(Void())
        owner.output.isLoading.accept(false)
        owner.output.reloadCardStack.onNext(Void())
        owner.output.informationImageViewStatus.onNext(.noMatchingCardInformation)
      }
      .disposed(by: disposeBag)
    
//    // 필터링된 매칭 멤버 불러오기 API
//    retrieveFilterdMembers
//      .withUnretained(self)
//      .do { $0.0.output.isLoading.accept(true) }
//      .map { _ in FilterStorage.shared.filter }
//      .flatMap {
//        APIService.matchingProvider.rx.request(.retrieveFiltered(filter: $0))
//          .asObservable()
//      }
//      .withUnretained(self)
//      .subscribe { owner, response in
//        owner.output.isLoading.accept(false)
//
//        switch response.statusCode {
//        case 200:
//          let members = APIService.decode(
//            ResponseModel<[MatchingModel.Member]>.self,
//            data: response.data
//          ).data
//          owner.matchingMembers.accept(members)
//        case 204:
//          owner.matchingMembers.accept([])
//        default:
//          fatalError("필터링을 실패했습니다,,,")
//        }
//        owner.output.reloadCardStack.onNext(Void())
//      }
//      .disposed(by: disposeBag)
  }
}

// MARK: - Helpers

extension MatchingViewModel {
  private func reloadInformationImage() {
    let storage = MemberInfoStorage.instance
    if storage.hasMatchingInfo {
      storage.isPublicMatchingInfo ? output.informationImageViewStatus.onNext(.noMatchingCardInformation) : output.informationImageViewStatus.onNext(.noShareState)
    } else {
      output.informationImageViewStatus.onNext(.noMatchingInformation)
    }
  }
  
  private func reload() {
    reloadInformationImage()
    let storage = MemberInfoStorage.instance
    if storage.hasMatchingInfo {
      if storage.isPublicMatchingInfo {
        FilterStorage.shared.hasFilter ?
        retrieveFilterdMembers.onNext(Void()) : retrieveMatchingMembers.onNext(Void())
      } else {
        output.presentNoSharePopupVC.onNext(Void())
      }
    } else {
      output.presentMatchingPopupVC.onNext(Void())
    }
  }
  
  private func reload_filter() -> Bool {
    let storage = MemberInfoStorage.instance
    if storage.hasMatchingInfo {
      if storage.isPublicMatchingInfo {
        return true
      } else {
        output.presentNoSharePopupVC.onNext(Void())
        return false
      }
    } else {
      output.presentMatchingPopupVC.onNext(Void())
      return false
    }
  }
}
