//
//  LoadingCell.swift
//  idorm
//
//  Created by 김응철 on 2023/01/14.
//

import UIKit

import SnapKit

final class LoadingCell: UICollectionViewCell {

  // MARK: - Properties

  static let id = "LoadingCell"

  let indicator = UIActivityIndicatorView()

  // MARK: - LifeCycle

  override init(frame: CGRect) {
    super.init(frame: .zero)
    setupStyles()
    setupLayout()
    setupConstraints()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Setup

  private func setupLayout() {
    contentView.addSubview(indicator)
    indicator.color = .darkGray
  }

  private func setupConstraints() {
    indicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }

  private func setupStyles() {
    indicator.startAnimating()
  }
}
