//
//  PopupViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/10.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class PopupViewController: BaseViewController {
  // MARK: - Properties
  let contents: String
  
  lazy var infoView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.clipsToBounds = true
    view.layer.cornerRadius = 12
    
    return view
  }()
  
  lazy var contentsLabel: UILabel = {
    let label = UILabel()
    label.textColor = .black
    label.font = .init(name: MyFonts.medium.rawValue, size: 14.0)
    
    return label
  }()
  
  lazy var confirmButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setTitle("확인", for: .normal)
    button.setTitleColor(UIColor.idorm_blue, for: .normal)
    button.titleLabel?.font = .init(name: MyFonts.medium.rawValue, size: 14.0)
    
    return button
  }()
  
  // MARK: - LifeCycle
  
  init(contents: String) {
    self.contents = contents
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    contentsLabel.text = contents
    view.backgroundColor = .black.withAlphaComponent(0.5)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    view.addSubview(infoView)
    
    [ contentsLabel, confirmButton ]
      .forEach { infoView.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    infoView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(32)
      make.centerY.equalToSuperview().offset(-50)
      make.height.equalTo(130)
    }
    
    contentsLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(16)
      make.top.equalToSuperview().inset(24)
    }
    
    confirmButton.snp.makeConstraints { make in
      make.trailing.bottom.equalToSuperview().inset(16)
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    // 확인 버튼 클릭 이벤트
    confirmButton.rx.tap
      .bind(onNext: { [weak self] in
        self?.dismiss(animated: false)
      })
      .disposed(by: disposeBag)
  }
}
