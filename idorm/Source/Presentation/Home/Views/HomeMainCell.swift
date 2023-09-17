//
//  HomeMainCell.swift
//  idorm
//
//  Created by 김응철 on 8/19/23.
//

import UIKit

import SnapKit

protocol HomeMainCellDelegate: AnyObject {
  func didTapStartMatchingButton()
}

final class HomeMainCell: UICollectionViewCell, BaseViewProtocol {
  
  // MARK: - UI Components
  
  /// 메인 `UILabel`
  private let mainLabel: UILabel = {
    let label = UILabel()
    let text = """
    2학기 룸메이트 매칭
    아이돔과 함께해요.
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
      range: (text as NSString).range(of: "2학기")
    )
    label.attributedText = attributedString
    return label
  }()
  
  /// `룸메이트 매칭 시작하기` 버튼
  private lazy var startMatchingButton: iDormButton = {
    let button = iDormButton("룸메이트 매칭 시작하기", image: .iDormIcon(.squareRight))
    button.baseBackgroundColor = .iDormColor(.iDormBlue)
    button.baseForegroundColor = .white
    button.imagePadding = 12.0
    button.imagePlacement = .trailing
    button.shadowOpacity = 0.12
    button.shadowRadius = 3.0
    button.font = .iDormFont(.medium, size: 16.0)
    button.shadowOffset = CGSize(width: 0, height: 4)
    button.addTarget(
      self,
      action: #selector(self.didTapStartMatchingButton),
      for: .touchUpInside
    )
    return button
  }()
  
  /// 아이돔의 마스코트 캐릭터가 그려져 있는 `UIImageView`
  private let domiImageView = UIImageView(image: .iDormIcon(.domi))
  
  // MARK: - Properties
  
  weak var delegate: HomeMainCellDelegate?
  
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
    [
      self.mainLabel,
      self.domiImageView,
      self.startMatchingButton
    ].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.mainLabel.snp.makeConstraints { make in
      make.top.leading.equalToSuperview()
    }
    
    self.domiImageView.snp.makeConstraints { make in
      make.trailing.equalToSuperview()
      make.top.equalTo(self.mainLabel.snp.bottom).offset(-12.0)
    }
    
    self.startMatchingButton.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview()
      make.bottom.equalTo(self.domiImageView.snp.bottom).offset(-11.0)
      make.bottom.equalToSuperview().inset(53.0)
      make.height.equalTo(52.0)
    }
  }
  
  // MARK: - Selectors
  
  @objc
  private func didTapStartMatchingButton() {
    self.delegate?.didTapStartMatchingButton()
  }
}
