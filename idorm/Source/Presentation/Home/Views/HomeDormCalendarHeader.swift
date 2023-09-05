//
//  HomeHeader.swift
//  idorm
//
//  Created by 김응철 on 8/20/23.
//

import UIKit

import SnapKit

final class HomeDormCalendarHeader: UICollectionReusableView, BaseView {
  
  // MARK: - UI Components
  
  /// 메인 `UILabel`
  private let mainLabel: UILabel = {
    let label = UILabel()
    let text = """
    인천대 기숙사 일정
    아이돔에서 함께해요.
    """
    label.textColor = .iDormColor(.iDormGray400)
    label.numberOfLines = 2
    label.font = .iDormFont(.medium, size: 20.0)
    let attributedString = NSMutableAttributedString(string: text)
    attributedString.addAttributes(
      [
        .foregroundColor: UIColor.iDormColor(.iDormBlue),
        .font: UIFont.iDormFont(.bold, size: 20.0)
      ],
      range: (text as NSString).range(of: "기숙사 일정")
    )
    label.attributedText = attributedString
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
    self.addSubview(self.mainLabel)
  }
  
  func setupConstraints() {
    self.mainLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(32.0)
      make.leading.equalToSuperview()
    }
  }
}
