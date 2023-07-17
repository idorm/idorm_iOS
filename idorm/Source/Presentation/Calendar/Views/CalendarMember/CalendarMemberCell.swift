//
//  CalendarMemberCell.swift
//  idorm
//
//  Created by 김응철 on 7/13/23.
//

import UIKit

import SnapKit
import Kingfisher

/// 멤버의 프로필사진과 닉네임이  노출되는 `Cell`입니다.
final class CalendarMemberCell: UICollectionViewCell, BaseView {
  
  private enum Metric {
    static let imageViewSize: CGFloat = 48.0
    static let imageViewBorderWidth: CGFloat = 3.0
  }
  
  // MARK: - Properties
  
  // MARK: - UI Components
  
  private let profileImageView: UIImageView = {
    let iv = UIImageView()
    iv.layer.cornerRadius = Metric.imageViewSize / 2
    iv.layer.borderWidth = Metric.imageViewBorderWidth
    iv.backgroundColor = .iDormColor(.iDormBlue)
    return iv
  }()
  
  private let nicknameLabel: UILabel = {
    let lb = UILabel()
    lb.font = .idormFont(.regular, size: 10)
    lb.textColor = .iDormColor(.iDormGray400)
    lb.numberOfLines = 2
    lb.textAlignment = .center
    return lb
  }()
  
  // MARK: - Life Cycle
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }
  
  // MARK: - Setup
  
  func setupStyles() {
    self.contentView.backgroundColor = .clear
  }
  
  func setupLayouts() {
    [
      self.profileImageView,
      self.nicknameLabel
    ].forEach {
      self.contentView.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.profileImageView.snp.makeConstraints { make in
      make.top.directionalHorizontalEdges.equalToSuperview()
      make.width.height.equalTo(Metric.imageViewSize)
    }
    
    self.nicknameLabel.snp.makeConstraints { make in
      make.top.equalTo(self.profileImageView.snp.bottom).offset(8)
      make.directionalHorizontalEdges.equalToSuperview()
    }
  }
  
  // MARK: - Fucntions
  
  /// 셀의 UI에 데이터를 주입합니다.
  ///
  /// - Parameters:
  ///   - teamMember: 팀 멤버의 기본적인 정보를 제공합니다.
  func configure(_ teamMember: TeamMember) {
//    guard let url = URL(string: teamMember.profilePhotoUrl) else { return }
//    self.profileImageView.kf.setImage(with: url)
    self.nicknameLabel.text = teamMember.nickname
  }
}
