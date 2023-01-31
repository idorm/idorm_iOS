//
//  ManageMyInfoView.swift
//  idorm
//
//  Created by 김응철 on 2022/12/22.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

final class ManageMyInfoView: UIView {
  
  enum ManageMyInfoViewType {
    case onlyArrow(title: String)
    case onlyDescription(description: String = "", title: String)
    case both(description: String = "", title: String)
  }
  
  // MARK: - Properties
  
  private let titleLabel = UILabel().then {
    $0.font = .init(name: MyFonts.regular.rawValue, size: 16)
    $0.textColor = .idorm_gray_400
  }
  
  let descriptionLabel = UILabel().then {
    $0.font = .init(name: MyFonts.regular.rawValue, size: 16)
    $0.textColor = .idorm_gray_300
  }
  
  private let arrowImageView = UIImageView(image: #imageLiteral(resourceName: "rightarrow_gray"))
  private let type: ManageMyInfoViewType
  
  // MARK: - LifeCycle
  
  init(_ type: ManageMyInfoViewType) {
    self.type = type
    super.init(frame: .zero)
    setupComponents(type)
    setupStyles()
    setupLayout()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  private func setupComponents(_ type: ManageMyInfoViewType) {
    switch type {
    case .onlyArrow(let title):
      titleLabel.text = title
      
    case let .onlyDescription(description, title):
      descriptionLabel.text = description
      titleLabel.text = title
      
    case let .both(description, title):
      descriptionLabel.text = description
      titleLabel.text = title
    }
  }
  
  private func setupStyles() {
    backgroundColor = .white
  }
  
  private func setupLayout() {
    addSubview(titleLabel)
    switch type {
    case .onlyArrow:
      addSubview(arrowImageView)
    case .onlyDescription:
      addSubview(descriptionLabel)
    case .both:
      addSubview(arrowImageView)
      addSubview(descriptionLabel)
    }
  }
  
  private func setupConstraints() {
    titleLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview().inset(24)
    }
    
    switch type {
    case .onlyArrow:
      arrowImageView.snp.makeConstraints { make in
        make.centerY.equalToSuperview()
        make.trailing.equalToSuperview().inset(24)
      }
    case .onlyDescription:
      descriptionLabel.snp.makeConstraints { make in
        make.centerY.equalToSuperview()
        make.trailing.equalToSuperview().inset(24)
      }
    case .both:
      arrowImageView.snp.makeConstraints { make in
        make.centerY.equalToSuperview()
        make.trailing.equalToSuperview().inset(24)
      }
      
      descriptionLabel.snp.makeConstraints { make in
        make.centerY.equalToSuperview()
        make.trailing.equalTo(arrowImageView.snp.leading).offset(-12)
      }
    }
  }
}
