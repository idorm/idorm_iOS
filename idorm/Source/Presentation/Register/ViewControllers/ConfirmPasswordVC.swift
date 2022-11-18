import UIKit

import SnapKit
import Then
import RxSwift
import RxCocoa

final class ConfirmPasswordViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let textField2 = RegisterPwTextField(placeholder: "비밀번호를 한번 더 입력해주세요.").then {
    $0.textField.isSecureTextEntry = true
  }
  private let textField1 = RegisterPwTextField(placeholder: "비밀번호를 입력해주세요.")
  
  private lazy var confirmButton = RegisterBottomButton("").then {
    switch vcType {
    case .signUp:
      $0.configuration?.title = "계속하기"
    case .updatePW, .findPW:
      $0.configuration?.title = "변경 완료"
    }
  }
  
  private let infoLabel = RegisterUtilities.infoLabel(text: "비밀번호")
  private let infoLabel2 = RegisterUtilities.infoLabel(text: "비밀번호 확인")
  private let eightLabel = RegisterUtilities.descriptionLabel(text: "•  8자 이상 입력")
  private let mixingLabel = RegisterUtilities.descriptionLabel(text: "•  영문 소문자/숫자/특수 문자 조합")
  
  private let vcType: RegisterVCTypes.ConfirmPasswordVCType
  private let viewModel: ConfirmPasswordViewModel
  
  // MARK: - LifeCycle
  
  init(_ vcType: RegisterVCTypes.ConfirmPasswordVCType) {
    self.vcType = vcType
    self.viewModel = ConfirmPasswordViewModel(vcType)
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Bind
  
  private func bindTextField() {
    
    // 비밀번호 텍스트필드 포커싱 -> UI변경
    textField1.textField.rx.controlEvent(.editingDidBegin)
      .bind(onNext: { [weak self] in
        self?.infoLabel.textColor = .black
        self?.eightLabel.textColor = .idorm_gray_400
        self?.mixingLabel.textColor = .idorm_gray_400
      })
      .disposed(by: disposeBag)
    
    // 비밀번호 텍스트필드 포커싱 해제 -> UI변경
    textField1.textField.rx.controlEvent(.editingDidEnd)
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        let countBool = self.viewModel.output.verificationCount.value
        let combineBool = self.viewModel.output.verificationCombine.value
        
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
          self.textField1.layer.borderColor = UIColor.idorm_red.cgColor
          self.infoLabel.textColor = .idorm_red
        }
      })
      .disposed(by: disposeBag)
    
    // 비밀번호 확인 텍스트필드 포커싱 -> UI변경
    textField2.textField.rx.controlEvent(.editingDidBegin)
      .bind(onNext: { [weak self] in
        self?.textField2.layer.borderColor = UIColor.idorm_blue.cgColor
        self?.infoLabel2.textColor = .idorm_gray_400
      })
      .disposed(by: disposeBag)
    
    // 비밀번호 확인 텍스트필드 포커싱 해제 -> UI변경
    textField2.textField.rx.controlEvent(.editingDidEnd)
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        let equality = self.viewModel.output.verificationEquality.value
        
        if equality {
          self.infoLabel2.text = "비밀번호 확인"
          self.infoLabel2.textColor = .idorm_gray_400
          self.textField2.textField.layer.borderColor = UIColor.idorm_blue.cgColor
        } else {
          self.infoLabel2.text = "두 비밀번호가 일치하지 않습니다. 다시 확인해주세요."
          self.infoLabel2.textColor = .idorm_red
          self.textField2.textField.layer.borderColor = UIColor.idorm_red.cgColor
        }
      })
      .disposed(by: disposeBag)
  }
  
  override func bind() {
    super.bind()
    bindTextField()
    
    // MARK: - Input
    
    // 비밀번호 텍스트필드 이벤트
    textField1.textField.rx.text
      .orEmpty
      .distinctUntilChanged()
      .bind(to: viewModel.input.passwordText)
      .disposed(by: disposeBag)

    // 비밀번호확인 텍스트필드 이벤트
    textField2.textField.rx.text
      .orEmpty
      .distinctUntilChanged()
      .bind(to: viewModel.input.passwordText_2)
      .disposed(by: disposeBag)
    
    // 확인 버튼 이벤트
    confirmButton.rx.tap
      .bind(to: viewModel.input.confirmButtonTapped)
      .disposed(by: disposeBag)
    
    // MARK: - Output
    
    // '8자 이상 입력' 라벨 색상 바꾸기
    viewModel.output.verificationCount
      .bind(onNext: { [weak self] isValid in
        if isValid {
          self?.eightLabel.textColor = .idorm_blue
        } else {
          self?.eightLabel.textColor = .idorm_gray_400
        }
      })
      .disposed(by: disposeBag)
    
    // 영문 소문자/숫자/특수 문자 조합 색상 바꾸기
    viewModel.output.verificationCombine
      .bind(onNext: { [weak self] isValid in
        if isValid {
          self?.mixingLabel.textColor = .idorm_blue
        } else {
          self?.mixingLabel.textColor = .idorm_gray_400
        }
      })
      .disposed(by: disposeBag)
    
    // 에러 팝업 띄우기
    viewModel.output.showErrorPopupVC
      .bind(onNext: { [weak self] mention in
        let popupVC = PopupViewController(contents: mention)
        popupVC.modalPresentationStyle = .overFullScreen
        self?.present(popupVC, animated: false)
      })
      .disposed(by: disposeBag)
    
    // 비밀번호 변경 완료 시 로그인 페이지로 넘어가기
    viewModel.output.showLoginVC
      .bind(onNext: { [weak self] in
        self?.navigationController?.popToRootViewController(animated: true)
      })
      .disposed(by: disposeBag)
    
    // 확인 버튼 활성/비활성
    viewModel.output.isEnableConfirmButton
      .bind(onNext: { [weak self] in
        if $0 {
          self?.confirmButton.isEnabled = true
        } else {
          self?.confirmButton.isEnabled = false
        }
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: - Setup
  
  override func setupLayouts() {
    super.setupLayouts()
    [infoLabel, infoLabel2, textField1, textField2, confirmButton, eightLabel, mixingLabel]
      .forEach { view.addSubview($0) }
  }
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .white
    confirmButton.isEnabled = false
    
    switch vcType {
    case .signUp:
      navigationItem.title = "회원가입"
    case .findPW, .updatePW:
      navigationItem.title = "비밀번호 변경"
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    infoLabel.snp.makeConstraints { make in
      make.leading.equalTo(view.safeAreaLayoutGuide).inset(24)
      make.top.equalTo(view.safeAreaLayoutGuide).inset(52)
    }
    
    textField1.snp.makeConstraints { make in
      make.top.equalTo(infoLabel.snp.bottom).offset(8)
      make.leading.trailing.equalToSuperview().inset(24)
      make.height.equalTo(50)
    }
    
    eightLabel.snp.makeConstraints { make in
      make.top.equalTo(textField1.snp.bottom).offset(8)
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
    
    textField2.snp.makeConstraints { make in
      make.top.equalTo(infoLabel2.snp.bottom).offset(8)
      make.trailing.leading.equalToSuperview().inset(24)
      make.height.equalTo(50)
    }
    
    confirmButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-20)
      make.height.equalTo(50)
    }
  }
  
  // MARK: - Helpers
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
}
