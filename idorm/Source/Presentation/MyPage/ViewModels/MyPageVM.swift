import RxSwift
import RxCocoa
import RxMoya
import RxOptional

final class MyPageViewModel: ViewModel {
  
  // MARK: - Properties
  
  struct Input {
    let gearButtonDidTap = PublishSubject<Void>()
    let shareButtonDidTap = PublishSubject<Bool>()
    let manageButtonDidTap = PublishSubject<Void>()
    let roommateButtonDidTap = PublishSubject<MyPageVCTypes.MyRoommateVCType>()
    let makeProfileImageButtonDidTap = PublishSubject<Void>()
    let viewWillAppear = PublishSubject<Void>()
  }
  
  struct Output {
    let pushToManageMyInfoVC = PublishSubject<Void>()
    let pushToMyRoommateVC = PublishSubject<MyPageVCTypes.MyRoommateVCType>()
    let pushToOnboardingVC = PublishSubject<Bool>()
    let presentNoMatchingInfoPopupVC = PublishSubject<Void>()
    let dismissPopupVC = PublishSubject<Void>()
    let isLoading = PublishSubject<Bool>()
    let toggleShareButton = PublishSubject<Void>()
    let updateShareButton = PublishSubject<Bool>()
    let updateNickname = PublishSubject<String>()
  }
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  // MARK: - Bind
  
  init() {
    
    // 공유 버튼 클릭 -> 매칭 공개 여부 수정 API 요청
    input.shareButtonDidTap
      .withUnretained(self)
      .do { $0.0.output.isLoading.onNext(true) }
      .flatMap {
        APIService.onboardingProvider.rx.request(.modifyPublic($0.1))
          .asObservable()
      }
      .retry()
      .withUnretained(self)
      .subscribe(onNext: { owner, response in
        owner.output.isLoading.onNext(false)
        
        if response.statusCode == 204 {
          SharedAPI.instance.retrieveMyOnboarding()
          owner.output.toggleShareButton.onNext(Void())
        } else {
          let error = APIService.decode(ErrorResponseModel.self, data: response.data)
          
          switch error.code {
          case .MATCHING_INFO_NOT_FOUND:
            owner.output.presentNoMatchingInfoPopupVC.onNext(Void())
          default:
            break
          }
        }
      })
      .disposed(by: disposeBag)
    
    // 설정 버튼 클릭 -> 내 정보 관리 페이지로 이동
    input.gearButtonDidTap
      .bind(to: output.pushToManageMyInfoVC)
      .disposed(by: disposeBag)
    
    // 좋아요한 룸메 & 싫어요한 룸메 버튼 클릭 -> 룸메이트 관리 페이지 이동
    input.roommateButtonDidTap
      .bind(to: output.pushToMyRoommateVC)
      .disposed(by: disposeBag)
    
    // 마이페이지 버튼 클릭 -> 온보딩 수정 페이지로 이동
    input.manageButtonDidTap
      .map { MemberInfoStorage.instance.hasMatchingInfo }
      .bind(to: output.pushToOnboardingVC)
      .disposed(by: disposeBag)
    
    // 화면 접근 -> 공유 버튼 업데이트
    input.viewWillAppear
      .map { MemberInfoStorage.instance.isPublicMatchingInfo }
      .bind(to: output.updateShareButton)
      .disposed(by: disposeBag)
    
    // 화면 접근 -> 닉네임 업데이트
    input.viewWillAppear
      .map { MemberInfoStorage.instance.myInformation.value?.nickname }
      .filterNil()
      .bind(to: output.updateNickname)
      .disposed(by: disposeBag)
    
    // 프로필 이미지 만들기 버튼 -> 온보딩 페이지로 이동
    input.makeProfileImageButtonDidTap
      .withUnretained(self)
      .do(onNext: { $0.0.output.dismissPopupVC.onNext(Void()) })
      .map { _ in false }
      .bind(to: output.pushToOnboardingVC)
      .disposed(by: disposeBag)
  }
}
