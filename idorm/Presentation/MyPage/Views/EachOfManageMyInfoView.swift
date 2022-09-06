//
//  EachOfManageMyInfoView.swift
//  idorm
//
//  Created by 김응철 on 2022/08/30.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

enum EachOfManageMyInfoViewType {
  case onlyArrow
  case onlyDescription(description: String)
  case both(description: String)
}

class EachOfManageMyInfoView: UIView {
  // MARK: - Properties
  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = .init(name: Font.regular.rawValue, size: 16)
    label.textColor = .idorm_gray_400
    
    return label
  }()
  
  lazy var descriptionLabel: UILabel = {
    let label = UILabel()
    label.font = .init(name: Font.regular.rawValue, size: 16)
    label.textColor = .idorm_gray_300
    
    return label
  }()
  
  lazy var arrowImageView = UIImageView(image: UIImage(named: "rightArrow"))
  
  let type: EachOfManageMyInfoViewType
  
  // MARK: - Init
  init(type: EachOfManageMyInfoViewType, title: String) {
    self.type = type
    super.init(frame: .zero)
    configureUI()
    self.titleLabel.text = title
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Helpers
  func configureUI() {
    backgroundColor = .white
    addSubview(titleLabel)
    
    titleLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview().inset(24)
    }
    
    switch type {
    case .onlyArrow:
      addSubview(arrowImageView)
      
      arrowImageView.snp.makeConstraints { make in
        make.centerY.equalToSuperview()
        make.trailing.equalToSuperview().inset(24)
      }
    case .onlyDescription(let description):
      descriptionLabel.text = description
      addSubview(descriptionLabel)
      
      descriptionLabel.snp.makeConstraints { make in
        make.centerY.equalToSuperview()
        make.trailing.equalToSuperview().inset(24)
      }
    case .both(let description):
      descriptionLabel.text = description
      addSubview(arrowImageView)
      addSubview(descriptionLabel)
      
      arrowImageView.snp.makeConstraints { make in
        make.centerY.equalToSuperview()
        make.trailing.equalToSuperview().inset(24)
      }
      
      descriptionLabel.snp.makeConstraints { make in
        make.centerY.equalToSuperview()
        make.trailing.equalTo(arrowImageView.snp.leading).offset(-24)
      }
    }
  }
}
