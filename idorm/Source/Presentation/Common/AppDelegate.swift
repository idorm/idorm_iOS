import UIKit

import RxSwift
import RxCocoa

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var disposeBag = DisposeBag()
  
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // MARK: - Setup UI
    
    let appearance = AppearanceManager.navigationAppearance(from: .white, shadow: false)
    UINavigationBar.appearance().compactAppearance = appearance
    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
    
    let tabBarAppearance = UITabBarAppearance()
    let tabBar = UITabBar()
    tabBarAppearance.configureWithOpaqueBackground()
    tabBarAppearance.backgroundColor = .white
    tabBarAppearance.backgroundImage = UIImage()
    tabBarAppearance.shadowImage = UIImage()
    tabBarAppearance.shadowColor = .clear
    tabBar.standardAppearance = tabBarAppearance
    UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    UITabBar.appearance().standardAppearance = tabBarAppearance
    
    if TokenStorage.shared.hasToken() {
      requestMemberAPI()
      requestMatchingInfo()
    }
    
    return true
  }
}

// MARK: - Network

extension AppDelegate {
  
  /// 멤버 단건 조회 API 요청
  func requestMemberAPI() {
    MemberService.shared.memberAPI()
      .subscribe(onNext: { response in
        guard let statusCode = response.response?.statusCode else { return }
        switch statusCode {
        case 200: // 멤버 단건 조회 완료
          guard let data = response.data else { return }
          struct ResponseModel: Codable {
            let data: MemberInfo
          }
          let memberInformation = APIService.decode(ResponseModel.self, data: data).data
          MemberInfoStorage.shared.memberInfo.accept(memberInformation)
        default: break
        }
      })
      .disposed(by: disposeBag)
  }
  
  /// 멤버 최초 온보딩 매칭 유무 조회
  func requestMatchingInfo() {
    OnboardingService.shared.matchingInfoAPI_Get()
      .subscribe(onNext: { response in
        guard let statusCode = response.response?.statusCode else { return }
        switch statusCode {
        case 200:
          guard let data = response.data else { return }
          struct ResponseModel: Codable {
            let data: MatchingInfo_Lookup
          }
          let matchingInfo = APIService.decode(ResponseModel.self, data: data).data
          MemberInfoStorage.shared.matchingInfo.accept(matchingInfo)
        case 409:
          break
        default: // 서버 오류 & 로그인 오류
          fatalError()
        }
      })
      .disposed(by: disposeBag)
  }
}
