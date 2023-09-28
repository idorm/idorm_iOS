//
//  PostCell.swift
//  idorm
//
//  Created by 김응철 on 2023/01/10.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class CommunityPostingImageCell: BaseCollectionViewCell {
  
  // MARK: - UI Components
  
  private let removeButton: UIButton = {
    let button = UIButton()
    button.setImage(.iDormIcon(.remove), for: .normal)
    return button
  }()
  
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 10
    imageView.layer.masksToBounds = true
    imageView.contentMode = .scaleAspectFill
    return imageView
  }()
  
  // MARK: - Properties
  
  var removeButtonHandler: (() -> Void)?
  
  // MARK: - LifeCycle
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    self.imageView.image = nil
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    self.backgroundColor = .white
  }
  
  override func setupLayouts() {
    [
      self.imageView,
      self.removeButton
    ].forEach {
      self.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.imageView.snp.makeConstraints { make in
      make.bottom.leading.equalToSuperview()
      make.width.height.equalTo(80.0)
    }
    
    self.removeButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().offset(3.0)
      make.top.equalToSuperview().offset(-3.0)
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    self.removeButton.rx.tap.asDriver()
      .drive(with: self) { owner, _ in
        owner.removeButtonHandler?()
      }
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Configure
  
  func configure(with image: UIImage?) {
    self.imageView.image = image
  }
}
