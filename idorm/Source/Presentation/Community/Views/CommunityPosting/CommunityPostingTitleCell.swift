//
//  CommunityPostingTitleCell.swift
//  idorm
//
//  Created by 김응철 on 9/28/23.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class CommunityPostingTitleCell: BaseCollectionViewCell {
  
  // MARK: - UI Components
  
  private let titleTextField: iDormTextField = {
    let textField = iDormTextField(type: .custom)
    textField.backgroundColor = .white
    textField.font = .iDormFont(.bold, size: 20.0)
    textField.placeHolderFont = .iDormFont(.bold, size: 20.0)
    textField.placeHolderColor = .iDormColor(.iDormGray200)
    textField.textColor = .black
    textField.placeHolder = "제목"
    return textField
  }()
  
  private let lineView: UIView = {
    let view = UIView()
    view.backgroundColor = .iDormColor(.iDormGray200)
    return view
  }()
  
  // MARK: - Properties
  
  var textFieldHandler: ((String) -> Void)?
  
  // MARK: - Setup
  
  override func setupStyles() {
    self.backgroundColor = .white
  }
  
  override func setupLayouts() {
    [
      self.titleTextField,
      self.lineView
    ].forEach {
      self.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.titleTextField.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview()
      make.top.equalToSuperview().inset(30.0)
    }
    
    self.lineView.snp.makeConstraints { make in
      make.bottom.directionalHorizontalEdges.equalToSuperview()
      make.top.equalTo(self.titleTextField.snp.bottom).offset(12.0)
      make.height.equalTo(1.0)
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    self.titleTextField.rx.text.asDriver()
      .drive(with: self) { owner, text in
        owner.textFieldHandler?(text)
      }
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Configure
  
  func configure(with title: String) {
    self.titleTextField.text = title
  }
}
