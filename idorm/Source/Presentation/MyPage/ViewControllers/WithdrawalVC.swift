import UIKit

import SnapKit
import Then

final class WithdrawalViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let scrollView = UIScrollView()
  private let contentView = UIView()
  private let sadDomiImageView = UIImageView(image: #imageLiteral(resourceName: "sadDomi"))
  private let floatyBottomView = FloatyBottomView(.withdrawal)
  
  private let mainLabel = UILabel().then {
    $0.text = """
              idorm과 이별을 원하시나요?
              너무 슬퍼요 😥
              """
    $0.numberOfLines = 0
    $0.font = .init(name: MyFonts.medium.rawValue, size: 20)
  }
  
  private let mainLabel2 = UILabel().then {
    $0.text = "idorm 탈퇴 전 알아두셔야 해요!"
    $0.font = .init(name: MyFonts.medium.rawValue, size: 20)
  }
  
  private let descriptionLabel = UILabel().then {
    $0.text = """
              📌 idorm 탈퇴 후에도 커뮤니티 내에는
              작성하신 글과 댓글은 남아 있어요.
              """
    $0.numberOfLines = 2
    $0.font = .init(name: MyFonts.regular.rawValue, size: 16)
    $0.textColor = .idorm_gray_400
  }
  
  private let descriptionLabel2 = UILabel().then {
    $0.text = """
              📌 프로필과 내 정보 데이터가 사라지며
              다시 복구할 수 없어요.
              """
    $0.numberOfLines = 2
    $0.font = .init(name: MyFonts.regular.rawValue, size: 16)
    $0.textColor = .idorm_gray_400
  }

  private let descriptionLabel3 = UILabel().then {
    $0.text = """
              📌 그 밖 수정사항들
              """
    $0.font = .init(name: MyFonts.regular.rawValue, size: 16)
    $0.textColor = .idorm_gray_400
  }
  
  private lazy var descriptionLabelStack = UIStackView(
    arrangedSubviews: [
      descriptionLabel, descriptionLabel2, descriptionLabel3
    ]).then {
      $0.axis = .vertical
      $0.spacing = 16
  }
  
  private let descriptionBackgroundView = UIView().then {
    $0.backgroundColor = .idorm_gray_100
  }
    
  // MARK: - LifeCycle
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    navigationItem.title = "회원탈퇴"
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    view.addSubview(scrollView)
    view.addSubview(floatyBottomView)
    scrollView.addSubview(contentView)
    
    [mainLabel, sadDomiImageView, mainLabel2, descriptionBackgroundView, descriptionLabelStack]
      .forEach { contentView.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    scrollView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
      make.bottom.equalTo(floatyBottomView.snp.top)
    }
    
    floatyBottomView.snp.makeConstraints { make in
      make.leading.trailing.bottom.equalToSuperview()
      make.height.equalTo(76)
    }
    
    contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalTo(view.frame.width)
    }
    
    mainLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalToSuperview().inset(36)
    }
    
    sadDomiImageView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(mainLabel.snp.bottom).offset(36)
    }
    
    mainLabel2.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalTo(sadDomiImageView.snp.bottom).offset(24)
    }
    
    descriptionLabelStack.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalTo(mainLabel2.snp.bottom).offset(32)
    }
    
    descriptionBackgroundView.snp.makeConstraints { make in
      make.top.equalTo(mainLabel2.snp.bottom).offset(12)
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(192)
      make.bottom.equalToSuperview()
    }
  }
}

// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct WithdrawalVC_PreView: PreviewProvider {
  static var previews: some View {
    WithdrawalViewController().toPreview()
  }
}
#endif

