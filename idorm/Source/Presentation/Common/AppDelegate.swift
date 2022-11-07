import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
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
    
    return true
  }
}
