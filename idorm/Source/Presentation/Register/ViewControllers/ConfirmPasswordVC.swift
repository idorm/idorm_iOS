import UIKit

import SnapKit
import Then
import RxSwift
import RxCocoa

final class ConfirmPasswordViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let infoLabel = UILabel().then {
    $0.text = "비밀번호"
    $0.textColor = .black
    $0.font = .init(name: MyFonts.medium.rawValue, size: 14)
  }
  
  private let infoLabel2 = UILabel().then {
    $0.text = "비밀번호 확인"
    $0.textColor = .black
    $0.font = .init(name: MyFonts.medium.rawValue, size: 14)
  }
  
  private let textCountConditionLabel = UILabel().then {
    $0.text = "•  8자 이상 입력"
    $0.textColor = .idorm_gray_400
    $0.font = .init(name: MyFonts.medium.rawValue, size: 12)
  }
  
  private let compoundConditionLabel = UILabel().then {
    $0.text = "•  영문 소문자/숫자/특수 문자 조합"
    $0.textColor = .idorm_gray_400
    $0.font = .init(name: MyFonts.medium.rawValue, size: 12)
  }
  
  private let textField1 = passwordTextField(placeholder: "비밀번호를 입력해주세요.")
  private let textField2 = passwordTextField(placeholder: "비밀번호를 한번 더 입력해주세요.")
  private var confirmButton: idormButton!
  
  private let viewModel: ConfirmPasswordViewModel
  private let vcType: RegisterVCTypes.ConfirmPasswordVCType
  
  // MARK: - LifeCycle
  
  init(_ vcType: RegisterVCTypes.ConfirmPasswordVCType) {
    self.vcType = vcType
    self.viewModel = ConfirmPasswordViewModel(vcType)
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  override func setupLayouts() {
    super.setupLayouts()
    [infoLabel, infoLabel2, textField1, textField2, confirmButton, textCountConditionLabel, compoundConditionLabel]
      .forEach { view.addSubview($0) }
  }
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .white
    
    switch vcType {
    case .signUp:
      navigationItem.title = "회원가입"
      self.confirmButton = idormButton("계속하기")
    case .findPW, .updatePW:
      navigationItem.title = "비밀번호 변경"
      self.confirmButton = idormButton("변경 완료")
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    infoLabel.snp.makeConstraints { make in
      make.top.leading.equalTo(view.safeAreaLayoutGuide).inset(24)
    }
    
    textField1.snp.makeConstraints { make in
      make.top.equalTo(infoLabel.snp.bottom).offset(8)
      make.leading.trailing.equalToSuperview().inset(24)
      make.height.equalTo(50)
    }
    
    textCountConditionLabel.snp.makeConstraints { make in
      make.top.equalTo(textField1.snp.bottom).offset(8)
      make.leading.equalToSuperview().inset(24)
    }
    
    compoundConditionLabel.snp.makeConstraints { make in
      make.top.equalTo(textCountConditionLabel.snp.bottom)
      make.leading.equalToSuperview().inset(24)
    }
    
    infoLabel2.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalTo(textCountConditionLabel.snp.bottom).offset(30)
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
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    // MARK: - Input
    
    // 텍스트필드1 반응
    textField1.textField.rx.text
      .orEmpty
      .bind(to: viewModel.input.passwordTf1DidChange)
      .disposed(by: disposeBag)
    
    textField1.textField.rx.controlEvent(.editingDidBegin)
      .bind(to: viewModel.input.passwordTf1DidBegin)
      .disposed(by: disposeBag)
    
    textField1.textField.rx.controlEvent(.editingDidEnd)
      .bind(to: viewModel.input.passwordTf1DidEnd)
      .disposed(by: disposeBag)
    
    // 텍스트필드2 반응
    textField2.textField.rx.text
      .orEmpty
      .bind(to: viewModel.input.passwordTf2DidChange)
      .disposed(by: disposeBag)
    
    textField2.textField.rx.controlEvent(.editingDidEnd)
      .bind(to: viewModel.input.passwordTf2DidEnd)
      .disposed(by: disposeBag)
    
    // 완료 버튼 클릭
    confirmButton.rx.tap
      .bind(to: viewModel.input.confirmButtonDidTap)
      .disposed(by: disposeBag)
    
    // MARK: - Output
    
    // 글자수 레이블 텍스트 컬러
    viewModel.output.textCountConditionLabelTextColor
      .bind(to: textCountConditionLabel.rx.textColor)
      .disposed(by: disposeBag)
    
    // 글자수 조합 레이블 텍스트 컬러
    viewModel.output.compoundConditionLabelTextColor
      .bind(to: compoundConditionLabel.rx.textColor)
      .disposed(by: disposeBag)
    
    // 텍스트필드 1 체크마크 숨김
    viewModel.output.isHiddenCheckmark
      .bind(to: textField1.checkmarkButton.rx.isHidden)
      .disposed(by: disposeBag)
    
    // 텍스트필드1 모서리 컬러
    viewModel.output.passwordTf1BorderColor
      .bind(to: textField1.layer.rx.borderColor)
      .disposed(by: disposeBag)
    
    // infoLabel 컬러
    viewModel.output.infoLabelTextColor
      .bind(to: infoLabel.rx.textColor)
      .disposed(by: disposeBag)
    
    // infoLabel2 텍스트
    viewModel.output.infoLabel2Text
      .bind(to: infoLabel2.rx.text)
      .disposed(by: disposeBag)
    
    // infoLabel2 택스트 컬러
    viewModel.output.infoLabel2TextColor
      .bind(to: infoLabel2.rx.textColor)
      .disposed(by: disposeBag)
    
    // 텍스트필드2 모서리 컬러
    viewModel.output.passwordTf2BorderColor
      .bind(to: textField2.layer.rx.borderColor)
      .disposed(by: disposeBag)

    // 에러 팝업 띄우기
    viewModel.output.presentPopupVC
      .bind(onNext: { [weak self] mention in
        let popupVC = PopupViewController(contents: mention)
        popupVC.modalPresentationStyle = .overFullScreen
        self?.present(popupVC, animated: false)
      })
      .disposed(by: disposeBag)
    
    // 비밀번호 변경 완료 시 로그인 페이지로 넘어가기
    viewModel.output.presentLoginVC
      .bind(onNext: { [weak self] in
        self?.navigationController?.popToRootViewController(animated: true)
      })
      .disposed(by: disposeBag)
    
    // 닉네임 변경 페이지로 이동
    viewModel.output.pushToConfirmNicknameVC
      .bind(onNext: { [weak self] in
        let viewController = NicknameViewController(.signUp)
        self?.navigationController?.pushViewController(viewController, animated: true)
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: - Helpers
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct ConfirmPasswordVC_PreView: PreviewProvider {
  static var previews: some View {
    ConfirmPasswordViewController(.signUp).toPreview()
  }
}
#endif

