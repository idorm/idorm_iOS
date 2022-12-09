import UIKit

import Then
import SnapKit
import RxSwift
import RxCocoa

final class KakaoPopup: BaseViewController {
  
  // MARK: - Properties
  
  private let containerView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 16
  }
  
  private let mainLabel = UILabel().then {
    $0.text = "상대의 카카오톡 오픈채팅으로 이동합니다."
    $0.font = .init(name: MyFonts.medium.rawValue, size: 14)
    $0.textColor = .black
  }
  
  private let xmarkButton = UIButton().then {
    $0.setImage(#imageLiteral(resourceName: "Xmark_Black"), for: .normal)
  }
  
  let kakaoButton = UIButton().then {
    var container = AttributeContainer()
    container.foregroundColor = .white
    container.font = .init(name: MyFonts.medium.rawValue, size: 14)

    var config = UIButton.Configuration.filled()
    config.attributedTitle = AttributedString("카카오톡으로 이동", attributes: container)
    config.image = #imageLiteral(resourceName: "kakao")
    config.imagePlacement = .leading
    config.imagePadding = 10
    config.baseBackgroundColor = .idorm_blue
    
    $0.configuration = config
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    view.backgroundColor = .black.withAlphaComponent(0.5)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    view.addSubview(containerView)
    
    [xmarkButton, mainLabel, kakaoButton]
      .forEach { containerView.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    containerView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.centerY.equalToSuperview()
      make.height.equalTo(230)
    }
    
    xmarkButton.snp.makeConstraints { make in
      make.top.trailing.equalToSuperview().inset(16)
    }
    
    mainLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(xmarkButton.snp.bottom).offset(36)
    }
    
    kakaoButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.bottom.equalToSuperview().inset(30)
      make.height.equalTo(55)
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    // 창 닫기
    xmarkButton.rx.tap
      .bind(onNext: { [weak self] in
        self?.dismiss(animated: false)
      })
      .disposed(by: disposeBag)
  }
}
