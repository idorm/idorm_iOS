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
  
  // MARK: - UI COMPONENTS
  
  private let backButton = UIButton().then {
    var config = UIButton.Configuration.plain()
    config.image = #imageLiteral(resourceName: "xmark_black")
    config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    $0.configuration = config
  }
  
  private let portalButton = OldiDormButton("메일함 바로가기").then {
    $0.configuration?.baseForegroundColor = .idorm_gray_400
    $0.configuration?.baseBackgroundColor = .white
    $0.configuration?.background.strokeWidth = 1
    $0.configuration?.background.strokeColor = .idorm_gray_200
  }
  
  private let spamDescriptionLabel: UILabel = UILabel().then {
    $0.font = .iDormFont(.medium, size: 14.0)
    $0.textColor = .idorm_gray_300
    $0.text = "메일이 오지 않았으면 스팸함을 확인해주세요."
  }
  
  private let envelopeImageView = UIImageView(image: #imageLiteral(resourceName: "envelope"))
  private let nextButton = OldiDormButton("인증번호 입력")
  
  // MARK: -  PROPERTIES
  
  private let mailTimer = MailTimerChecker()
  
  // MARK: - BIND
  
  func bind(reactor: AuthViewReactor) {
    
    // MARK: - Action
    
    // X표시 버튼
    self.backButton.rx.tap
      .map { AuthViewReactor.Action.dismiss }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 메일함 바로가기 버튼
    self.portalButton.rx.tap
      .map { AuthViewReactor.Action.portal }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 인증번호 입력 버튼
    self.nextButton.rx.tap
      .map { AuthViewReactor.Action.next }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // MARK: - State
    
    // 사파리 열기
    reactor.state
      .map { $0.isOpenedSafari }
      .filter { $0 }
      .bind { _ in UIApplication.shared.open(URL(string: "https://webmail.inu.ac.kr/member/login?host_domain=inu.ac.kr")!) }
      .disposed(by: disposeBag)
    
    // AuthNumberVC로 이동
    reactor.state
      .map { $0.isOpenedAuthNumberVC }
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        let authNumberVC = AuthNumberViewController(owner.mailTimer)
        authNumberVC.reactor = AuthNumberViewReactor(owner.mailTimer)
        owner.navigationController?.pushViewController(authNumberVC, animated: true)
      }
      .disposed(by: disposeBag)
    
    // 화면 종료
    reactor.state
      .map { $0.isDismiss }
      .filter { $0 }
      .withUnretained(self)
      .bind { $0.0.dismiss(animated: true) }
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
    [
      envelopeImageView,
      spamDescriptionLabel,
      portalButton,
      nextButton
    ]
      .forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    envelopeImageView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().inset(150)
    }
    
    spamDescriptionLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(envelopeImageView.snp.bottom).offset(4)
    }
    
    nextButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.bottom.equalToSuperview().inset(85)
      make.height.equalTo(50)
    }
    
    portalButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.bottom.equalTo(nextButton.snp.top).offset(-8)
      make.height.equalTo(50)
    }
  }
}
