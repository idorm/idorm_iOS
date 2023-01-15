import UIKit

import RxSwift
import RxCocoa
import PanModal
import SnapKit
import Then

final class MatchingBottomSheet: BaseViewController {
  
  // MARK: - Properties
  
  private let reportButton = BottomSheetUtils.reportButton()
  
  private let xmarkButton = UIButton().then {
    $0.setImage(UIImage(named: "xmark_black"), for: .normal)
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
        self?.dismiss(animated: true)
      })
      .disposed(by: disposeBag)
    
    // 신고하기 버튼
    reportButton.rx.tap
      .withUnretained(self)
      .bind {
        $0.0.dismiss(animated: true)
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - PanModal Setup

extension MatchingBottomSheet: PanModalPresentable {
  
  var panScrollable: UIScrollView? { nil }
  
  var longFormHeight: PanModalHeight { .contentHeight(113) }
  
  var shortFormHeight: PanModalHeight { .contentHeight(113) }
  
  var showDragIndicator: Bool { false }
  
  var cornerRadius: CGFloat { return 24 }
}
