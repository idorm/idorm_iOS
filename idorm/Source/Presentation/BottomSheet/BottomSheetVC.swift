//
//  BottomSheetVC.swift
//  idorm
//
//  Created by 김응철 on 7/24/23.
//

import UIKit

import PanModal
import SnapKit

protocol BottomSheetViewControllerDelegate: AnyObject {
  func didTapButton(index: Int)
}

final class BottomSheetViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let contentHeight: CGFloat
  private let buttons: [UIButton]
  weak var delegate: BottomSheetViewControllerDelegate?
  
  // MARK: - UI Components
  
  /// 취소 버튼
  private lazy var cancelButton: UIButton = {
    let button = UIButton()
    button.setImage(.iDormIcon(.cancel), for: .normal)
    button.addTarget(self, action: #selector(self.didTapCancelButton), for: .touchUpInside)
    return button
  }()
  
  /// 버튼 스택
  private lazy var buttonStackView: UIStackView = {
    let stackView = UIStackView()
    self.buttons.forEach { stackView.addArrangedSubview($0) }
    stackView.axis = .vertical
    return stackView
  }()
  
  // MARK: - Initializer
  
  init(
    items: [BottomSheetItem],
    contentHeight: CGFloat
  ) {
    self.contentHeight = contentHeight
    self.buttons = items.map { $0.button }
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    self.view.backgroundColor = .white
    
    self.buttons.forEach {
      $0.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [
      self.cancelButton,
      self.buttonStackView
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.cancelButton.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(10.0)
      make.trailing.equalToSuperview().inset(18.0)
    }
    
    self.buttonStackView.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview().inset(24.0)
      make.top.equalTo(self.cancelButton.snp.bottom).offset(4.0)
    }
  }
  
  // MARK: - Selectors
  
  /// `X`버튼을 눌렀을 때의 메서드
  @objc
  private func didTapCancelButton() {
    self.dismiss(animated: true)
  }
  
  /// 생성된 버튼 중 아무거나 눌렀을 때의 메서드
  @objc
  private func didTapButton(_ button: UIButton) {
    guard let index = self.buttons.firstIndex(of: button) else { return }
    self.dismiss(animated: true)
    self.delegate?.didTapButton(index: index)
  }
}

// MARK: - PanModal

extension BottomSheetViewController: PanModalPresentable {
  var panScrollable: UIScrollView? { nil }
  var shortFormHeight: PanModalHeight { .contentHeight(self.contentHeight) }
  var longFormHeight: PanModalHeight { .contentHeight(self.contentHeight) }
  var showDragIndicator: Bool { false }
  var cornerRadius: CGFloat { 24.0 }
}
