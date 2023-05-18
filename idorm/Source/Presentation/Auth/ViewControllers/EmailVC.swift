//
//  PutEmailViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/12/21.
//

import UIKit

import Then
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class EmailViewController: BaseViewController, View {
  
  enum ViewControllerType {
    case signUp
    case findPw
    case changePw
  }
  
  // MARK: - UI COMPONENTS
  
  private lazy var mainDescriptionLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .idormFont(.medium, size: 14)
    switch viewControllerType {
    case .findPw, .changePw:
      $0.text = "가입시 사용한 인천대학교 이메일이 필요해요."
    case .signUp:
      $0.text = "이메일"
    }
  }
  
  private let emailDescriptionLabel = UILabel().then {
    $0.text = "인천대학교 이메일 (@inu.ac.kr)이 필요해요."
    $0.textColor = .idorm_gray_400
    $0.font = .idormFont(.medium, size: 12)
  }
  
  private let indicator = UIActivityIndicatorView().then {
    $0.color = .darkGray
  }
  
  private lazy var inuStack = UIStackView().then { stack in
    [inuImageView, emailDescriptionLabel]
      .forEach { stack.addArrangedSubview($0) }
    stack.axis = .horizontal
    stack.spacing = 4
    
    switch viewControllerType {
    case .signUp:
      stack.isHidden = false
    case .findPw, .changePw:
      stack.isHidden = true
    }
  }
  
  private let textField = idormTextField("이메일을 입력해주세요")
  private let nextButton = idormButton("인증번호 받기")
  private let inuImageView = UIImageView(image: #imageLiteral(resourceName: "inu"))
  
  // MARK: - PROPERTIES
  
  let viewControllerType: ViewControllerType

  // MARK: - LifeCycle
  
  init(_ viewControllerType: ViewControllerType) {
    self.viewControllerType = viewControllerType
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
  // MARK: - Bind
  
  func bind(reactor: EmailViewReactor) {
    
    // MARK: - Action
    
    // 인증번호 받기 버튼 클릭
    nextButton.rx.tap
      .withUnretained(self)
      .map { ($0.0.textField.text ?? "", $0.0.viewControllerType) }
      .map { EmailViewReactor.Action.next($0.0, $0.1) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // MARK: - State
    
    // 오류 팝업 창
    reactor.state
      .map { $0.isOpenedPopup }
      .filter { $0.0 }
      .withUnretained(self)
      .bind { owner, content in
        let popup = BasicPopup(contents: content.1)
        popup.modalPresentationStyle = .overFullScreen
        owner.present(popup, animated: false)
      }
      .disposed(by: disposeBag)
    
    // 인디케이터 제어
    reactor.state
      .map { $0.isLoading }
      .bind(to: indicator.rx.isAnimating)
      .disposed(by: disposeBag)
    
    // 화면 인터렉션 제어
    reactor.state
      .map { $0.isLoading }
      .map { !$0 }
      .bind(to: view.rx.isUserInteractionEnabled)
      .disposed(by: disposeBag)
    
    // AuthVC로 이동
    reactor.state
      .map { $0.isOpenedAuthVC }
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        Logger.shared.saveEmailVcReference(owner)
        let authVC = AuthViewController()
        authVC.reactor = AuthViewReactor()
        let navVC = UINavigationController(rootViewController: authVC)
        navVC.modalPresentationStyle = .fullScreen
        owner.present(navVC, animated: true)
      }
      .disposed(by: disposeBag)
  }

  // MARK: - Setup
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [
      mainDescriptionLabel,
      textField,
      nextButton,
      inuStack,
      indicator
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    
    view.backgroundColor = .white
    switch viewControllerType {
    case .signUp:
      navigationItem.title = "회원가입"
    case .findPw:
      navigationItem.title = "비밀번호 찾기"
    case .changePw:
      navigationItem.title = "비밀번호 변경"
    }
  }
  
  override func setupConstraints() {
    mainDescriptionLabel.snp.makeConstraints { make in
      make.top.leading.equalTo(view.safeAreaLayoutGuide).inset(24)
    }
    
    textField.snp.makeConstraints { make in
      make.top.equalTo(mainDescriptionLabel.snp.bottom).offset(8)
      make.leading.trailing.equalToSuperview().inset(24)
      make.height.equalTo(50)
    }
    
    nextButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-20)
      make.height.equalTo(50)
    }
    
    inuStack.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(textField.snp.bottom).offset(16)
    }
    
    indicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.height.equalTo(20)
    }
  }
  
  // MARK: - Helpers
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
}
