import RxMoya
import RxSwift

final class SharedAPI {
  static let instance = SharedAPI()
  private init() {}
  private let disposeBag = DisposeBag()
}

// MARK: - MemberAPI

extension SharedAPI {
  /// 자신의 정보를 업데이트합니다.
  func retrieveMyInformation() {
    APIService.memberProvider.rx.request(.retrieveMember)
      .asObservable()
      .subscribe(onNext: { response in
        switch response.statusCode {
        case 200:
          let myInformation = APIService.decode(ResponseModel<MemberModel.MyInformation>.self, data: response.data).data
          MemberInfoStorage.instance.saveMyInformation(from: myInformation)
        default:
          fatalError("token is missing")
        }
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - OnboardingAPI

extension SharedAPI {
  
  /// 나의 매칭 정보를 가져와서 저장합니다.
  func retrieveMyOnboarding() {
    APIService.onboardingProvider.request(.retrieve) { result in
      switch result {
      case .success(let response):
        switch response.statusCode {
        case 200:
          let responseModel = APIService.decode(ResponseModel<OnboardingModel.MyOnboarding>.self, data: response.data).data
          MemberInfoStorage.instance.saveMyOnboarding(from: responseModel)
        case 409:
          break
        default:
          fatalError("Token is expired!")
        }
      case .failure(let error):
        print(error.localizedDescription)
      }
    }
  }
}
