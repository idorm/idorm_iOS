//
//  AuthViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/15.
//

import UIKit

import SnapKit
import Then
import WebKit
import RxSwift
import RxCocoa

class AuthViewController: BaseViewController {
  
  // MARK: - Properties
  
  lazy var mailImageView = UIImageView(image: UIImage(named: "mail"))
  lazy var authInfoImageView = UIImageView(image: UIImage(named: "AuthInfoLabel"))
  lazy var confirmButton = RegisterBottomButton("인증번호 입력")
  
  lazy var backButton = UIButton().then {
    var config = UIButton.Configuration.plain()
    config.image = UIImage(named: "Xmark_Black")
    config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    $0.configuration = config
  }
  
  lazy var portalButton = RegisterBottomButton("메일함 바로가기").then {
    $0.configuration?.baseForegroundColor = .idorm_gray_400
    $0.configuration?.baseBackgroundColor = .white
    $0.configuration?.background.strokeWidth = 1
    $0.configuration?.background.strokeColor = .idorm_gray_200
  }
  
  var pushCompletion: (() -> Void)?
  
  let viewModel = AuthViewModel()
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    // --------------------------------
    // --------------INPUT-------------
    // --------------------------------
    
    // 뒤로가기 버튼 이벤트
    backButton.rx.tap
      .bind(to: viewModel.input.backButtonTapped)
      .disposed(by: disposeBag)
    
    // 웹메일 바로 가기 버튼 이벤트
    portalButton.rx.tap
      .bind(to: viewModel.input.portalButtonTapped)
      .disposed(by: disposeBag)
    
    // 인증번호 입력 버튼 이벤트
    confirmButton.rx.tap
      .bind(to: viewModel.input.confirmButtonTapped)
      .disposed(by: disposeBag)
    
    // 메일 타이머 시작
    rx.viewDidLoad
      .bind(onNext: {
        MailTimerChecker.shared.start()
      })
      .disposed(by: disposeBag)
    
    // --------------------------------
    // -------------OUTPUT-------------
    // --------------------------------
    
    // 화면 종료
    viewModel.output.dismissVC
      .asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] in
        self?.dismiss(animated: true)
      })
      .disposed(by: disposeBag)
    
    // 웹메일 페이지 보여주기
    viewModel.output.showPortalWeb
      .asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] in
        guard let url = URL(string: "https://webmail.inu.ac.kr/member/login?host_domain=inu.ac.kr&t=1658031681") else { return }
        let webMailVC = WebMailViewController(urlRequest: URLRequest(url: url))
        webMailVC.modalPresentationStyle = .fullScreen
        self?.navigationController?.pushViewController(webMailVC, animated: true)
      })
      .disposed(by: disposeBag)
    
    // 인증번호 입력 페이지로 넘어가기
    viewModel.output.showAuthNumberVC
      .asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] in
        let authNumberVC = AuthNumberViewController()
        self?.navigationController?.pushViewController(authNumberVC, animated: true)
        
        authNumberVC.popCompletion = {
          self?.pushCompletion?()
        }
      })
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
    
    [mailImageView, authInfoImageView, portalButton, confirmButton]
      .forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    mailImageView.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide).inset(114)
      make.centerX.equalToSuperview()
    }
    
    authInfoImageView.snp.makeConstraints { make in
      make.top.equalTo(mailImageView.snp.bottom).offset(20)
      make.centerX.equalToSuperview()
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
