//
//  ProfilePublicCell.swift
//  idorm
//
//  Created by 김응철 on 9/29/23.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class ProfilePublicCell: BaseCollectionViewCell {
  
  // MARK: - UI Components
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.text = "내 매칭 이미지 매칭페이지에 공개하기"
    label.font = .iDormFont(.regular, size: 12.0)
    label.textColor = .black
    return label
  }()
  
  private let toggleButton: UIButton = {
    let button = UIButton()
    button.setImage(.iDormImage(.select), for: .selected)
    button.setImage(.iDormImage(.deselect), for: .normal)
    return button
  }()
  
  // MARK: - Properties
  
  var buttonHandler: (() -> Void)?
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    self.backgroundColor = .clear
  }
  
  override func setupLayouts() {
    [
      self.titleLabel,
      self.toggleButton
    ].forEach {
      self.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.titleLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24.0)
      make.centerY.equalToSuperview()
    }
    
    self.toggleButton.snp.makeConstraints { make in
      make.centerY.equalTo(self.titleLabel)
      make.leading.equalTo(self.titleLabel.snp.trailing).offset(12.0)
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    self.toggleButton.rx.tap.asDriver()
      .drive(with: self) { owner, _ in
        owner.buttonHandler?()
      }
      .disposed(by: self.disposeBag)
  }
}
