import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class ConfirmPasswordViewController: BaseViewController {
  
  // MARK: - Properties
  
  let textField2 = RegisterPwTextField(placeholder: "비밀번호를 한번 더 입력해주세요.").then {
    $0.textField.isSecureTextEntry = true
  }
  
  lazy var confirmButton = RegisterBottomButton("").then {
    if type == .signUp {
      $0.configuration?.title = "가입 완료"
    } else {
      $0.configuration?.title = "변경 완료"
    }
  }
  
  let textField1 = RegisterPwTextField(placeholder: "비밀번호를 입력해주세요.")
  
  lazy var infoLabel = returnInfoLabel(text: "비밀번호")
  lazy var infoLabel2 = returnInfoLabel(text: "비밀번호 확인")
  
  lazy var eightLabel = returnDescriptionLabel(text: "•  8자 이상 입력")
  lazy var mixingLabel = returnDescriptionLabel(text: "•  영문 소문자/숫자/특수 문자 조합")
  
  let type: RegisterType
  
  let viewModel = ConfirmPasswordViewModel()
  
  // MARK: - Init
  
  init(type: RegisterType) {
    self.type = type
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    // --------------------------------
    // --------------INPUT-------------
    // --------------------------------
    
    /// 텍스트필드 이벤트 모음
    textField1.textField.rx.text
      .orEmpty
      .distinctUntilChanged()
      .bind(to: viewModel.input.passwordText)
      .disposed(by: disposeBag)
    
    textField1.textField.rx.controlEvent(.editingDidEnd)
      .bind(to: viewModel.input.passwordTextFieldDidEnd)
      .disposed(by: disposeBag)
    
    textField1.textField.rx.controlEvent(.editingDidBegin)
      .bind(to: viewModel.input.passwordTextFieldDidBegin)
      .disposed(by: disposeBag)
    
    textField2.textField.rx.controlEvent(.editingDidBegin)
      .bind(to: viewModel.input.passwordTextFieldDidBegin_2)
      .disposed(by: disposeBag)
    
    textField2.textField.rx.controlEvent(.editingDidEnd)
      .bind(to: viewModel.input.passwordTextFieldDidEnd_2)
      .disposed(by: disposeBag)
    
    textField2.textField.rx.text
      .orEmpty
      .distinctUntilChanged()
      .bind(to: viewModel.input.passwordText_2)
      .disposed(by: disposeBag)
    
    /// 확인 버튼 이벤트
    confirmButton.rx.tap
      .bind(to: viewModel.input.confirmButtonTapped)
      .disposed(by: disposeBag)
    
    // --------------------------------
    // -------------OUTPUT-------------
    // --------------------------------
    
    /// 비밀번호 텍스트필드 포커싱
    viewModel.output.didBeginState
      .asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] in
        self?.infoLabel.textColor = .black
        self?.eightLabel.textColor = .idorm_gray_400
        self?.mixingLabel.textColor = .idorm_gray_400
        self?.textField1.layer.borderColor = UIColor.idorm_gray_400.cgColor
      })
      .disposed(by: disposeBag)

    /// 비밀번호 확인 텍스트필드 포커싱
    viewModel.output.didBeginState_2
      .asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] in
        self?.textField2.layer.borderColor = UIColor.idorm_blue.cgColor
        self?.infoLabel2.textColor = .idorm_gray_400
      })
      .disposed(by: disposeBag)
    
    /// 비밀번호 텍스트필드 포커스가 해제되었을 때
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
          self.textField1.layer.borderColor = UIColor.idorm_red.cgColor
          self.infoLabel.textColor = .idorm_red
        }
      })
      .disposed(by: disposeBag)
    
    /// 비밀번호 확인 텍스트 포커싱 해제되었을 때
    viewModel.output.didEndState_2
      .asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] in
        guard let self = self else { return }
        let password = self.viewModel.passwordText
        let password2 = self.viewModel.passwordText2
        
        if password != password2 {
          self.infoLabel2.text = "비밀번호가 일치하지 않습니다. 다시확인해주세요."
          self.infoLabel2.textColor = .idorm_red
          self.textField2.layer.borderColor = UIColor.idorm_red.cgColor
        } else {
          self.infoLabel2.text = "비밀번호 확인"
          self.infoLabel2.textColor = .black
          self.textField2.layer.borderColor = UIColor.idorm_gray_400.cgColor
        }
      })
      .disposed(by: disposeBag)

    /// '8자 이상 입력' 라벨 색상 바꾸기
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
    
    /// 영문 소문자/숫자/특수 문자 조합 색상 바꾸기
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
    
    /// 완료버튼 누를 때 에러 팝업 띄우기
    viewModel.output.showErrorPopupVC
      .asDriver(onErrorJustReturn: "")
      .drive(onNext: { [weak self] mention in
        let popupVC = PopupViewController(contents: mention)
        popupVC.modalPresentationStyle = .overFullScreen
        self?.present(popupVC, animated: false)
      })
      .disposed(by: disposeBag)
    
    /// 회원가입 완료 페이지로 넘어가기
    viewModel.output.showCompleteVC
      .asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] in
        let completeVC = CompleteSignUpViewController()
        completeVC.modalPresentationStyle = .fullScreen
        self?.present(completeVC, animated: true)
      })
      .disposed(by: disposeBag)
    
    /// 비밀번호 변경 완료 시 로그인 페이지로 넘어가기
    viewModel.output.showLoginVC
      .asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] in
        self?.navigationController?.popToRootViewController(animated: true)
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
    if type == .signUp {
      navigationItem.title = "회원가입"
    } else {
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
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
}

// MARK: - Utilities

extension ConfirmPasswordViewController {
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
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct ConfirmPasswordVC_PreView: PreviewProvider {
  static var previews: some View {
    ConfirmPasswordViewController(type: .findPW).toPreview()
  }
}
#endif

