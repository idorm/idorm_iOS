//
//  ManagementMyInfoMembershipCell.swift
//  idorm
//
//  Created by 김응철 on 9/29/23.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class ManagementMyInfoMembershipCell: BaseCollectionViewCell {
  
  // MARK: - UI Components
  
  private let withdrawalButton: iDormButton = {
    let button = iDormButton("회원 탈퇴")
    button.baseForegroundColor = .iDormColor(.iDormGray300)
    button.baseBackgroundColor = .clear
    button.contentInset = .zero
    button.font = .iDormFont(.regular, size: 14.0)
    return button
  }()
  
  private let logoutButton: iDormButton = {
    let button = iDormButton("로그아웃")
    button.baseBackgroundColor = .iDormColor(.iDormBlue)
    button.baseForegroundColor = .white
    button.font = .iDormFont(.medium, size: 16.0)
    button.cornerRadius = 6.0
    return button
  }()
  
  // MARK: - Properties
  
  var withdrawlButtonHandler: (() -> Void)?
  var logoutButtonHandler: (() -> Void)?
  
  // MARK: - Setup
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [
      self.withdrawalButton,
      self.logoutButton
    ].forEach {
      self.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.withdrawalButton.snp.makeConstraints { make in
      make.leading.top.equalToSuperview()
    }
    
    self.logoutButton.snp.makeConstraints { make in
      make.top.equalTo(self.withdrawalButton.snp.bottom).offset(36.0)
      make.directionalHorizontalEdges.equalToSuperview()
      make.height.equalTo(52.0)
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    self.withdrawalButton.rx.tap.asDriver()
      .drive(with: self) { owner, _ in
        owner.withdrawlButtonHandler?()
      }
      .disposed(by: self.disposeBag)
    
    self.logoutButton.rx.tap.asDriver()
      .drive(with: self) { owner, _ in
        owner.logoutButtonHandler?()
      }
      .disposed(by: self.disposeBag)
  }
}
