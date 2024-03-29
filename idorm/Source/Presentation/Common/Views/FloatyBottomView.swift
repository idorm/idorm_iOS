import UIKit

import SnapKit
import Then

enum FloatyBottomViewType {
  /// [정보 입력 건너 뛰기], [완료]
  case jump
  /// [뒤로가기], [완료]
  case back
  /// [입력초기화], [완료]
  case reset
  /// [선택초기화], [필터링 완료]
  case filter
  /// [정보수정], [완료]
  case correction
  /// [다시생각해볼게요], [탈퇴]
  case withdrawal
}

/// 하단에 붙어있는 두 개의 버튼이 있는 View입니다.
final class FloatyBottomView: UIView {
  
  // MARK: - Properties
  
  lazy var containerView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOffset = CGSize(width: 0, height: -4)
    $0.layer.shadowOpacity = 0.14
  }
  
  lazy var leftButton = UIButton().then {
    var container = AttributeContainer()
    container.font = .init(name: IdormFont_deprecated.medium.rawValue, size: 16)
    container.foregroundColor = .idorm_gray_400
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = .idorm_gray_100
    config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 26, bottom: 14, trailing: 26)
    
    switch floatyBottomViewType {
    case .jump:
      config.attributedTitle = AttributedString("정보 입력 건너 뛰기", attributes: container)
    case .back:
      config.attributedTitle = AttributedString("뒤로 가기", attributes: container)
    case .reset:
      config.attributedTitle = AttributedString("입력 초기화", attributes: container)
      config.image = UIImage(named: "reset(Onboarding)")
      config.imagePlacement = .leading
      config.imagePadding = 12
    case .filter:
      config.attributedTitle = AttributedString("선택 초기화", attributes: container)
      config.image = UIImage(named: "reset(Onboarding)")
      config.imagePlacement = .leading
      config.imagePadding = 12
    case .correction:
      config.attributedTitle = AttributedString("정보 수정", attributes: container)
    case .withdrawal:
      config.attributedTitle = AttributedString("다시 생각해볼래요❤️", attributes: container)
    }
    $0.configuration = config
  }
  
  lazy var rightButton = UIButton().then {
    var container = AttributeContainer()
    container.font = .init(name: IdormFont_deprecated.medium.rawValue, size: 16)
    container.foregroundColor = UIColor.white
    var config = UIButton.Configuration.filled()
    config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 26, bottom: 14, trailing: 26)
    config.attributedTitle = AttributedString("완료", attributes: container)
    config.baseBackgroundColor = .idorm_blue
    
    switch floatyBottomViewType {
    case .filter:
      config.attributedTitle = AttributedString("필터링 완료", attributes: container)
    case .withdrawal:
      config.attributedTitle = AttributedString("탈퇴", attributes: container)
    default:
      break
    }
    $0.configuration = config
  }
  
  let floatyBottomViewType: FloatyBottomViewType
  
  // MARK: - LifeCycle
  
  init(_ floatyBottomViewType: FloatyBottomViewType) {
    self.floatyBottomViewType = floatyBottomViewType
    super.init(frame: .zero)
    setupLayout()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  private func setupLayout() {
    addSubview(containerView)
    [ leftButton, rightButton ]
      .forEach { containerView.addSubview($0) }
  }
  
  private func setupConstraints() {
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    leftButton.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.centerY.equalToSuperview()
    }
    
    rightButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(24)
      make.centerY.equalToSuperview()
    }
  }
}
