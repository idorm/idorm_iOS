//
//  MyPageProfileCell.swift
//  idorm
//
//  Created by 김응철 on 9/29/23.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class ProfileMainCell: BaseCollectionViewCell {
  
  // MARK: - UI Components
  
  private let profileImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .iDormImage(.human)
    imageView.contentMode = .scaleAspectFill
    return imageView
  }()
  
  private let nicknameLabel: UILabel = {
    let label = UILabel()
    label.textColor = .white
    label.font = .iDormFont(.medium, size: 14.0)
    return label
  }()
  
  private let gearButton: UIButton = {
    let button = UIButton()
    button.setImage(.iDormIcon(.gear), for: .normal)
    return button
  }()
  
  // MARK: - Properties
  
  var gearButtonHandler: (() -> Void)?
  
  // MARK: - Setup
  
  override func setupStyles() {
    self.contentView.backgroundColor = .iDormColor(.iDormBlue)
    self.contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    self.contentView.layer.cornerRadius = 24.0
    self.contentView.layer.shadowOpacity = 0.11
    self.contentView.layer.shadowRadius = 2.0
    self.contentView.layer.shadowOffset = CGSize(width: .zero, height: 2.0)
  }
  
  override func setupLayouts() {
    [
      self.profileImageView,
      self.nicknameLabel,
      self.gearButton
    ].forEach {
      self.contentView.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.profileImageView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().inset(70.0)
    }
    
    self.nicknameLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.profileImageView.snp.bottom).offset(8.0)
    }
    
    self.gearButton.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(12.0)
      make.trailing.equalToSuperview().inset(24.0)
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    self.gearButton.rx.tap.asDriver()
      .drive(with: self) { owner, _ in
        owner.gearButtonHandler?()
      }
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Configure
  
  func configure(imageURL: String, nickname: String) {
    self.nicknameLabel.text = nickname
    ImageDownloader.downloadImage(from: imageURL) { image in
      self.profileImageView.image = image
    }
  }
}
