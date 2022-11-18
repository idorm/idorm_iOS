import UIKit

import SnapKit
import Then
import RxSwift
import RxCocoa

final class ConfirmNicknameViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let containerView = UIView().then {
    $0.backgroundColor = .white
  }
  
  private let mainLabel = UILabel().then {
    $0.text = "idorm 프로필 닉네임을 입력해주세요."
    $0.textColor = .idorm_gray_400
    $0.font = .init(name: MyFonts.regular.rawValue, size: 16)
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
  
  private lazy var descriptionStack = UIStackView().then { stack in
    [minimumLengthLabel, noSpacingLabel, noSpecialSymbolLabel]
      .forEach { stack.addArrangedSubview($0) }
    stack.axis = .horizontal
  }
  
  private let indicator = UIActivityIndicatorView()
  private let confirmButton = RegisterBottomButton("가입완료")
  private let textField = RegisterTextField("사용하실 닉네임을 입력해주세요.")
  private let minimumLengthLabel = RegisterUtilities.descriptionLabel(text: "•  최소 2글자에서 8글자를 입력해주세요.")
  private let noSpacingLabel = RegisterUtilities.descriptionLabel(text: "•  공백없이 입력해주세요.")
  private let noSpecialSymbolLabel = RegisterUtilities.descriptionLabel(text: "•  영문, 한글, 숫자만 입력할 수 있어요.")
  
  private let viewModel = ConfirmNicknameViewModel()
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .idorm_gray_100
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(containerView)
    [mainLabel, maxLengthLabel, currentLenghtLabel, confirmButton, textField, minimumLengthLabel, noSpacingLabel, noSpacingLabel]
      .forEach { containerView.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    containerView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(view.safeAreaLayoutGuide).inset(24)
      make.height.equalTo(320)
    }
    
    mainLabel.snp.makeConstraints { make in
      make.top.leading.equalToSuperview().inset(24)
    }
    
    maxLengthLabel.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(32)
      make.top.equalTo(mainLabel.snp.bottom).offset(24)
    }
    
    currentLenghtLabel.snp.makeConstraints { make in
      make.centerY.equalTo(maxLengthLabel)
      make.trailing.equalTo(maxLengthLabel.snp.leading).offset(2)
    }
    
    textField.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(currentLenghtLabel.snp.bottom).offset(8)
      make.height.equalTo(50)
    }
    
    descriptionStack.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(textField.snp.bottom).offset(8)
    }
    
    confirmButton.snp.makeConstraints { make in
      make.bottom.leading.trailing.equalToSuperview().inset(24)
      make.height.equalTo(50)
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    // MARK: - Input
    
    // 텍스트 변화 감지 & 텍스트 글자수 제한
    textField.rx.text
      .orEmpty
      .scan("") { [weak self] previous, new in
        let length: String
        if new.count > 8 {
          length = previous
        } else if new.count < 2 {
          self?.confirmButton.isEnabled = false
          length = new
        } else {
          self?.confirmButton.isEnabled = true
          length = new
        }
        return length
      }
      .bind(to: viewModel.input.textFieldDidChange)
      .disposed(by: disposeBag)
    
    // 가입완료 버튼 클릭 이벤트
    confirmButton.rx.tap
      .map { [weak self] in self?.textField.text ?? "" }
      .bind(to: viewModel.input.confirmButtonDidTap)
      .disposed(by: disposeBag)
    
    // MARK: - Output
    
    // 현재 텍스트 길이
    viewModel.output.currentLength
      .bind(onNext: { [weak self] in
        self?.currentLenghtLabel.text = "\($0)"
      })
      .disposed(by: disposeBag)
    
    // 인디케이터 제어
    viewModel.output.indicatorState
      .bind(onNext: { [weak self] in
        if $0 {
          self?.indicator.startAnimating()
          self?.view.isUserInteractionEnabled = false
        } else {
          self?.indicator.stopAnimating()
          self?.view.isUserInteractionEnabled = true
        }
      })
      .disposed(by: disposeBag)
  }
}
