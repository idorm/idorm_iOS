//
//  ManagementAccountNotifyView.swift
//  idorm
//
//  Created by 김응철 on 9/30/23.
//

import UIKit

import SnapKit

final class ManagementAccountNotifyView: BaseView {
  
  // MARK: - UI Components
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.text = "idorm 탈퇴 전 알아두셔야 해요!"
    label.textColor = .black
    label.font = .iDormFont(.medium, size: 20.0)
    return label
  }()
  
  private let containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .iDormColor(.iDormGray100)
    return view
  }()
  
  private let subtitleLabel1: UILabel = {
    let label = UILabel()
    label.text = "📌 idorm 탈퇴 후에도 커뮤니티 내에는\n작성하신 글과 댓글은 남아 있어요."
    label.font = .iDormFont(.regular, size: 16.0)
    label.textColor = .iDormColor(.iDormGray400)
    label.numberOfLines = 2
    return label
  }()
  
  private let subtitleLabel2: UILabel = {
    let label = UILabel()
    label.text = "📌 탈퇴 시 프로필과 내 정보 데이터는\n다시 복구할 수 없어요."
    label.font = .iDormFont(.regular, size: 16.0)
    label.textColor = .iDormColor(.iDormGray400)
    label.numberOfLines = 2
    return label
  }()
  
  // MARK: - Setup
  
  override func setupLayouts() {
    super.setupLayouts()

    self.addSubview(self.titleLabel)
    self.addSubview(self.containerView)
    [
      self.subtitleLabel1,
      self.subtitleLabel2
    ].forEach {
      self.containerView.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.subtitleLabel1.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24.0)
      make.top.equalToSuperview().inset(20.0)
    }
    
    self.subtitleLabel2.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24.0)
      make.top.equalTo(self.subtitleLabel1.snp.bottom).offset(16.0)
    }
    
    self.containerView.snp.makeConstraints { make in
      make.bottom.directionalHorizontalEdges.equalToSuperview()
      make.top.equalTo(self.titleLabel.snp.bottom).offset(12.0)
      make.height.equalTo(152.0)
    }
    
    self.titleLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24.0)
      make.top.equalToSuperview()
    }
  }
}
