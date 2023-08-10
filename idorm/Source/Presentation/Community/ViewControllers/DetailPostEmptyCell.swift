//
//  CommentEmptyCell.swift
//  idorm
//
//  Created by 김응철 on 2023/01/26.
//

import UIKit

import SnapKit

/// 게시글의 댓글이 아무것도 없을 때 나타나는 `UICollectionViewCell`
final class CommunityPostEmptyCell: UICollectionViewCell, BaseView {
  
  // MARK: - UI Components
  
  /// `ic_speechBubble`의 `UIImageView`
  private let speechBubbleImageView: UIImageView = {
    let imageView = UIImageView()
    let image: UIImage? = .iDormIcon(.speechBubble)?
      .resize(newSize: 45.0)?
      .withTintColor(.iDormColor(.iDormGray300))
    imageView.image = image
    return imageView
  }()
  
  /// 사용자에게 정보를 주는 `UILabel`
  private let infoLabel: UILabel = {
    let label = UILabel()
    label.text = """
    아직 등록된 댓글이 없어요.
    첫 댓글을 남겨주세요.
    """
    label.textColor = .iDormColor(.iDormGray200)
    label.font = .iDormFont(.regular, size: 14.0)
    return label
  }()
  
  // MARK: - Initializer
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  func setupStyles() {}
  
  func setupLayouts() {
    [
      self.speechBubbleImageView,
      self.infoLabel
    ].forEach {
      self.contentView.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.speechBubbleImageView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().inset(23.0)
    }
    
    self.infoLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.speechBubbleImageView.snp.bottom).offset(10.0)
    }
  }
}
