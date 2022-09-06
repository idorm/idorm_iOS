//
//  AuthViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/15.
//

import UIKit
import SnapKit
import WebKit
import RxSwift
import RxCocoa
import SwiftUI

class AuthViewController: UIViewController {
  // MARK: - Properties
  var dismissCompletion: (() -> Void)?
  
  lazy var mailImageView: UIImageView = {
    let iv = UIImageView()
    iv.image = UIImage(named: "mail")
    
    return iv
  }()
  
  lazy var authInfoImageView: UIImageView = {
    let iv = UIImageView()
    iv.image = UIImage(named: "AuthInfoLabel")
    
    return iv
  }()
  
  lazy var backButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(named: "Xmark_Black"), for: .normal)
    button.tintColor = .black
    
    return button
  }()
  
  lazy var portalButton: UIButton = {
    let button = LoginUtilities.returnBottonConfirmButton(string: "메일함 바로가기")
    button.configuration?.baseForegroundColor = .idorm_gray_400
    button.configuration?.baseBackgroundColor = .white
    button.configuration?.background.strokeWidth = 1
    button.configuration?.background.strokeColor = .idorm_gray_200
    
    return button
  }()
  
  lazy var confirmButton: UIButton = {
    let button = LoginUtilities.returnBottonConfirmButton(string: "인증번호 입력")
    
    return button
  }()
  
  let viewModel = AuthViewModel()
  let disposeBag = DisposeBag()
  
  // MARK: - LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bind()
  }
  
  // MARK: - Bind
  func bind() {
    // --------------------------------
    // --------------INPUT-------------
    // --------------------------------
    backButton.rx.tap
      .bind(to: viewModel.input.backButtonTapped)
      .disposed(by: disposeBag)
    
    portalButton.rx.tap
      .bind(to: viewModel.input.portalButtonTapped)
      .disposed(by: disposeBag)
    
    confirmButton.rx.tap
      .bind(to: viewModel.input.confirmButtonTapped)
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
    
    // 웹메일 웹 보여주기
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
          self?.dismissCompletion?()
        }
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: - Helpers
  private func configureUI() {
    view.backgroundColor = .white
    navigationController?.navigationBar.tintColor = .black
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    
    [ mailImageView, authInfoImageView, portalButton, confirmButton ]
      .forEach { view.addSubview($0) }
    
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
    }
    
    portalButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.bottom.equalTo(confirmButton.snp.top).offset(-8)
    }
  }
}
