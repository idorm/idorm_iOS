import UIKit

import SnapKit
import Then
import RxSwift
import RxCocoa
import RxGesture

final class NoPublicStatePopUp: BaseViewController {
  
  // MARK: - Properties
  
  private let cancelLabel = UILabel().then {
    $0.text = "취소"
    $0.textColor = .idorm_gray_300
    $0.font = .init(name: MyFonts.medium.rawValue, size: 14)
  }
  
  let confirmLabel = UILabel().then {
    $0.text = "공개 허용"
    $0.textColor = .idorm_blue
    $0.font = .init(name: MyFonts.medium.rawValue, size: 14)
  }
  
  private let containerView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 12
  }
  
  private let mainLabel = UILabel().then {
    $0.text = """
              룸메이트 매칭을 위해
              우선 내 매칭 이미지를
              매칭페이지에 공개해야 해요.
              """
    $0.textColor = .black
    $0.font = .init(name: MyFonts.regular.rawValue, size: 14)
    $0.numberOfLines = 3
    $0.textAlignment = .center
  }
  
  private let xmarkButton = UIButton().then {
    $0.setImage(#imageLiteral(resourceName: "xmark_black"), for: .normal)
  }
  
  private let indicator = UIActivityIndicatorView().then {
    $0.color = .gray
  }
    
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .black.withAlphaComponent(0.5)
  }
  
  override func setupLayouts() {
    view.addSubview(containerView)
    [xmarkButton, mainLabel, cancelLabel, confirmLabel, indicator]
      .forEach { containerView.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    containerView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.height.equalTo(220)
      make.centerY.equalToSuperview()
    }
    
    xmarkButton.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(20)
      make.trailing.equalToSuperview().inset(16)
    }
    
    mainLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(xmarkButton.snp.bottom).offset(24)
    }
    
    confirmLabel.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(16)
      make.bottom.equalToSuperview().inset(20)
    }
    
    cancelLabel.snp.makeConstraints { make in
      make.centerY.equalTo(confirmLabel)
      make.trailing.equalTo(confirmLabel.snp.leading).offset(-26)
    }
    
    indicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    xmarkButton.rx.tap
      .bind(onNext: { [weak self] in
        self?.dismiss(animated: false)
      })
      .disposed(by: disposeBag)
    
    cancelLabel.rx.tapGesture()
      .bind(onNext: { [weak self] _ in
        self?.dismiss(animated: false)
      })
      .disposed(by: disposeBag)
  }
}
