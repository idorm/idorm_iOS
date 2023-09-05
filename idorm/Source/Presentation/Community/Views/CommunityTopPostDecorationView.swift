//
//  CommunityTopPostDecorationView.swift
//  idorm
//
//  Created by 김응철 on 8/20/23.
//

import UIKit

final class CommunityTopPostsBackgroundView: UICollectionReusableView {
  
  // MARK: - Initializer
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  private func setupStyles() {
    self.backgroundColor = .iDormColor(.iDormGray100)
  }
}
