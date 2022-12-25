//
//  AuthViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/12/23.
//

import UIKit

import SnapKit
import Then
import WebKit
import RxSwift
import RxCocoa
import ReactorKit

final class AuthViewController: BaseViewController, View {
  
  typealias Reactor = AuthViewReactor
  
  // MARK: - Properties
  
  private let backButton = UIButton().then {
    var config = UIButton.Configuration.plain()
    config.image = #imageLiteral(resourceName: "Xmark_Black")
    config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    $0.configuration = config
  }
  
  private let portalButton = idormButton("메일함 바로가기").then {
    $0.configuration?.baseForegroundColor = .idorm_gray_400
    $0.configuration?.baseBackgroundColor = .white
    $0.configuration?.background.strokeWidth = 1
    $0.configuration?.background.strokeColor = .idorm_gray_200
  }
  
  private let envelopeImageView = UIImageView(image: #imageLiteral(resourceName: "envelope"))
  private let confirmButton = idormButton("인증번호 입력")
  
  private let mailTimer = MailTimerChecker()
  private let reactor = AuthViewReactor()
    
  // MARK: - Bind
  
  func bind(reactor: AuthViewReactor) {
    
    // MARK: - Action
    
    // 메일함 바로가기 버튼
    portalButton.rx.tap
      .map { AuthViewReactor.Action.didTapPortalButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 인증번호 입력 버튼
    confirmButton.rx.tap
      .map { AuthViewReactor.Action.didTapConfirmButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // MARK: - State
    
    // 사파리 열기
    reactor.state
      .map { $0.isOpenedSafari }
      .filter { $0 }
      .bind { _ in  UIApplication.shared.open(URL(string: "https://webmail.inu.ac.kr/member/login?host_domain=inu.ac.kr")!) }
      .disposed(by: disposeBag)
    
    // AuthNumberVC로 이동
    reactor.state
      .map { $0.isOpenedAuthNumberVC }
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        let authNumberVC = AuthNumberViewController(owner.mailTimer)
        owner.navigationController?.pushViewController(authNumberVC, animated: true)
      }
      .disposed(by: disposeBag)
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .white
    navigationController?.navigationBar.tintColor = .black
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [envelopeImageView, portalButton, confirmButton]
      .forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    envelopeImageView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().inset(150)
    }
    
    confirmButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.bottom.equalToSuperview().inset(85)
      make.height.equalTo(50)
    }
    
    portalButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.bottom.equalTo(confirmButton.snp.top).offset(-8)
      make.height.equalTo(50)
    }
  }
}
