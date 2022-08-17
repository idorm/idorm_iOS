//
//  FindPasswordViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/10.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class PutEmailViewController: UIViewController {
  // MARK: - Properties
  let type: LoginType
  var confirmButtonYValue = CGFloat(0)
  
  lazy var infoLabel: UILabel = {
    let label = UILabel()
    label.textColor = .black
    label.font = .init(name: Font.medium.rawValue, size: 14.0)
    if type == .findPW {
      label.text = "가입시 사용한 인천대학교 이메일이 필요해요."
    } else {
      label.text = "이메일"
    }
    
    return label
  }()
  
  lazy var inuMark: UIImageView = {
    let iv = UIImageView()
    iv.image = UIImage(named: "INUMark")
    
    return iv
  }()
  
  lazy var needEmailLabel: UILabel = {
    let label = UILabel()
    label.text = "인천대학교 이메일 (@inu.ac.kr)이 필요해요."
    label.textColor = .gray
    label.font = .systemFont(ofSize: 14.0)
    
    return label
  }()
  
  lazy var confirmButton: UIButton = {
    let button = LoginUtilities.returnBottonConfirmButton(string: "")
    if type == .findPW {
      button.setTitle("인증번호 발급받기", for: .normal)
    } else {
      button.setTitle("회원가입", for: .normal)
    }
    
    return button
  }()
  
  lazy var textField: UITextField = {
    let tf = LoginUtilities.returnTextField(placeholder: "이메일을 입력해주세요")
    
    return tf
  }()
  
  let viewModel = PutEmailViewModel()
  let disposeBag = DisposeBag()
  
  // MARK: - LifeCycle
  init(type: LoginType) {
    self.type = type
    super.init(nibName: nil, bundle: nil)
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
  }
  
  // MARK: - Bind
  func bind() {
    // --------------------------------
    // --------------INPUT-------------
    // --------------------------------
    confirmButton.rx.tap
      .bind(to: viewModel.input.confirmButtonTapped)
      .disposed(by: disposeBag)
    
    textField.rx.text
      .orEmpty
      .bind(to: viewModel.input.emailText)
      .disposed(by: disposeBag)

    // --------------------------------
    // -------------OUTPUT-------------
    // --------------------------------
    viewModel.output.showErrorPopupVC
      .asDriver(onErrorJustReturn: "")
      .drive(onNext: { [weak self] mention in
        let popupVC = PopupViewController(contents: mention)
        popupVC.modalPresentationStyle = .overFullScreen
        self?.present(popupVC, animated: false)
      })
      .disposed(by: disposeBag)
    
    viewModel.output.showAuthVC
      .asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] in
        let authVC = UINavigationController(rootViewController: AuthViewController())
        authVC.modalPresentationStyle = .fullScreen
        self?.present(authVC, animated: true)
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: - Helpers
  private func configureUI() {
    view.backgroundColor = .white
    navigationController?.isNavigationBarHidden = false
    
    let inustack = UIStackView(arrangedSubviews: [ inuMark, needEmailLabel ])
    inustack.axis = .horizontal
    inustack.spacing = 4.0
    
    if type == .findPW {
      navigationItem.title = "비밀번호 찾기"
      inustack.isHidden = true
    } else {
      navigationItem.title = "회원가입"
      inustack.isHidden = false
    }
    
    [ infoLabel, textField, confirmButton, inustack ]
      .forEach { view.addSubview($0) }
    
    infoLabel.snp.makeConstraints { make in
      make.top.leading.equalTo(view.safeAreaLayoutGuide).inset(24)
    }
    
    textField.snp.makeConstraints { make in
      make.top.equalTo(infoLabel.snp.bottom).offset(8)
      make.leading.trailing.equalToSuperview().inset(24)
    }
    
    confirmButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-20)
    }
    
    inustack.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(textField.snp.bottom).offset(16)
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
}
