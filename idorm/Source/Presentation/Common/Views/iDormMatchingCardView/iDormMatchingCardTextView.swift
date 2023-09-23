//
//  iDormMatchingCardTextView.swift
//  idorm
//
//  Created by 김응철 on 9/23/23.
//

import UIKit

import SnapKit

final class iDormMatchingCardTextView: BaseView {
  
  // MARK: - UI Components
  
  /// 메인이되는 `UILabel`
  private let contentsLabel: UILabel = {
    let label = UILabel()
    label.textColor = .iDormColor(.iDormGray400)
    label.font = .iDormFont(.medium, size: 14.0)
    label.textAlignment = .left
    return label
  }()
  
  // MARK: - Initializer
  
  init(_ wishText: String) {
    self.contentsLabel.text = wishText
    super.init(frame: .zero)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    self.backgroundColor = .white
    self.layer.cornerRadius = 6.0
  }
  
  override func setupLayouts() {
    self.addSubview(self.contentsLabel)
  }
  
  override func setupConstraints() {
    self.contentsLabel.snp.makeConstraints { make in
      make.top.directionalHorizontalEdges.equalToSuperview().inset(10.0)
    }
  }
}
