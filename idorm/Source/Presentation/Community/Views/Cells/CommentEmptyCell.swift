//
//  CommentEmptyCell.swift
//  idorm
//
//  Created by 김응철 on 2023/01/26.
//

import UIKit

import SnapKit

final class CommentEmptyCell: UITableViewCell {
  
  // MARK: - Properties
  
  static let identifier = "CommentEmptyCell"
  
  private let mainImageView = UIImageView(image: UIImage(named: "text_emptyComment"))
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupStyles()
    setupLayouts()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension CommentEmptyCell: BaseView {
  func setupStyles() {
    contentView.backgroundColor = .white
  }
  
  func setupLayouts() {
    contentView.addSubview(mainImageView)
  }
  
  func setupConstraints() {
    mainImageView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
}
