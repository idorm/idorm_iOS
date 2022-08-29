//
//  ManageMyInfoTableViewCell.swift
//  idorm
//
//  Created by 김응철 on 2022/08/29.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

enum ManageMyInfoTableViewCellType {
  
}

class ManageMyInfoTableViewCell: UITableViewCell {
  // MARK: - Properties
  lazy var titleLabel: UILabel = {
    let lb = UILabel()
    lb.font = .init(name: Font.regular.rawValue, size: 16)
    lb.textColor = .idorm_gray_400
    
    return lb
  }()
  
  lazy var arrowButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.image = UIImage(named: "rightArrow")
    let button = UIButton(configuration: config)
    
    return button
  }()
  
  let disposeBag = DisposeBag()
  
  // MARK: - Helpers
  func configureUI(type: ManageMyInfoTableViewCellType) {
    
  }
}

