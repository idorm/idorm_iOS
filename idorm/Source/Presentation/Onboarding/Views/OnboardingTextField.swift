import UIKit

import SnapKit
import Then
import RxSwift
import RxCocoa

class OnboardingTextField: UIView {
  
  // MARK: - Properties
  
  lazy var textField = UITextField().then {
    $0.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
      NSAttributedString.Key.foregroundColor: UIColor.idorm_gray_300,
      NSAttributedString.Key.font: UIFont.init(name: MyFonts.medium.rawValue, size: 14.0) ?? 0
    ])
    $0.textColor = .black
    $0.font = .init(name: MyFonts.medium.rawValue, size: 14.0)
    $0.addLeftPadding(16)
    $0.backgroundColor = .white
    $0.keyboardType = .default
    $0.returnKeyType = .done
  }
  
  let checkmarkButton = UIButton().then {
    $0.setImage(UIImage(named: "Checkmark"), for: .normal)
    $0.isHidden = true
  }
  
  let xmarkButton = UIButton().then {
    $0.setImage(UIImage(named: "Xmark_Grey"), for: .normal)
    $0.isHidden = true
  }
  
  let placeholder: String
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
    [ textField, checkmarkButton, xmarkButton ]
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
    textField.rx.text.orEmpty
      .scan("") { pervious, new -> String in
        if new.count >= 30 {
          return pervious
        } else {
          return new
        }
      }
      .asDriver(onErrorJustReturn: "")
      .drive(textField.rx.text)
      .disposed(by: disposeBag)
    
    // 입력 반응 -> X버튼 활성화
    textField.rx.controlEvent(.editingChanged)
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
    
    // 입력 종료 -> 테두리 Color 변경 & 체크 버튼 활성/비활성화
    textField.rx.controlEvent(.editingDidEnd)
      .asDriver()
      .drive(onNext: { [weak self] in
        let text = self?.textField.text ?? ""
        self?.layer.borderColor = UIColor.idorm_gray_300.cgColor
        self?.xmarkButton.isHidden = true
        if text.count >= 1 {
          self?.checkmarkButton.isHidden = false
        } else {
          self?.checkmarkButton.isHidden = true
        }
      })
      .disposed(by: disposeBag)
    
    // X버튼 클릭 -> 텍스트 모두 지우기
    xmarkButton.rx.tap
      .bind(onNext: { [unowned self] in
        self.textField.text = ""
      })
      .disposed(by: disposeBag)
  }
}
