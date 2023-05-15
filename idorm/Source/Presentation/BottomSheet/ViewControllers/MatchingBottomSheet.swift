import UIKit

import RxSwift
import RxCocoa
import PanModal
import SnapKit
import Then

final class MatchingBottomSheet: BaseViewController {
  
  // MARK: - Properties
  
  private let reportButton = BottomSheetUtils.reportButton()
  private let blockingButton = BottomSheetUtils.basicButton("사용자 차단", imageName: "circle_cancel")
  
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
    
    [
      xmarkButton,
      reportButton,
      blockingButton
    ]
      .forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    xmarkButton.snp.makeConstraints { make in
      make.top.trailing.equalToSuperview().inset(16)
    }
    
    blockingButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(xmarkButton.snp.bottom).offset(4)
    }
    
    reportButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(blockingButton.snp.bottom)
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
    
    // 사용자 차단
    blockingButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.dismiss(animated: true)
      }
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
  
  var longFormHeight: PanModalHeight { .contentHeight(161) }
  
  var shortFormHeight: PanModalHeight { .contentHeight(161) }
  
  var showDragIndicator: Bool { false }
  
  var cornerRadius: CGFloat { return 24 }
}
