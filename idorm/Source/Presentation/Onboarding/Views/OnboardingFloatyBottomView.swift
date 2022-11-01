import UIKit

import SnapKit
import Then

enum OnboardingFloatyBottomViewType {
  /// [정보 입력 건너 뛰기], [완료]
  case normal
  /// [뒤로가기], [완료]
  case detail
  /// [입력초기화], [완료]
  case update
  /// [선택초기화], [필터링 완료]
  case matchingFilter
}

class OnboardingFloatyBottomView: UIView {
  
  // MARK: - Properties
  
  lazy var containerView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOffset = CGSize(width: 0, height: -4)
    $0.layer.shadowOpacity = 0.14
  }
  
  lazy var skipButton = UIButton().then {
    var container = AttributeContainer()
    container.font = .init(name: MyFonts.medium.rawValue, size: 16)
    container.foregroundColor = .idorm_gray_400
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = .idorm_gray_100
    config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 26, bottom: 14, trailing: 26)
    
    switch type {
    case .normal:
      config.attributedTitle = AttributedString("정보 입력 건너 뛰기", attributes: container)
    case .detail:
      config.attributedTitle = AttributedString("뒤로 가기", attributes: container)
    case .update:
      config.attributedTitle = AttributedString("입력 초기화", attributes: container)
      config.image = UIImage(named: "reset(Onboarding)")
      config.imagePlacement = .leading
      config.imagePadding = 12
    case .matchingFilter:
      config.attributedTitle = AttributedString("선택 초기화", attributes: container)
      config.image = UIImage(named: "reset(Onboarding)")
      config.imagePlacement = .leading
      config.imagePadding = 12
    }
    $0.configuration = config
  }
  
  lazy var confirmButton = UIButton().then {
    var container = AttributeContainer()
    container.font = .init(name: MyFonts.medium.rawValue, size: 16)
    container.foregroundColor = UIColor.white
    var config = UIButton.Configuration.filled()
    config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 26, bottom: 14, trailing: 26)
    config.attributedTitle = AttributedString("완료", attributes: container)
    
    switch type {
    case .normal:
      config.baseBackgroundColor = .idorm_gray_300
    case .detail:
      config.baseBackgroundColor = .idorm_blue
    case .update:
      config.baseBackgroundColor = .idorm_blue
    case .matchingFilter:
      config.attributedTitle = AttributedString("필터링 완료", attributes: container)
      config.baseBackgroundColor = .idorm_blue
    }
    $0.isUserInteractionEnabled = false
    $0.configuration = config
  }
  
  var type: OnboardingFloatyBottomViewType = .normal
  
  // MARK: - Helpers
  
  func configureUI(type: OnboardingFloatyBottomViewType) {
    self.type = type
    addSubview(containerView)
    
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    [ skipButton, confirmButton ]
      .forEach { containerView.addSubview($0) }
    
    skipButton.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.centerY.equalToSuperview()
    }
    
    confirmButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(24)
      make.centerY.equalToSuperview()
    }
  }
}
