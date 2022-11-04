import UIKit

import RxSwift
import RxCocoa

final class MatchingViewModel: ViewModel {
  struct Input {
    let cancelButtonObserver = PublishSubject<Void>()
    let backButtonObserver = PublishSubject<Void>()
    let messageButtonObserver = PublishSubject<Void>()
    let heartButtonObserver = PublishSubject<Void>()
    let filterButtonObserver = PublishSubject<Void>()
    let viewWillAppearObserver = PublishSubject<Void>()
    
    let swipeObserver = PublishSubject<MatchingType>()
    let didEndSwipeObserver = PublishSubject<MatchingSwipeType>()
  }
  
  struct Output {
    let onChangedTopBackgroundColor = PublishSubject<MatchingType>()
    let onChangedTopBackgroundColor_WithTouch = PublishSubject<MatchingType>()
    let drawBackTopBackgroundColor = PublishSubject<Void>()
    
    let showFliterVC = PublishSubject<Void>()
    let showFirstPopupVC = PublishSubject<Void>()
    
    let reloadCardStack = PublishSubject<Void>()
    let matchingMembers = BehaviorRelay<[MatchingMember]>(value: [])
  }
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  init() {
    bind()
  }
  
  func bind() {
    
    // 화면 처음 진입 -> 매칭 정보 유무 체크
    input.viewWillAppearObserver
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
    input.heartButtonObserver
      .map { MatchingType.cancel }
      .bind(to: output.onChangedTopBackgroundColor_WithTouch)
      .disposed(by: disposeBag)
    
    // 좋아요 버튼 클릭 -> 배경화면 컬러 변경
    input.cancelButtonObserver
      .map { MatchingType.heart }
      .bind(to: output.onChangedTopBackgroundColor_WithTouch)
      .disposed(by: disposeBag)
    
    // 필터 버튼 클릭 -> 매칭 필터 VC 전환
    input.filterButtonObserver
      .bind(to: output.showFliterVC)
      .disposed(by: disposeBag)
  }
}

// MARK: - Network

extension MatchingViewModel {
  
  /// 첫 화면 진입 시 매칭 정보 유무 확인 API
  private func requestMatchingInfoAPI() {
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
        }
      })
      .disposed(by: disposeBag)
  }
  
  /// 멤버들의 매칭 정보 불러오기 API
  private func requestMatchingAPI() {
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
        self.output.reloadCardStack.onNext(Void())
      })
      .disposed(by: disposeBag)
  }
}
