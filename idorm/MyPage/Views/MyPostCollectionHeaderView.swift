//
//  MyPostCollectionHeaderView.swift
//  idorm
//
//  4Created by 김응철 on 2022/07/30.
//

import SnapKit
import UIKit
import RxSwift
import RxCocoa

class MyPostCollectionHeaderView: UICollectionReusableView {
  // MARK: - Properties
  lazy var lastSortedButton = createBasicButton(title: "최신순")
  lazy var pastSortedButton = createBasicButton(title: "과거순")
  
  static let identifier = "MyPostCollectionHeaderView"
  let disposeBag = DisposeBag()
  
  // MARK: - Bind
  private func bind() {
    lastSortedButton.rx.tap
      .bind(onNext: { [weak self] in
        self?.lastSortedButton.isSelected = true
        self?.pastSortedButton.isSelected = false
      })
      .disposed(by: disposeBag)
    
    pastSortedButton.rx.tap
      .bind(onNext: { [weak self] in
        self?.lastSortedButton.isSelected = false
        self?.pastSortedButton.isSelected = true
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: - Helpers
  func configureUI() {
    bind()
    backgroundColor = .idorm_gray_100
    
    [ lastSortedButton, pastSortedButton ]
      .forEach { addSubview($0) }
    
    lastSortedButton.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.centerY.equalToSuperview()
    }

    pastSortedButton.snp.makeConstraints { make in
      make.leading.equalTo(lastSortedButton.snp.trailing).offset(20)
      make.centerY.equalToSuperview()
    }
  }
}

extension MyPostCollectionHeaderView {
  private func createBasicButton(title: String) -> UIButton {
    var config = UIButton.Configuration.plain()
    config.image = UIImage(named: "myPostButton")
    config.imagePlacement = .trailing
    config.imagePadding = 8
    var container = AttributeContainer()
    container.foregroundColor = UIColor.black
    container.font = .init(name: Font.regular.rawValue, size: 14)
    config.attributedTitle = AttributedString(title, attributes: container)
    config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    let button = UIButton(configuration: config)
    
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      switch button.state {
      case .selected:
        button.configuration?.image = UIImage(named: "myPostButton_Hover")
        button.configuration?.baseBackgroundColor = .white
      default:
        button.configuration?.image = UIImage(named: "myPostButton")
        button.configuration?.baseBackgroundColor = .white
      }
    }
    button.configurationUpdateHandler = handler
    
    return button
  }
}
