//
//  iDormTextField.swift
//  idorm
//
//  Created by 김응철 on 7/26/23.
//

import UIKit

import Then
import SnapKit
import RxSwift
import RxCocoa

final class iDormTextField: UITextField {
  
  // MARK: - UI Components
  
  // MARK: - Properties
  
  let checkmarkButton = UIButton().then {
    $0.setImage(UIImage(named: "circle_checkmark_blue"), for: .normal)
    $0.isUserInteractionEnabled = false
    $0.isHidden = true
  }
  
  private var disposeBag = DisposeBag()
  
  // MARK: - Init
  
  init(_ title: String) {
    super.init(frame: .zero)
    setupStyles(title)
    setupLayout()
    setupConstraints()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  private func setupStyles(_ title: String) {
    self.attributedPlaceholder = NSAttributedString(
      string: title,
      attributes: [
        .foregroundColor: UIColor.idorm_gray_300,
        .font: UIFont.init(name: IdormFont_deprecated.medium.rawValue, size: 14) ?? 0
      ]
    )
    font = .init(name: IdormFont_deprecated.medium.rawValue, size: 14)
    textColor = .idorm_gray_300
    addLeftPadding(14)
    layer.borderWidth = 1
    layer.borderColor = UIColor.idorm_gray_300.cgColor
    layer.cornerRadius = 10
    backgroundColor = .white
  }
  
  private func setupLayout() {
    addSubview(checkmarkButton)
  }
  
  private func setupConstraints() {
    checkmarkButton.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().inset(8)
    }
  }
  
  // MARK: - Bind
  
  private func bind() {
    
    rx.controlEvent(.editingDidBegin)
      .map { UIColor.idorm_blue.cgColor }
      .bind(to: layer.rx.borderColor)
      .disposed(by: disposeBag)
    
    rx.controlEvent(.editingDidEnd)
      .map { UIColor.idorm_gray_300.cgColor }
      .bind(to: layer.rx.borderColor)
      .disposed(by: disposeBag)
  }
}
