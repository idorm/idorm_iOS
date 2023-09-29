//
//  ManagementMyInfoProfileCell.swift
//  idorm
//
//  Created by 김응철 on 9/29/23.
//

import UIKit

import SnapKit
import RxSwift
import RxGesture

final class ManagementMyInfoProfileCell: BaseCollectionViewCell {
  
  // MARK: - UI Components
  
  private let profileImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .iDormImage(.human)
    imageView.contentMode = .scaleToFill
    imageView.layer.cornerRadius = 12
    imageView.layer.masksToBounds = true
    return imageView
  }()
  
  // MARK: - Properties
  
  var profileTapHandler: (() -> Void)?
  
  // MARK: - Setup
  
  override func setupLayouts() {
    super.setupLayouts()
    
    self.addSubview(self.profileImageView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.profileImageView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().inset(24.0)
      make.size.equalTo(68.0)
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    self.profileImageView.rx.tapGesture()
      .when(.recognized)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        owner.profileTapHandler?()
      }
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Configure
  
  func configure(with url: String?) {
    if let url = url {
      ImageDownloader.downloadImage(from: url) { [weak self] in
        self?.profileImageView.image = $0
      }
    } else {
      self.profileImageView.image = .iDormImage(.human)
    }
  }
}
