import UIKit

import RxSwift
import RxCocoa
import PanModal
import SnapKit
import Then

final class MatchingBottomAlertViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let reportButton = BottomAlertUtilities.getReportButton()
  
  private let xmarkButton = UIButton().then {
    $0.setImage(UIImage(named: "Xmark_Black"), for: .normal)
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .white
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [xmarkButton, reportButton]
      .forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    xmarkButton.snp.makeConstraints { make in
      make.top.trailing.equalToSuperview().inset(16)
    }
    
    reportButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(xmarkButton.snp.bottom).offset(4)
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

// MARK: - PanModal Setup

extension MatchingBottomAlertViewController: PanModalPresentable {
  
  var panScrollable: UIScrollView? {
    return nil
  }
  
  var longFormHeight: PanModalHeight {
    return PanModalHeight.contentHeight(113)
  }
  
  var shortFormHeight: PanModalHeight {
    return PanModalHeight.contentHeight(113)
  }
}
