import UIKit

import SnapKit
import Then
import RxSwift
import RxCocoa
import RxGesture

final class MyPageViewController: BaseViewController {
  
  // MARK: - Properties
  
  private var scrollView: UIScrollView!
  private var contentView: UIView!
  private var gearButton: UIButton!
    
  private let lionImageView = UIImageView(image: #imageLiteral(resourceName: "BottonLion(MyPage)"))
  private let topProfileView = TopProfileView()
  private let matchingContainerView = MatchingContainerView()
  
  private let viewModel = MyPageViewModel()
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    setupScrollView()
    super.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.isHidden = false
    tabBarController?.tabBar.isHidden = false
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    
  }
  
  // MARK: - Setup
  
  private func setupScrollView() {
    let scrollView = UIScrollView()
    scrollView.bounces = false
    self.scrollView = scrollView
    
    let contentView = UIView()
    contentView.backgroundColor = .idorm_gray_100
    self.contentView = contentView
  }
  
  override func setupStyles() {
    super.setupStyles()
    
    let gearButton = UIButton()
    gearButton.setImage(UIImage(named: "gear"), for: .normal)
    self.gearButton = gearButton
    
    view.backgroundColor = .white
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: gearButton)
    
    // MARK: - NavigationBarAppearance
    let navigationBarAppearance = UINavigationBarAppearance()
    navigationBarAppearance.backgroundColor = .idorm_blue
    navigationBarAppearance.shadowImage = UIImage()
    navigationBarAppearance.shadowColor = .clear
    navigationController?.navigationBar.standardAppearance = navigationBarAppearance
    navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
    
    // MARK: - TabBarAppearance
    let appearance = UITabBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = .idorm_gray_100
    appearance.backgroundImage = UIImage()
    appearance.shadowImage = UIImage()
    appearance.shadowColor = .clear
    tabBarController?.tabBar.standardAppearance = appearance
    tabBarController?.tabBar.scrollEdgeAppearance = appearance
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    view.addSubview(scrollView)
    scrollView.addSubview(contentView)
    
    [topProfileView, matchingContainerView, lionImageView]
      .forEach { contentView.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    scrollView.snp.makeConstraints { make in
      make.edges.equalTo(view.safeAreaLayoutGuide)
    }
    
    contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalTo(view.frame.width)
    }
    
    topProfileView.snp.makeConstraints { make in
      make.leading.trailing.top.equalToSuperview()
      make.height.equalTo(146)
    }
    
    matchingContainerView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(topProfileView.snp.bottom).offset(24)
    }
    
    lionImageView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
    }
  }
}

// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct MyPageVC_PreView: PreviewProvider {
  static var previews: some View {
    MyPageViewController().toPreview()
  }
}
#endif
