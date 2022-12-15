import RxMoya
import RxSwift

final class SharedAPI {
  static let instance = SharedAPI()
  private init() {}
  private let disposeBag = DisposeBag()
  
  /// 나의 매칭 정보를 가져와서 저장합니다.
  func retrieveMyOnboarding() {
    APIService.onboardingProvider.rx.request(.retrieve)
      .asObservable()
      .retry()
      .subscribe { response in
        switch response.statusCode {
        case 200:
          let onboarding = APIService.decode(
            ResponseModel<OnboardingModel.MyOnboarding>.self,
            data: response.data
          ).data
          MemberInfoStorage.instance.saveMyOnboarding(from: onboarding)
        default:
          break
        }
      }
      .disposed(by: disposeBag)
  }
  
  /// 자신의 정보를 업데이트합니다.
  func retrieveMyInformation() {
    APIService.memberProvider.rx.request(.retrieveMember)
      .asObservable()
      .retry()
      .subscribe { response in
        switch response.statusCode {
        case 200:
          let myInformation = APIService.decode(
            ResponseModel<MemberModel.MyInformation>.self,
            data: response.data
          ).data
          MemberInfoStorage.instance.saveMyInformation(from: myInformation)
        default:
          let viewController = LoginViewController()
          viewController.modalPresentationStyle = .fullScreen
        }
      }
      .disposed(by: disposeBag)
  }
}
