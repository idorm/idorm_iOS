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
  
  /// 프로필 이미지 테두리 색상을 변경합니다.
  private var borderColor: CGColor? = UIColor.iDormColor(.firstUser).cgColor {
    willSet {
      self.profileImageView.layer.borderColor = newValue
    }
  }
  
  // MARK: - UI Components
  
  private lazy var profileImageView: UIImageView = {
    let iv = UIImageView()
    iv.layer.cornerRadius = Metric.imageViewSize / 2
    iv.layer.borderWidth = Metric.imageViewBorderWidth
    iv.layer.borderColor = self.borderColor
    iv.contentMode = .scaleAspectFit
    iv.layer.masksToBounds = true
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
    if let urlString = teamMember.profilePhotoUrl {
      self.profileImageView.kf.setImage(with: URL(string: urlString)!)
    }
    self.nicknameLabel.text = teamMember.nickname
    
    switch teamMember.order {
    case 0:
      self.borderColor = UIColor.iDormColor(.firstUser).cgColor
    case 1:
      self.borderColor = UIColor.iDormColor(.secondUser).cgColor
    case 2:
      self.borderColor = UIColor.iDormColor(.thirdUser).cgColor
    case 3:
      self.borderColor = UIColor.iDormColor(.fourthUser).cgColor
    default:
      self.borderColor = UIColor.iDormColor(.firstUser).cgColor
    }
  }
}
