//
//  ManagementAccountVC.swift
//  idorm
//
//  Created by 김응철 on 9/30/23.
//

import UIKit

import SnapKit

final class ManagementAccountViewController: BaseViewController {
  
  // MARK: - UI Components
  
  private let scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    return scrollView
  }()
  
  private let containerView: UIView = {
    let view = UIView()
    return view
  }()
  
  private let bottomMenuView: iDormBottomMenuView = {
    let view = iDormBottomMenuView()
    view.updateTitle(left: "다시 생각해볼래요❤", right: "탈퇴")
    return view
  }()
  
  private let domiImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .iDormImage(.domi_sad)
    return imageView
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.text = "idorm과 이별을 원하시나요?\n너무 슬퍼요 😥"
    label.font = .iDormFont(.medium, size: 20.0)
    label.textColor = .black
    label.numberOfLines = 2
    return label
  }()
  
  private let notifiyView = ManagementAccountNotifyView()
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    self.navigationItem.title = "회원 탈퇴"
    self.view.backgroundColor = .white
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    self.view.addSubview(self.scrollView)
    self.view.addSubview(self.bottomMenuView)
    self.scrollView.addSubview(self.containerView)
    [
      self.titleLabel,
      self.domiImageView,
      self.notifiyView,
    ].forEach {
      self.containerView.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.scrollView.snp.makeConstraints { make in
      make.top.directionalHorizontalEdges.equalToSuperview()
      make.bottom.equalTo(self.bottomMenuView.snp.top)
    }
    
    self.containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalTo(self.view.frame.width)
    }
    
    self.titleLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24.0)
      make.top.equalToSuperview().inset(36.0)
    }
    
    self.domiImageView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.titleLabel.snp.bottom).offset(36.0)
    }
    
    self.notifiyView.snp.makeConstraints { make in
      make.top.equalTo(self.domiImageView.snp.bottom).offset(36.0)
      make.directionalHorizontalEdges.equalToSuperview()
      make.bottom.equalToSuperview().inset(24.0)
    }
    
    self.bottomMenuView.snp.makeConstraints { make in
      make.bottom.directionalHorizontalEdges.equalTo(self.view.safeAreaLayoutGuide)
    }
  }
}
