//
//  ConfirmPasswordViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/11.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ConfirmPasswordViewController: UIViewController {
  // MARK: - Properties
  let type: LoginType
  
  lazy var infoLabel = returnInfoLabel(text: "비밀번호")
  lazy var infoLabel2 = returnInfoLabel(text: "비밀번호 확인")
  
  lazy var eightLabel = returnDescriptionLabel(text: "•  8자 이상 입력")
  lazy var mixingLabel = returnDescriptionLabel(text: "•  영문 소문자/숫자/특수 문자 조합")
  
  lazy var passwordTextFieldContainerView: RegisterPwTextField = {
    let containerView = RegisterPwTextField(placeholder: "비밀번호를 입력해주세요.")
    
    return containerView
  }()
  
  lazy var passwordTextFieldContainerView2: UITextField = {
    let tf = LoginUtilities.returnTextField(placeholder: "비밀번호를 한번 더 입력해주세요.")
    tf.layer.borderColor = tf.isEditing ? UIColor.idorm_blue.cgColor : UIColor.idorm_gray_400.cgColor
    tf.isSecureTextEntry = true
    
    return tf
  }()
  
  lazy var confirmButton: UIButton = {
    let button = LoginUtilities.returnBottonConfirmButton(string: "")
    if type == .signUp {
      button.setTitle("가입 완료", for: .normal)
    } else {
      button.setTitle("변경 완료", for: .normal)
    }
    
    return button
  }()
  
  let viewModel = ConfirmPasswordViewModel()
  let disposeBag = DisposeBag()
  
  // MARK: - LifeCycle
  init(type: LoginType) {
    self.type = type
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
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
    confirmButton.rx.tap
      .throttle(.seconds(2), latest: false, scheduler: MainScheduler.instance)
      .bind(to: viewModel.input.confirmButtonTapped)
      .disposed(by: disposeBag)
    
    passwordTextFieldContainerView.textField.rx.text
      .orEmpty
      .distinctUntilChanged()
      .bind(to: viewModel.input.passwordText)
      .disposed(by: disposeBag)
    
    passwordTextFieldContainerView.textField.rx.controlEvent(.editingDidEnd)
      .bind(to: viewModel.input.passwordTextFieldDidEnd)
      .disposed(by: disposeBag)
    
    passwordTextFieldContainerView.textField.rx.controlEvent(.editingDidBegin)
      .bind(to: viewModel.input.passwordTextFieldDidBegin)
      .disposed(by: disposeBag)
    
    passwordTextFieldContainerView2.rx.controlEvent(.editingDidBegin)
      .bind(to: viewModel.input.passwordTextFieldDidBegin_2)
      .disposed(by: disposeBag)
    
    passwordTextFieldContainerView2.rx.controlEvent(.editingDidEnd)
      .bind(to: viewModel.input.passwordTextFieldDidEnd_2)
      .disposed(by: disposeBag)
    
    passwordTextFieldContainerView2.rx.text
      .orEmpty
      .distinctUntilChanged()
      .bind(to: viewModel.input.passwordText_2)
      .disposed(by: disposeBag)
    
    confirmButton.rx.tap
      .bind(to: viewModel.input.confirmButtonTapped)
      .disposed(by: disposeBag)
    
    // --------------------------------
    // -------------OUTPUT-------------
    // --------------------------------
    // 비밀번호 텍스트필드 포커싱
    viewModel.output.didBeginState
      .asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] in
        print("dd")
        self?.infoLabel.textColor = .black
        self?.eightLabel.textColor = .idorm_gray_400
        self?.mixingLabel.textColor = .idorm_gray_400
        self?.passwordTextFieldContainerView.layer.borderColor = UIColor.idorm_gray_400.cgColor
      })
      .disposed(by: disposeBag)

    // 비밀번호 확인 텍스트필드 포커싱
    viewModel.output.didBeginState_2
      .asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] in
        self?.passwordTextFieldContainerView2.layer.borderColor = UIColor.idorm_blue.cgColor
        self?.infoLabel2.textColor = .idorm_gray_400
      })
      .disposed(by: disposeBag)
    
    // 비밀번호 텍스트필드 포커스가 해제되었을 때
    viewModel.output.didEndState
      .asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] in
        guard let self = self else { return }
        let countBool = self.viewModel.output.countState.value
        let combineBool = self.viewModel.output.combineState.value
        
        if countBool {
          self.eightLabel.textColor = .idorm_blue
        } else {
          self.eightLabel.textColor = .idorm_red
        }
        
        if combineBool {
          self.mixingLabel.textColor = .idorm_blue
        } else {
          self.mixingLabel.textColor = .idorm_red
        }
        
        if countBool == false || combineBool == false {
          self.passwordTextFieldContainerView.layer.borderColor = UIColor.idorm_red.cgColor
          self.infoLabel.textColor = .idorm_red
        }
      })
      .disposed(by: disposeBag)
    
    // 비밀번호 확인 텍스트 포커싱 해제되었을 때
    viewModel.output.didEndState_2
      .asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] in
        guard let self = self else { return }
        let password = self.viewModel.passwordText
        let password2 = self.viewModel.passwordText2
        
        if password != password2 {
          self.infoLabel2.text = "비밀번호가 일치하지 않습니다. 다시확인해주세요."
          self.infoLabel2.textColor = .idorm_red
          self.passwordTextFieldContainerView2.layer.borderColor = UIColor.idorm_red.cgColor
        } else {
          self.infoLabel2.text = "비밀번호 확인"
          self.infoLabel2.textColor = .black
          self.passwordTextFieldContainerView2.layer.borderColor = UIColor.idorm_gray_400.cgColor
        }
      })
      .disposed(by: disposeBag)

    // '8자 이상 입력' 라벨 색상 바꾸기
    viewModel.output.countState
      .asDriver(onErrorJustReturn: false)
      .drive(onNext: { [weak self] isValid in
        if isValid {
          self?.eightLabel.textColor = .idorm_blue
        } else {
          self?.eightLabel.textColor = .idorm_gray_400
        }
      })
      .disposed(by: disposeBag)
    
    // 영문 소문자/숫자/특수 문자 조합 색상 바꾸기
    viewModel.output.combineState
      .asDriver(onErrorJustReturn: false)
      .drive(onNext: { [weak self] isValid in
        if isValid {
          self?.mixingLabel.textColor = .idorm_blue
        } else {
          self?.mixingLabel.textColor = .idorm_gray_400
        }
      })
      .disposed(by: disposeBag)
    
    // 완료버튼 누를 때 에러 팝업 띄우기
    viewModel.output.showErrorPopupVC
      .asDriver(onErrorJustReturn: "")
      .drive(onNext: { [weak self] mention in
        let popupVC = PopupViewController(contents: mention)
        popupVC.modalPresentationStyle = .overFullScreen
        self?.present(popupVC, animated: false)
      })
      .disposed(by: disposeBag)
    
    // 회원가입 완료 페이지로 넘어가기
    viewModel.output.showCompleteVC
      .asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] in
        let completeVC = CompleteSignUpViewController()
        completeVC.modalPresentationStyle = .fullScreen
        self?.present(completeVC, animated: true)
      })
      .disposed(by: disposeBag)
    
    viewModel.output.showLoginVC
      .asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] in
        self?.navigationController?.popToRootViewController(animated: true)
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: - Helpers
  private func configureUI() {
    view.backgroundColor = .white
    
    if type == .signUp {
      navigationItem.title = "회원가입"
    } else {
      navigationItem.title = "비밀번호 변경"
    }
    
    [ infoLabel, infoLabel2, passwordTextFieldContainerView, passwordTextFieldContainerView2, confirmButton, eightLabel, mixingLabel ]
      .forEach { view.addSubview($0) }
    
    infoLabel.snp.makeConstraints { make in
      make.leading.equalTo(view.safeAreaLayoutGuide).inset(24)
      make.top.equalTo(view.safeAreaLayoutGuide).inset(52)
    }
    
    passwordTextFieldContainerView.snp.makeConstraints { make in
      make.top.equalTo(infoLabel.snp.bottom).offset(8)
      make.leading.trailing.equalToSuperview().inset(24)
      make.height.equalTo(50)
    }
    
    eightLabel.snp.makeConstraints { make in
      make.top.equalTo(passwordTextFieldContainerView.snp.bottom).offset(8)
      make.leading.equalToSuperview().inset(24)
    }
    
    mixingLabel.snp.makeConstraints { make in
      make.top.equalTo(eightLabel.snp.bottom)
      make.leading.equalToSuperview().inset(24)
    }
    
    infoLabel2.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalTo(mixingLabel.snp.bottom).offset(30)
    }
    
    passwordTextFieldContainerView2.snp.makeConstraints { make in
      make.top.equalTo(infoLabel2.snp.bottom).offset(8)
      make.trailing.leading.equalToSuperview().inset(24)
    }
    
    confirmButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-20)
    }
  }
  
  private func returnInfoLabel(text: String) -> UILabel {
    let label = UILabel()
    label.text = text
    label.textColor = .black
    label.font = .init(name: MyFonts.medium.rawValue, size: 14.0)
    return label
  }
  
  private func returnDescriptionLabel(text: String) -> UILabel {
    let label = UILabel()
    label.font = .init(name: MyFonts.medium.rawValue, size: 12.0)
    label.textColor = .idorm_gray_400
    label.text = text
    
    return label
  }
  
  private func validConfirmPassword(text: String) {
    guard let password1Text = passwordTextFieldContainerView.textField.text else { return }
    if passwordTextFieldContainerView2.text != password1Text {
      infoLabel2.text = "비밀번호가 일치하지 않습니다. 다시확인해주세요."
      infoLabel2.textColor = .red
      passwordTextFieldContainerView2.layer.borderColor = UIColor.red.cgColor
    } else {
      infoLabel2.text = "비밀번호 확인"
      infoLabel2.textColor = .black
      passwordTextFieldContainerView2.layer.borderColor = UIColor.idorm_gray_400.cgColor
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
}
