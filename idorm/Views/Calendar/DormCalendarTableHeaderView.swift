//
//  DormCalendarCollectionHeaderView.swift
//  idorm
//
//  Created by 김응철 on 2022/07/27.
//

import SnapKit
import UIKit
import RxSwift
import RxCocoa

class DormCalendarTableHeaderView: UITableViewHeaderFooterView {
  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.text = "기숙사 공식 일정"
    label.font = .init(name: Font.regular.rawValue, size: 12)
    label.textColor = .idorm_gray_400
    
    return label
  }()
  
  static let identifier = "DormCalendarTableHeaderView"
  
  // MARK: - LifeCycle
  
  // MARK: - Helpers
  func configureUI() {
    [ titleLabel ]
      .forEach { addSubview($0) }
    
    titleLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.top.equalToSuperview().inset(14)
    }
  }
}
