//
//  iDormFloatyButton.swift
//  idorm
//
//  Created by 김응철 on 7/26/23.
//

import UIKit

import SnapKit

/// `UIButton.Configuration`의 `Custom`의 용이를 위한 객체
final class iDormButton: UIButton, BaseView {
  
  // MARK: - UI Components
  
  private let bottomBorderLine: UIView = {
    let view = UIView()
    view.backgroundColor = .black
    view.isHidden = true
    return view
  }()
  
  // MARK: - Properties
  
  /// 버튼의 왼쪽에 위치해 있는 `UIImage?`
  private let image: UIImage?
  
  /// 버튼의 타이틀 `String`
  var title: String = "" {
    willSet {
      self.configuration?.attributedTitle = AttributedString(
        newValue,
        attributes: .init([.font: self.font])
      )
    }
  }
  
  /// 버튼의 `CornerRadius`
  var cornerRadius: CGFloat = 0 {
    willSet { self.configuration?.background.cornerRadius = newValue }
  }
  
  /// 버튼의 `UIFont`
  var font: UIFont = .iDormFont(.medium, size: 14.0) {
    willSet { self.configuration?.attributedTitle?.font = newValue }
  }
  
  /// 버튼의 `BackgroundColor`
  var baseBackgroundColor: UIColor? {
    willSet { self.configuration?.baseBackgroundColor = newValue }
  }
  
  /// 버튼의 `ForegroundColor`
  var baseForegroundColor: UIColor? {
    willSet { self.configuration?.baseForegroundColor = newValue }
  }
  
  /// 버튼의 `EdgeInset`
  var edgeInsets: NSDirectionalEdgeInsets = .zero {
    willSet { self.configuration?.contentInsets = newValue }
  }
  
  /// 버튼의 `ShadowOpacity`
  var shadowOpacity: Float = 0 {
    willSet { self.layer.shadowOpacity = newValue }
  }
  
  /// 버튼의 `ShadowRadius`
  var shadowRadius: CGFloat = 0 {
    willSet { self.layer.shadowRadius = newValue }
  }
  
  /// 버튼의 `ShadowOffset`
  var shadowOffset: CGSize = .zero {
    willSet { self.layer.shadowOffset = newValue }
  }
  
  /// 버튼의 `SubTitle`
  var subTitle: String = "" {
    willSet {
      self.configuration?.attributedSubtitle = AttributedString(
        newValue,
        attributes: .init([
          .font: self.subTitleFont,
          .foregroundColor: self.subTitleColor
        ])
      )
    }
  }
  
  /// 버튼의 `SubTitleFont`
  var subTitleFont: UIFont? {
    willSet { self.configuration?.attributedSubtitle?.font = newValue }
  }
  
  /// 버튼의 `SubTitleColor`
  var subTitleColor: UIColor? {
    willSet { self.configuration?.attributedSubtitle?.foregroundColor = newValue }
  }
  
  /// 버튼의 `title`과 `subTitle`사이의 `Padding`
  var titlePadding: CGFloat = 0 {
    willSet { self.configuration?.titlePadding = newValue }
  }
  
  /// 버튼의 `contentInset`
  var contentInset: NSDirectionalEdgeInsets = .zero {
    willSet { self.configuration?.contentInsets = newValue }
  }
  
  /// 버튼의 `BottomBorderLine`
  var isHiddenBottomBorderLine: Bool = true {
    willSet { self.bottomBorderLine.isHidden = newValue }
  }
  
  override var isSelected: Bool {
     willSet {
       self.bottomBorderLine.backgroundColor = newValue ? .black : .iDormColor(.iDormGray200)
    }
  }
  
  // MARK: - Init
  
  init(_ title: String, image: UIImage?) {
    self.title = title
    self.image = image
    super.init(frame: .zero)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
    self.setupConfiguration()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  func setupStyles() {
    self.baseBackgroundColor = .white
  }
  
  func setupLayouts() {
    [
      self.bottomBorderLine
    ].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.bottomBorderLine.snp.makeConstraints { make in
      make.bottom.directionalHorizontalEdges.equalToSuperview()
      make.height.equalTo(1.0)
    }
  }
  
  /// 사용자의 정보를 토대로 `Configuration`을 업데이트합니다.
  private func setupConfiguration() {
    var config = UIButton.Configuration.filled()
    config.attributedTitle = AttributedString(self.title)
    config.image = self.image
    config.imagePlacement = .leading
    config.imagePadding = 6.0
    self.configuration = config
  }
}
