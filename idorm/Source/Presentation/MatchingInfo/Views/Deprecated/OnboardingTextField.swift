import UIKit

import SnapKit
import Then
import RxSwift
import RxCocoa

final class OnboardingTextField: UIView {
  
  // MARK: - Properties
  
  lazy var textField = UITextField().then {
    $0.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
      NSAttributedString.Key.foregroundColor: UIColor.idorm_gray_300,
      NSAttributedString.Key.font: UIFont.init(name: IdormFont_deprecated.medium.rawValue, size: 14.0) ?? 0
    ])
    $0.textColor = .black
    $0.font = .init(name: IdormFont_deprecated.regular.rawValue, size: 14.0)
    $0.addLeftPadding(16)
    $0.backgroundColor = .white
    $0.keyboardType = .default
    $0.returnKeyType = .continue
  }
  
  let checkmarkButton = UIButton().then {
    $0.setImage(UIImage(named: "circle_checkmark_blue"), for: .normal)
    $0.isHidden = true
  }
  
  let xmarkButton = UIButton().then {
    $0.setImage(UIImage(named: "circle_xmark_gray"), for: .normal)
    $0.isHidden = true
  }
  
  let placeholder: String
  var isDefault: Bool = true
  private var disposeBag = DisposeBag()
  
  // MARK: - LifeCycle
  
  init(placeholder: String) {
    self.placeholder = placeholder
    super.init(frame: .zero)
    setupStyles()
    setupLayout()
    setupConstraints()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  private func setupLayout() {
    
    [
      textField,
      checkmarkButton,
      xmarkButton
    ]
      .forEach { addSubview($0) }
  }
  
  private func setupStyles() {
    backgroundColor = .white
    layer.borderWidth = 1
    layer.cornerRadius = 10
    layer.borderColor = UIColor.idorm_gray_300.cgColor
  }
  
  private func setupConstraints() {
    textField.snp.makeConstraints { make in
      make.leading.bottom.top.equalToSuperview()
      make.trailing.equalToSuperview().inset(40)
    }
    
    checkmarkButton.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().inset(8)
    }
    
    xmarkButton.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().inset(8)
    }
  }
  
  // MARK: - Bind

  private func bind() {
    
    // 글자 수 30자 제한
    textField.rx.text
      .orEmpty
      .scan("") { [weak self] previous, new -> String in
        guard let self = self else { return "" }
        if self.isDefault {
          if new.count >= 30 {
            return previous
          } else {
            return new
          }
        } else {
          if new.count >= 50 {
            return previous
          } else {
            return new
          }
        }
      }
      .asDriver(onErrorJustReturn: "")
      .drive(textField.rx.text)
      .disposed(by: disposeBag)
    
    // 입력 반응 -> X버튼 활성화
    textField.rx.controlEvent(.editingDidBegin)
      .asDriver()
      .drive(onNext: { [weak self] in
        self?.xmarkButton.isHidden = false
      })
      .disposed(by: disposeBag)
    
    // 입력 시작 -> 테두리 Color 변경 & 체크 버튼 숨기기
    textField.rx.controlEvent(.editingDidBegin)
      .asDriver()
      .drive(onNext: { [weak self] in
        self?.checkmarkButton.isHidden = true
        self?.layer.borderColor = UIColor.idorm_blue.cgColor
      })
      .disposed(by: disposeBag)
    
    textField.rx.controlEvent(.editingDidEnd)
      .map { true }
      .bind(to: xmarkButton.rx.isHidden)
      .disposed(by: disposeBag)
        
    textField.rx.controlEvent(.editingDidEnd)
      .withUnretained(self)
      .filter { $0.0.isDefault }
      .bind {
        let text = $0.0.textField.text ?? ""
        if text.count >= 1 {
          $0.0.checkmarkButton.isHidden = false
        } else {
          $0.0.checkmarkButton.isHidden = true
        }
        $0.0.layer.borderColor = UIColor.idorm_gray_300.cgColor
        $0.0.xmarkButton.isHidden = true
      }
      .disposed(by: disposeBag)
    
    // X버튼 클릭 -> 텍스트 모두 지우기
    xmarkButton.rx.tap
      .bind(onNext: { [weak self] in
        self?.textField.text = ""
        self?.textField.sendActions(for: .valueChanged)
      })
      .disposed(by: disposeBag)
  }
}
