//
//  BaseReusableView.swift
//  idorm
//
//  Created by 김응철 on 9/29/23.
//

import UIKit

import RxSwift
import RxCocoa
import Reusable

class BaseReusableView: UICollectionReusableView, Reusable, BaseViewProtocol {
  
  // MARK: - Properties
  
  var disposeBag = DisposeBag()
  
  // MARK: - Initializer
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
    self.bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  func setupStyles() {}
  
  func setupLayouts() {}
  
  func setupConstraints() {}
  
  // MARK: - Bind
  
  func bind() {}
}
