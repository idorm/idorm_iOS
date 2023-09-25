//
//  MatchingMateQuotationView.swift
//  idorm
//
//  Created by 김응철 on 9/23/23.
//

import UIKit

import SnapKit

final class MatchingMateQuotationView: BaseView {
  
  enum ViewType {
    case noMatchingInfo
    case noPublic
    case noCard
    
    var title: String {
      switch self {
      case .noCard: 
        """
        더 볼 수 있는 매칭 이미지가 없어요.
        필터를 새롭게 조정해보세요.
        """
      case .noMatchingInfo:
        """
        룸메이트 매칭을 위해
        우선 마이페이지에서 프로필 이미지를 만들어 주세요.
        """
      case .noPublic:
        """
        룸메이트 매칭을 위해
        마이페이지에서 내 매칭 이미지 공개를 허용해 주세요.
        """
      }
    }
  }
  
  // MARK: - UI Components
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .iDormFont(.regular, size: 12.0)
    label.textColor = .iDormColor(.iDormGray400)
    label.numberOfLines = 2
    label.textAlignment = .center
    return label
  }()
  
  private let leftQuotationImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .iDormIcon(.left_quotation_marks)
    return imageView
  }()
  
  private let rightQuotationImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .iDormIcon(.right_quotation_marks)
    return imageView
  }()
  
  // MARK: - Setup
  
  override func setupStyles() {
    self.backgroundColor = .clear
  }
  
  override func setupLayouts() {
    [
      self.titleLabel,
      self.leftQuotationImageView,
      self.rightQuotationImageView
    ].forEach {
      self.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.titleLabel.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    self.leftQuotationImageView.snp.makeConstraints { make in
      make.leading.equalTo(self.titleLabel.snp.leading)
      make.bottom.equalTo(self.titleLabel.snp.top)
    }
    
    self.rightQuotationImageView.snp.makeConstraints { make in
      make.trailing.equalTo(self.titleLabel.snp.trailing)
      make.bottom.equalTo(self.titleLabel.snp.top)
    }
  }
  
  // MARK: - Functions
  
  func updateTitle(_ viewType: ViewType) {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = 4.0
    paragraphStyle.alignment = .center
    self.titleLabel.attributedText = NSMutableAttributedString(
      string: viewType.title,
      attributes: [.paragraphStyle: paragraphStyle]
    )
    
  }
}
