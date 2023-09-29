//
//  ManagementMatchingCardCell.swift
//  idorm
//
//  Created by 김응철 on 9/29/23.
//

import UIKit

import SnapKit

final class ManagementMatchingCardCell: BaseCollectionViewCell {
  
  // MARK: - UI Components
  
  private var matchingCardView: iDormMatchingCardView!
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    self.contentView.layer.shadowOpacity = 0.11
    self.contentView.layer.shadowRadius = 2.0
    self.layer.shadowOffset = CGSize(width: .zero, height: 1.0)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    self.addSubview(self.matchingCardView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.matchingCardView.snp.makeConstraints { make in
      make.top.directionalHorizontalEdges.equalToSuperview().inset(24.0)
    }
  }
  
  // MARK: - Configure
  
  func configure(with matchingInfo: MatchingInfo) {
    self.matchingCardView = iDormMatchingCardView(matchingInfo)
  }
}
