//
//  OnboardingDetailTableViewCell.swift
//  idorm
//
//  Created by 김응철 on 2022/07/11.
//

import UIKit
import SnapKit
import RSKGrowingTextView

class OnboardingTableViewCell: UITableViewCell {
  // MARK: - Properties
  static let identifier = "OnboardingDetailTableViewCell"
  
  var onChangedTextField: ((String) -> Void)?
  
  lazy var textField: OnboardingTextFieldContainerView = {
    let textField = OnboardingTextFieldContainerView(placeholder: "입력")
    textField.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    
    return textField
  }()
  
  lazy var infoLabel: UILabel = {
    let label = UILabel()
    label.textColor = .darkgrey_custom
    label.font = .init(name: Font.medium.rawValue, size: 14)
    
    return label
  }()
  
  lazy var optionalLabel: UILabel = {
    let label = UILabel()
    label.textColor = .mainColor
    label.text = "(필수)"
    label.font = .init(name: Font.regular.rawValue, size: 14)
    label.isHidden = true
    
    return label
  }()
  
  lazy var textView: RSKGrowingTextView = {
    let tv = RSKGrowingTextView()
    tv.attributedPlaceholder = NSAttributedString(string: "입력", attributes: [NSAttributedString.Key.font: UIFont.init(name: Font.regular.rawValue, size: 14) ?? 0, NSAttributedString.Key.foregroundColor: UIColor.grey_custom])
    tv.font = .init(name: Font.regular.rawValue, size: 14)
    tv.textColor = .black
    tv.layer.cornerRadius = 10
    tv.layer.borderColor = UIColor.grey_custom.cgColor
    tv.layer.borderWidth = 1
    tv.delegate = self
    tv.isScrollEnabled = false
    tv.keyboardType = .default
    tv.returnKeyType = .done
    tv.backgroundColor = .clear
    tv.isHidden = true
    tv.textContainerInset = UIEdgeInsets(top: 15, left: 9, bottom: 15, right: 9)
    
    return tv
  }()
  
  lazy var letterNumLabel: UILabel = {
    let label = UILabel()
    label.textColor = .grey_custom
    label.isHidden = true
    label.font = .init(name: Font.medium.rawValue, size: 14)
    
    return label
  }()
  
  // MARK: - LifeCycle
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Selectors
  @objc private func textFieldDidChange(_ tf: UITextField) {
    guard let changedText = tf.text else { return }
    onChangedTextField?(changedText)
  }
  
  // MARK: - Helpers
  func configureUI(type: OnboardingOptionalType, question: String) {
    contentView.backgroundColor = .white
    infoLabel.text = question
    
    [ infoLabel, optionalLabel, textField, letterNumLabel, textView ]
      .forEach { contentView.addSubview($0) }
    
    switch type {
    case .essential:
      optionalLabel.isHidden = false
    case .optional:
      break
    case .free:
      textField.isHidden = true
      textView.isHidden = false
      letterNumLabel.isHidden = false
    }

    infoLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalToSuperview()
    }

    textField.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(infoLabel.snp.bottom).offset(8)
      make.height.equalTo(50.0)
      make.bottom.equalToSuperview().inset(36)
    }
    
    optionalLabel.snp.makeConstraints { make in
      make.leading.equalTo(infoLabel.snp.trailing).offset(6.0)
      make.centerY.equalTo(infoLabel)
    }
    
    letterNumLabel.snp.makeConstraints { make in
      make.centerY.equalTo(infoLabel)
      make.trailing.equalToSuperview().inset(24)
    }
    
    textView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(infoLabel.snp.bottom).offset(8)
    }
  }
}

extension OnboardingTableViewCell: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    if textView.text.count > 100 {
      textView.deleteBackward()
    }
    
    letterNumLabel.text = "\(textView.text.count)/100pt"
    
    let attributedString = NSMutableAttributedString(string: "\(textView.text.count)/100pt")
    attributedString.addAttribute(.foregroundColor, value: UIColor.mainColor, range: ("\(textView.text.count)/100pt" as NSString).range(of: "\(textView.text.count)"))
    letterNumLabel.attributedText = attributedString
  }
}
