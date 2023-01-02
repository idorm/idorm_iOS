//
//  PrivacyPolicyBottomSheet.swift
//  idorm
//
//  Created by 김응철 on 2023/01/02.
//

import UIKit

import SnapKit
import Then
import PanModal
import RxSwift
import RxCocoa
import ReactorKit

final class PrivacyPolicyBottomSheet: BaseViewController, View {
  
  // MARK: - Properties
  
  private let agreementLabel1 = UILabel().then {
    $0.text = "회원가입 약관 필수동의"
    $0.font = .init(name: MyFonts.medium.rawValue, size: 12)
    $0.textColor = .idorm_gray_400
  }
  
  private let agreementLabel2 = UILabel().then {
    $0.text = "개인정보 처리방침 필수동의"
    $0.font = .init(name: MyFonts.medium.rawValue, size: 12)
    $0.textColor = .idorm_gray_400
  }

  private let agreementButton1 = UILabel().then {
    $0.text = "보기"
    $0.textColor = .idorm_gray_200
    $0.font = .init(name: MyFonts.medium.rawValue, size: 12)
  }
  
  private let agreementButton2 = UILabel().then {
    $0.text = "보기"
    $0.textColor = .idorm_gray_200
    $0.font = .init(name: MyFonts.medium.rawValue, size: 12)
  }
  
  private let agreementCircleButton1 = UIButton().then {
    $0.setImage(UIImage(named: "circle_gray"), for: .normal)
    $0.setImage(UIImage(named: "circle_blue"), for: .selected)
  }
  
  private let agreementCircleButton2 = UIButton().then {
    $0.setImage(UIImage(named: "circle_gray"), for: .normal)
    $0.setImage(UIImage(named: "circle_blue"), for: .selected)
  }
  
  private let indicator = UIActivityIndicatorView().then {
    $0.color = .darkGray
  }
  
  private let confirmButton = idormButton("완료")
  
  // MARK: - Setup
  
  override func setupStyles() {
    view.backgroundColor = .white
  }
  
  override func setupLayouts() {
    [
      confirmButton,
      agreementCircleButton1,
      agreementCircleButton2,
      agreementLabel1,
      agreementLabel2,
      agreementButton1,
      agreementButton2,
      indicator
    ]
      .forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    
    confirmButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
      make.height.equalTo(53)
    }
    
    agreementCircleButton1.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(27.5)
      make.bottom.equalTo(agreementButton2.snp.top).offset(-15)
    }
    
    agreementCircleButton2.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(27.5)
      make.bottom.equalTo(confirmButton.snp.top).offset(-33.5)
    }
    
    agreementLabel1.snp.makeConstraints { make in
      make.centerY.equalTo(agreementCircleButton1)
      make.leading.equalTo(agreementCircleButton1.snp.trailing).offset(11.5)
    }
    
    agreementLabel2.snp.makeConstraints { make in
      make.centerY.equalTo(agreementCircleButton2)
      make.leading.equalTo(agreementCircleButton2.snp.trailing).offset(11.5)
    }
    
    agreementButton1.snp.makeConstraints { make in
      make.centerY.equalTo(agreementCircleButton1)
      make.leading.equalTo(agreementLabel1.snp.trailing).offset(8)
    }
    
    agreementButton2.snp.makeConstraints { make in
      make.centerY.equalTo(agreementCircleButton2)
      make.leading.equalTo(agreementLabel2.snp.trailing).offset(8)
    }
    
    indicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  
  // MARK: - Bind
  
  func bind(reactor: PrivacyPolicyBottomSheetReactor) {
    
    // MARK: -  Action
    
    // 버튼 토글
    agreementCircleButton1.rx.tap
      .withUnretained(self)
      .map { !$0.0.agreementCircleButton1.isSelected }
      .bind(to: agreementCircleButton1.rx.isSelected)
      .disposed(by: disposeBag)
    
    agreementCircleButton2.rx.tap
      .withUnretained(self)
      .map { !$0.0.agreementCircleButton2.isSelected }
      .bind(to: agreementCircleButton2.rx.isSelected)
      .disposed(by: disposeBag)
    
    // 완료 버튼
    confirmButton.rx.tap
      .withUnretained(self)
      .filter {
        $0.0.agreementCircleButton1.isSelected &&
        $0.0.agreementCircleButton2.isSelected
      }
      .map { _ in PrivacyPolicyBottomSheetReactor.Action.didTapConfirmButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // TODO: 보기 버튼 노션 페이지로 이동하기
    
    // MARK: - State
    
    reactor.state
      .map { $0.isLoading }
      .bind(to: indicator.rx.isAnimating)
      .disposed(by: disposeBag)
    
    reactor.state
      .map { $0.isLoading }
      .map { !$0 }
      .bind(to: view.rx.isUserInteractionEnabled)
      .disposed(by: disposeBag)
    
    // 오류 팝업
    reactor.state
      .map { $0.isOpenedPopup }
      .filter { $0.0 }
      .withUnretained(self)
      .bind { owner, message in
        let popup = BasicPopup(contents: message.1)
        popup.modalPresentationStyle = .overFullScreen
        owner.present(popup, animated: false)
      }
      .disposed(by: disposeBag)
    
    // CompleteSignUpVC로 이동
    reactor.state
      .map { $0.isOpenedCompleteSignUpVC }
      .filter { $0 }
      .withUnretained(self)
      .bind {
        let completeSignUpVC = CompleteSignUpViewController()
        completeSignUpVC.reactor = CompleteSignupViewReactor()
        completeSignUpVC.modalPresentationStyle = .fullScreen
        $0.0.present(completeSignUpVC, animated: true)
      }
      .disposed(by: disposeBag)
  }
}

extension PrivacyPolicyBottomSheet: PanModalPresentable {
  var panScrollable: UIScrollView? { nil }
  
  var longFormHeight: PanModalHeight { .contentHeight(202) }
  
  var shortFormHeight: PanModalHeight { .contentHeight(202) }
  
  var cornerRadius: CGFloat { 24 }
}
