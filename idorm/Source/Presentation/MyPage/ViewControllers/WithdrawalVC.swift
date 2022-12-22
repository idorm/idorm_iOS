//
//  WithdrawalViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/12/22.
//

import UIKit

import SnapKit
import Then
import RxSwift
import RxCocoa
import ReactorKit

final class WithdrawalViewController: BaseViewController, View {
  
  typealias Reactor = WithDrawalViewReactor
  
  // MARK: - Properties
  
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
  
  private let scrollView = UIScrollView()
  private let contentView = UIView()
  private let sadDomiImageView = UIImageView(image: #imageLiteral(resourceName: "sadDomi"))
  private let floatyBottomView = FloatyBottomView(.withdrawal)
  private let indicator = UIActivityIndicatorView().then { $0.color = .gray }
  
  private let reactor = WithDrawalViewReactor()
  
  // MARK: - Bind
  
  func bind(reactor: WithDrawalViewReactor) {
    
    // MARK: - Action
    
    // 다시 생각해볼래요 버튼 클릭
    floatyBottomView.leftButton.rx.tap
      .withUnretained(self)
      .bind { $0.0.navigationController?.popViewController(animated: true) }
      .disposed(by: disposeBag)
    
    // 탈퇴하기 버튼 클릭
    floatyBottomView.rightButton.rx.tap
      .map { WithDrawalViewReactor.Action.didTapWithDrawalButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // MARK: - State
    
    // 인디케이터 애니메이션
    reactor.state
      .map { $0.isLoading }
      .bind(to: indicator.rx.isAnimating)
      .disposed(by: disposeBag)
    
    // 로그인VC로 이동
    reactor.state
      .map { $0.isOpenedLoginVC }
      .distinctUntilChanged()
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
        owner.present(loginVC, animated: true)
      }
      .disposed(by: disposeBag)
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    navigationItem.title = "회원탈퇴"
    view.backgroundColor = .white
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
      make.bottom.equalToSuperview().offset(-32)
    }
  }
}
