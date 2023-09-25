import UIKit

import Then
import SnapKit
import RxSwift
import RxCocoa
import RxGesture

final class KakaoPopupViewController: BaseViewController {
  
  // MARK: - UI Components
  
  private let containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.layer.cornerRadius = 16
    return view
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.text = "상대의 카카오톡 오픈채팅으로 이동합니다."
    label.font = .iDormFont(.medium, size: 14.0)
    label.textColor = .black
    return label
  }()
  
  private let kakaoButton: iDormButton = {
    let button = iDormButton("카카오톡으로 이동", image: .iDormIcon(.kakao))
    button.imagePadding = 10.0
    button.cornerRadius = 10.0
    button.baseBackgroundColor = .iDormColor(.iDormBlue)
    button.baseForegroundColor = .white
    button.font = .iDormFont(.medium, size: 14.0)
    button.height = 55.0
    return button
  }()
  
  private let cancelButton: UIButton = {
    let button = UIButton()
    button.setImage(.iDormIcon(.cancel), for: .normal)
    return button
  }()
  
  // MARK: - Properties
  
  var kakaoButtonHandler: (() -> Void)?
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    self.view.backgroundColor = .black.withAlphaComponent(0.5)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    view.addSubview(containerView)
    [
      self.cancelButton,
      self.titleLabel,
      self.kakaoButton
    ].forEach {
      self.containerView.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.containerView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.centerY.equalToSuperview()
      make.height.equalTo(230.0)
    }
    
    self.cancelButton.snp.makeConstraints { make in
      make.top.trailing.equalToSuperview().inset(16.0)
    }
    
    self.titleLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.cancelButton.snp.bottom).offset(36.0)
    }
    
    self.kakaoButton.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview().inset(24.0)
      make.bottom.equalToSuperview().inset(30.0)
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    self.view.rx.tapGesture()
      .when(.recognized)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        owner.dismiss(animated: false)
      }
      .disposed(by: self.disposeBag)
    
    self.cancelButton.rx.tap.asDriver()
      .drive(with: self) { owner, _ in
        owner.dismiss(animated: false)
      }
      .disposed(by: self.disposeBag)
    
    self.kakaoButton.rx.tap.asDriver()
      .drive(with: self) { owner, _ in
        owner.dismiss(animated: false)
        owner.kakaoButtonHandler?()
      }
      .disposed(by: self.disposeBag)
  }
}
