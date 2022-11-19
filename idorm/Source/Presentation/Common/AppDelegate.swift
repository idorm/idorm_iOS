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
    
    if TokenStorage.instance.hasToken() {
      SharedAPI.instance.retrieveMyInformation()
      SharedAPI.instance.retrieveMyOnboarding()
    }
    
    return true
  }
}
