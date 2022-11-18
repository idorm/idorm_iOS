import Foundation

import RxSwift
import RxCocoa

final class OnboardingDetailViewModel: ViewModel {
  
  struct Input {
    // Interaction
    let backButtonTapped = PublishSubject<Void>()
    let correctionButtonTapped = PublishSubject<Void>()
    let confirmButtonTapped = PublishSubject<Void>()
  }
  
  struct Output {
    // Presentation
    let popVC = PublishSubject<Void>()
    let showPopupVC = PublishSubject<String>()
    let showTabBarVC = PublishSubject<Void>()
    let showOnboardingVC = PublishSubject<Void>()
    
    // UI
    let indicatorState = PublishSubject<Bool>()
  }
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  private let vcType: OnboardingVCTypes.OnboardingDetailVCType
  
  init(_ vcType: OnboardingVCTypes.OnboardingDetailVCType) {
    self.vcType = vcType
    bind()
  }
  
  func bind() {
    
    // 뒤로가기 -> 이전 화면 돌아가기
    input.backButtonTapped
      .bind(to: output.popVC)
      .disposed(by: disposeBag)
    
    // 정보 수정 버튼 클릭 -> 온보딩 페이지 이동
    input.correctionButtonTapped
      .bind(to: output.showOnboardingVC)
      .disposed(by: disposeBag)
    
    switch vcType {
    case .initilize:
      
      // 완료 버튼 이벤트 -> 온보딩 최초 저장
      input.confirmButtonTapped
        .bind(onNext: { [weak self] in
          self?.matchingInfoAPI()
        })
        .disposed(by: disposeBag)
    case .update:
      
      // 완료 버튼 이벤트 -> 뒤로가기
      input.confirmButtonTapped
        .bind(to: output.popVC)
        .disposed(by: disposeBag)
    }
  }
}

// MARK: - Network

extension OnboardingDetailViewModel {
  
  func matchingInfoAPI() {
//    OnboardingService.shared.matchingInfoAPI_Post(myinfo: matchingInfo)
//      .subscribe(onNext: { [weak self] response in
//        self?.output.stopAnimation.onNext(Void())
//        guard let statusCode = response.response?.statusCode else { fatalError("Status Code is missing") }
//        switch statusCode {
//        case 200:
//          self?.output.showTabBarVC.onNext(Void())
//        case 401:
//          self?.output.showPopupVC.onNext("로그인한 멤버가 존재하지 않습니다.")
//        case 404:
//          self?.output.showPopupVC.onNext("멤버를 찾을 수 없습니다.")
//        case 409:
//          self?.output.showPopupVC.onNext("이미 등록된 매칭 정보가 있습니다.")
//        case 500:
//          self?.output.showPopupVC.onNext("Matching save 중 서버 에러 발생")
//        default:
//          break
//        }
//      })
//      .disposed(by: disposeBag)
  }
}
