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

final class PutEmailViewController: BaseViewController, View {
  
  typealias Reactor = PutEmailViewReactor
  
  // MARK: - Properties
  
  private lazy var infoLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .init(name: MyFonts.medium.rawValue, size: 14)
    switch type {
    case .findPw:
      $0.text = "가입시 사용한 인천대학교 이메일이 필요해요."
    case .signUp, .modifyPw:
      $0.text = "이메일"
    }
  }
  
  private let needEmailLabel = UILabel().then {
    $0.text = "인천대학교 이메일 (@inu.ac.kr)이 필요해요."
    $0.textColor = .idorm_gray_400
    $0.font = .init(name: MyFonts.medium.rawValue, size: 12)
  }
  
  private let indicator = UIActivityIndicatorView().then {
    $0.color = .gray
  }
  
  private lazy var inuStack = UIStackView().then { stack in
    [inuMark, needEmailLabel]
      .forEach { stack.addArrangedSubview($0) }
    stack.axis = .horizontal
    stack.spacing = 4
    
    switch type {
    case .signUp, .modifyPw:
      stack.isHidden = false
    case .findPw:
      stack.isHidden = true
    }
  }
  
  private let textField = idormTextField("이메일을 입력해주세요")
  private let confirmButton = idormButton("인증번호 받기")
  private let inuMark = UIImageView(image: #imageLiteral(resourceName: "inu"))
  
  private let type: RegisterEnumerations
  private let reactor = PutEmailViewReactor()

  // MARK: - LifeCycle
  
  init(_ type: RegisterEnumerations) {
    self.type = type
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
  // MARK: - Bind
  
  func bind(reactor: PutEmailViewReactor) {
    
    // MARK: - Action
    
    // 인증번호 받기 버튼 클릭
    confirmButton.rx.tap
      .withUnretained(self)
      .map { ($0.0.textField.text ?? "", $0.0.type) }
      .map { PutEmailViewReactor.Action.didTapReceiveButton($0.0, $0.1) }
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
    
    // AuthVC로 이동
    reactor.state
      .map { $0.isOpenedAuthVC }
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        let authVC = AuthViewController()
        owner.navigationController?.pushViewController(authVC, animated: true)
      }
      .disposed(by: disposeBag)
  }

  // MARK: - Setup
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [infoLabel, textField, confirmButton, inuStack, indicator]
      .forEach { view.addSubview($0) }
  }
  
  override func setupStyles() {
    super.setupStyles()
    
    view.backgroundColor = .white
    switch type {
    case .signUp:
      navigationItem.title = "회원가입"
    case .findPw:
      navigationItem.title = "비밀번호 찾기"
    case .modifyPw:
      navigationItem.title = "비밀번호 변경"
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    infoLabel.snp.makeConstraints { make in
      make.top.leading.equalTo(view.safeAreaLayoutGuide).inset(24)
    }
    
    textField.snp.makeConstraints { make in
      make.top.equalTo(infoLabel.snp.bottom).offset(8)
      make.leading.trailing.equalToSuperview().inset(24)
      make.height.equalTo(50)
    }
    
    confirmButton.snp.makeConstraints { make in
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
