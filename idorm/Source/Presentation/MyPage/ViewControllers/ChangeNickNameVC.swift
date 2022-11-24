import UIKit

import SnapKit
import Then
import RxSwift
import RxCocoa

final class ChangeNicknameViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let mainLabel = UILabel().then {
    $0.text = "idorm 프로필 닉네임을 입력해주세요."
    $0.textColor = .idorm_gray_400
    $0.font = .init(name: MyFonts.regular.rawValue, size: 16)
  }
  
  private let textField = idormTextField("변경할 닉네임을 입력해주세요.")
  
  private let confirmButton = RegisterBottomButton("완료")
  
  private let backgroundView = UIView().then {
    $0.backgroundColor = .white
  }
  
  private let maxLengthLabel = UILabel().then {
    $0.text = "/ 8 pt"
    $0.textColor = .idorm_gray_300
    $0.font = .init(name: MyFonts.medium.rawValue, size: 14)
  }
    
  private let currentLenghtLabel = UILabel().then {
    $0.text = "0"
    $0.textColor = .idorm_blue
    $0.font = .init(name: MyFonts.medium.rawValue, size: 14)
  }
  
  private let indicator = UIActivityIndicatorView().then {
    $0.color = .gray
  }
  
  private let countConditionLabel = MyPageUtilities.descriptionLabel(text: "•  최소 2글자에서 8글자를 입력해주세요.")
  private let spacingConditionLabel = MyPageUtilities.descriptionLabel(text: "•  공백없이 입력해주세요.")
  private let textConditionLabel = MyPageUtilities.descriptionLabel(text: "•  영문, 한글, 숫자만 입력할 수 있어요.")
  
  private lazy var descriptionStackView = UIStackView().then { stack in
    [countConditionLabel, spacingConditionLabel, textConditionLabel]
      .forEach { stack.addArrangedSubview($0) }
    stack.axis = .vertical
  }
  
  private let viewModel = ChangeNicknameViewModel()
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    view.backgroundColor = .idorm_gray_100
    navigationItem.title = "닉네임"
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    view.addSubview(backgroundView)
    [mainLabel, maxLengthLabel, textField, confirmButton, currentLenghtLabel, descriptionStackView, indicator]
      .forEach { backgroundView.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    backgroundView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(view.safeAreaLayoutGuide).inset(24)
      make.height.equalTo(320)
    }
    
    mainLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalTo(view.safeAreaLayoutGuide).inset(48)
    }
    
    maxLengthLabel.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(24)
      make.top.equalTo(mainLabel.snp.bottom).offset(24)
    }
    
    textField.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(maxLengthLabel.snp.bottom).offset(8)
      make.height.equalTo(50)
    }
    
    confirmButton.snp.makeConstraints { make in
      make.bottom.leading.trailing.equalToSuperview().inset(24)
      make.height.equalTo(52)
    }
    
    currentLenghtLabel.snp.makeConstraints { make in
      make.centerY.equalTo(maxLengthLabel)
      make.trailing.equalTo(maxLengthLabel.snp.leading).offset(-4)
    }
    
    descriptionStackView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalTo(textField.snp.bottom).offset(8)
    }
    
    indicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  
  // MARK: - Bind
      
  override func bind() {
    super.bind()

    // MARK: - Input
    
    // 텍스트 변화 감지
    textField.rx.text
      .orEmpty
      .bind(to: viewModel.input.textDidChange)
      .disposed(by: disposeBag)
    
    // 완료 버튼 클릭
    confirmButton.rx.tap
      .bind(to: viewModel.input.confirmButtonDidTap)
      .disposed(by: disposeBag)
    
    // 텍스트필드 포커싱 종료
    textField.rx.controlEvent(.editingDidEnd)
      .bind(to: viewModel.input.textFieldEditingDidEnd)
      .disposed(by: disposeBag)
    
    // 텍스트필드 포커싱 시작
    textField.rx.controlEvent(.editingDidBegin)
      .bind(to: viewModel.input.textFieldEditingDidBegin)
      .disposed(by: disposeBag)
    
    // MARK: - Output
    
    // 현재 글자수
    viewModel.output.currentTextCount
      .map { String($0) }
      .bind(to: currentLenghtLabel.rx.text)
      .disposed(by: disposeBag)
    
    // 현재 텍스트
    viewModel.output.currentText
      .bind(to: textField.rx.text)
      .disposed(by: disposeBag)

    // 글자 수 레이블 컬러
    viewModel.output.countConditionLabelTextColor
      .bind(to: countConditionLabel.rx.textColor)
      .disposed(by: disposeBag)
    
    // 공백 레이블 컬러
    viewModel.output.spacingConditionLabelTextColor
      .bind(to: spacingConditionLabel.rx.textColor)
      .disposed(by: disposeBag)

    // 특수문자 레이블 컬러
    viewModel.output.textConditionLabelTextColor
      .bind(to: textConditionLabel.rx.textColor)
      .disposed(by: disposeBag)
    
    // 오류 팝업
    viewModel.output.presentPopupVC
      .bind(onNext: { [weak self] in
        let viewController = PopupViewController(contents: $0)
        viewController.modalPresentationStyle = .overFullScreen
        self?.present(viewController, animated: false)
      })
      .disposed(by: disposeBag)
    
    // 뒤로가기
    viewModel.output.popVC
      .bind(onNext: { [weak self] in
        self?.navigationController?.popViewController(animated: true)
      })
      .disposed(by: disposeBag)
    
    // 로딩 중
    viewModel.output.isLoading
      .bind(to: indicator.rx.isAnimating)
      .disposed(by: disposeBag)
    
    // 체크마크 숨김처리
    viewModel.output.isHiddenCheckmark
      .bind(to: textField.checkmarkButton.rx.isHidden)
      .disposed(by: disposeBag)
    
    // 텍스트 필드 모서리 컬러
    viewModel.output.textFieldBorderColor
      .bind(to: textField.layer.rx.borderColor)
      .disposed(by: disposeBag)
  }
  
  // MARK: - Helpers
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
}

