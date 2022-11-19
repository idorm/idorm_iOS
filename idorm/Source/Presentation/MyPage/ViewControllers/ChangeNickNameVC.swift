import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

final class ChangeNicknameViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let mainLabel = UILabel().then {
    $0.text = "idorm 프로필 닉네임을 입력해주세요."
    $0.textColor = .idorm_gray_400
    $0.font = .init(name: MyFonts.regular.rawValue, size: 16)
  }
  
  private let textField = RegisterTextField("변경할 닉네임을 입력해주세요.")
  
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
  
  private let indicator = UIActivityIndicatorView()
  private let viewModel = ChangeNicknameViewModel()
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    view.backgroundColor = .idorm_gray_100
    navigationItem.title = "닉네임"
    confirmButton.isEnabled = false
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [backgroundView, mainLabel, maxLengthLabel, textField, confirmButton, currentLenghtLabel, indicator]
      .forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    backgroundView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(view.safeAreaLayoutGuide).inset(24)
      make.height.equalTo(250)
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
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(textField.snp.bottom).offset(24)
      make.height.equalTo(52)
    }
    
    currentLenghtLabel.snp.makeConstraints { make in
      make.centerY.equalTo(maxLengthLabel)
      make.trailing.equalTo(maxLengthLabel.snp.leading).offset(-4)
    }
    
    indicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    // MARK: - Input
    
    // 텍스트 글자수 제한 & 현재 글자수 보이기
    textField.rx.text
      .orEmpty
      .scan("") { [unowned self] previous, new -> String in
        let length: String
        if new.count > 8 {
          length = previous
        } else if new.count < 2 {
          self.confirmButton.isEnabled = false
          length = new
        } else {
          self.confirmButton.isEnabled = true
          length = new
        }
        self.currentLenghtLabel.text = "\(length.count)"
        return length
      }
      .bind(to: textField.rx.text)
      .disposed(by: disposeBag)
    
    // 완료 버튼 클릭 이벤트
    confirmButton.rx.tap
      .map { [unowned self] in self.textField.text ?? "" }
      .bind(to: viewModel.input.confirmButtonTapped)
      .disposed(by: disposeBag)
    
    // MARK: - Output
    
    // 뒤로가기
    viewModel.output.popVC
      .bind(onNext: { [weak self] in
        self?.navigationController?.popViewController(animated: true)
      })
      .disposed(by: disposeBag)
    
    // 완료 버튼 활성 & 비활성
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
  
  // MARK: - Helpers
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
}

// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct ChangeNicknameVC_PreView: PreviewProvider {
  static var previews: some View {
      ChangeNicknameViewController().toPreview()
  }
}
#endif
