import UIKit

import SnapKit
import Then
import RxSwift
import RxCocoa
import RxGesture

final class MatchingNoSharePopUpViewController: BaseViewController {
  
  // MARK: - Properties
  
  private var containerView: UIView!
  private var mainLabel: UILabel!
  private var cancelButton: UILabel!
  var confirmButton: UILabel!
  private var xmarkButton: UIButton!
  private let indicator = UIActivityIndicatorView()
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    setupContainerView()
    setupComponents()
    super.viewDidLoad()
  }
  
  // MARK: - Setup
  
  private func setupContainerView() {
    let view = UIView()
    view.backgroundColor = .white
    view.layer.cornerRadius = 12
    self.containerView = view
  }
  
  private func setupComponents() {
    let mainLabel = UIFactory.label(text: """
                                                룸메이트 매칭을 위해
                                                우선 내 매칭 이미지를
                                                매칭페이지에 공개해야 해요.
                                                """,
                                          color: .black,
                                          font: .init(name: MyFonts.regular.rawValue, size: 14))
    mainLabel.numberOfLines = 0
    mainLabel.textAlignment = .center
    self.mainLabel = mainLabel
    self.cancelButton = UIFactory.label(text: "취소", color: .idorm_gray_300, font: .init(name: MyFonts.medium.rawValue, size: 14))
    self.confirmButton = UIFactory.label(text: "공개 허용", color: .idorm_blue, font: .init(name: MyFonts.medium.rawValue, size: 14))
    self.xmarkButton = UIButton().then {
      $0.setImage(#imageLiteral(resourceName: "Xmark_Black"), for: .normal)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .black.withAlphaComponent(0.5)
  }
  
  override func setupLayouts() {
    view.addSubview(containerView)
    [xmarkButton, mainLabel, cancelButton, confirmButton, indicator]
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
    
    confirmButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(16)
      make.bottom.equalToSuperview().inset(20)
    }
    
    cancelButton.snp.makeConstraints { make in
      make.centerY.equalTo(confirmButton)
      make.trailing.equalTo(confirmButton.snp.leading).offset(-26)
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
    
    cancelButton.rx.tapGesture()
      .bind(onNext: { [weak self] _ in
        self?.dismiss(animated: false)
      })
      .disposed(by: disposeBag)
  }
}
