//
//  CommunityDetailHeaderCollectionViewCell.swift
//  idorm
//
//  Created by 김응철 on 2022/07/21.
//

import UIKit
import SnapKit

class CommunityDetailHeaderCollectionViewCell: UICollectionViewCell {
  static let identifier = "CommunityDetailHeaderCollectionViewCell"
  
  func configureUI() {
    contentView.layer.cornerRadius = 8
    contentView.layer.masksToBounds = true
    contentView.backgroundColor = .idorm_blue
  }
}
