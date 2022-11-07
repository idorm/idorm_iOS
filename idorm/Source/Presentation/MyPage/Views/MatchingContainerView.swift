import UIKit

import SnapKit
import Then

final class MatchingContainerView: UIView {
  
  // MARK: - Properties
  
  private var titleLabel: UILabel!
  var manageMatchingImageButton: UIButton!
  var likedRoommateButton: UIButton!
  var buttonStack: UIStackView!
  var shareStack: UIStackView!
  
  private let shareLabel = UILabel().then {
    $0.text = "내 이미지 매칭페이지에 공유하기"
    $0.textColor = .idorm_gray_400
    $0.font = .init(name: MyFonts.medium.rawValue, size: 14)
  }
  
  let shareButton = UIButton().then {
    var config = UIButton.Configuration.plain()
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      switch button.state {
      case .selected:
        button.configuration?.image = #imageLiteral(resourceName: "toggleHover(Matching)")
      default:
        button.configuration?.image = UIImage(named: "toggle(Matching)")
        button.configuration?.baseBackgroundColor = .clear
      }
    }
    $0.configuration = config
    $0.configurationUpdateHandler = handler
  }
  
  // MARK: - LifeCycle
  
  override init(frame: CGRect) {
    super.init(frame: .zero)
    setupComponents()
    setupStyles()
    setupLayout()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  private func setupComponents() {
    self.titleLabel = MyPageUtilities.createTitleLabel(title: "룸메이트 매칭 관리")
    self.manageMatchingImageButton = MyPageUtilities.createMatchingButton(imageName: "picture(MyPage)", title: "매칭 이미지 관리")
    self.likedRoommateButton = MyPageUtilities.createMatchingButton(imageName: "heart(MyPage)", title: "좋아요한 룸메")
    
    let buttonStack = UIStackView()
    buttonStack.addArrangedSubview(manageMatchingImageButton)
    buttonStack.addArrangedSubview(likedRoommateButton)
    buttonStack.axis = .horizontal
    buttonStack.spacing = 34
    self.buttonStack = buttonStack
    
    let shareStack = UIStackView()
    shareStack.addArrangedSubview(shareLabel)
    shareStack.addArrangedSubview(shareButton)
    shareStack.axis = .horizontal
    shareStack.spacing = 8
    self.shareStack = shareStack
  }
  
  private func setupStyles() {
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOffset = CGSize(width: 0, height: 5)
    layer.shadowOpacity = 0.1
    backgroundColor = .white
  }
  
  private func setupLayout() {
    [titleLabel, buttonStack, shareStack]
      .forEach { addSubview($0) }
  }
  
  private func setupConstraints() {
    titleLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.top.equalToSuperview().inset(16)
    }
    
    buttonStack.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.top.equalTo(titleLabel.snp.bottom).offset(16)
    }
    
    shareStack.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.top.equalTo(buttonStack.snp.bottom).offset(20)
      make.bottom.equalToSuperview().inset(16)
    }
  }
}
