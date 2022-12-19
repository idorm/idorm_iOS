import UIKit

import RxMoya
import RxSwift

final class TabBarController: UITabBarController {
  
  // MARK: - Properties
  
  let disposeBag = DisposeBag()
  
  let homeVC = UINavigationController(rootViewController: HomeViewController())
  let matchingVC = UINavigationController(rootViewController: MatchingViewController())
  let communityVC = UINavigationController(rootViewController: CommunityViewController())
  let calandarVC = UINavigationController(rootViewController: CalendarViewController())
  let mypageVC = UINavigationController(rootViewController: MyPageViewController())
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    
    // 탭바 최초 데이터 설정
    
    let email = UserStorage.loadEmail()
    let password = UserStorage.loadPassword()
    
    APIService.memberProvider.rx.request(.login(id: email, pw: password))
      .asObservable()
      .retry()
      .withUnretained(self)
      .subscribe { owner, response in
        switch response.statusCode {
        case 200:
          let info = APIService.decode(
            ResponseModel<MemberModel.MyInformation>.self,
            data: response.data
          ).data
          TokenStorage.saveToken(token: info.loginToken!)
          MemberInfoStorage.instance.saveMyInformation(from: info)
          SharedAPI.instance.retrieveMyOnboarding()
        default:
          let viewController = UINavigationController(rootViewController: LoginViewController())
          viewController.modalPresentationStyle = .fullScreen
          owner.present(viewController, animated: true)
        }
      }
      .disposed(by: disposeBag)
  }
  
  // MARK: - Setup
  
  private func configureUI() {
    tabBar.unselectedItemTintColor = .gray
    tabBar.tintColor = .idorm_blue
    tabBar.barTintColor = .white
    tabBar.backgroundColor = .white
    tabBar.layer.borderColor = UIColor.idorm_gray_200.cgColor
    tabBar.layer.borderWidth = 1
    tabBar.layer.cornerRadius = 24.0
    tabBar.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
    
    homeVC.tabBarItem = returnTabBarItem(text: "홈", imageName: "TabHome")
//    communityVC.tabBarItem = returnTabBarItem(text: "커뮤니티", imageName: "TabCommunity")
//    calandarVC.tabBarItem = returnTabBarItem(text: "캘린더", imageName: "TabCalandar")
    mypageVC.tabBarItem = returnTabBarItem(text: "마이페이지", imageName: "TabMypage")
    matchingVC.tabBarItem = returnTabBarItem(text: "룸메 매칭", imageName: "TabRoommate")
    
    homeVC.navigationBar.tintColor = .black
//    communityVC.navigationBar.tintColor = .black
//    calandarVC.navigationBar.tintColor = .black
    mypageVC.navigationBar.tintColor = .black
    matchingVC.navigationBar.tintColor = .black
    
    viewControllers = [ homeVC, matchingVC, mypageVC ]
  }
  
  private func returnTabBarItem(text: String, imageName: String) -> UITabBarItem {
    return UITabBarItem(title: text, image: UIImage(named: imageName), selectedImage: UIImage(named: imageName))
  }
}
