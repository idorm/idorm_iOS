//
//  OnboardingDetailTableViewCell.swift
//  idorm
//
//  Created by 김응철 on 2022/07/11.
//

import UIKit
import SnapKit
import RSKGrowingTextView
import RxSwift
import RxCocoa

class OnboardingTableViewCell: UITableViewCell {
  // MARK: - Properties
  static let identifier = "OnboardingDetailTableViewCell"
  var type: OnboardingListType = .wakeup
  var disposeBag = DisposeBag()
  var onChangedTextSubject = PublishSubject<(String, OnboardingListType)>()
  
  let textField = OnboardingTextFieldContainerView(placeholder: "입력")
  
  lazy var infoLabel: UILabel = {
    let label = UILabel()
    label.textColor = .idorm_gray_400
    label.font = .init(name: Font.medium.rawValue, size: 14)
    
    return label
  }()
  
  lazy var optionalLabel: UILabel = {
    let label = UILabel()
    label.textColor = .idorm_blue
    label.text = "(필수)"
    label.font = .init(name: Font.regular.rawValue, size: 14)
    label.isHidden = true
    
    return label
  }()
  
  lazy var textView: RSKGrowingTextView = {
    let tv = RSKGrowingTextView()
    tv.attributedPlaceholder = NSAttributedString(string: "입력", attributes: [NSAttributedString.Key.font: UIFont.init(name: Font.regular.rawValue, size: 14) ?? 0, NSAttributedString.Key.foregroundColor: UIColor.idorm_gray_300])
    tv.font = .init(name: Font.regular.rawValue, size: 14)
    tv.textColor = .black
    tv.layer.cornerRadius = 10
    tv.layer.borderColor = UIColor.idorm_gray_300.cgColor
    tv.layer.borderWidth = 1
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
    label.textColor = .idorm_gray_300
    label.isHidden = true
    label.font = .init(name: Font.medium.rawValue, size: 14)
    
    return label
  }()
  
  // MARK: - LifeCycle
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Selectors
  
  // MARK: - Helpers
  func configureUI(type: OnboardingListType, question: String) {
    contentView.backgroundColor = .white
    infoLabel.text = question
    self.type = type
    
    [ infoLabel, optionalLabel, textField, letterNumLabel, textView ]
      .forEach { contentView.addSubview($0) }
    
    switch type {
    case .wakeup, .shower, .cleanup:
      optionalLabel.isHidden = false
    case .wishText:
      textField.isHidden = true
      textView.isHidden = false
      letterNumLabel.isHidden = false
    case .mbti, .chatLink:
      textField.isHidden = false
      textView.isHidden = true
      letterNumLabel.isHidden = true
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
  
  private func bind() {
    textField.textField.rx.text
      .orEmpty
      .bind(onNext: { [weak self] text in
        guard let self = self else { return }
        self.onChangedTextSubject.onNext((text, self.type))
      })
      .disposed(by: disposeBag)
    
    textView.rx.text
      .orEmpty
      .scan("") { previous, new in
        if new.count > 100 {
          return previous
        } else {
          return new
        }
      }
      .asDriver(onErrorJustReturn: "")
      .drive(onNext: { [weak self] text in
        self?.textView.text = text
        
        self?.letterNumLabel.text = "\(self?.textView.text.count ?? 0)/100pt"
        
        let attributedString = NSMutableAttributedString(string: "\(self?.textView.text.count ?? 0)/100pt")
        attributedString.addAttribute(.foregroundColor, value: UIColor.idorm_blue, range: ("\(self?.textView.text.count ?? 0)/100pt" as NSString).range(of: "\(self?.textView.text.count ?? 0)"))
        self?.letterNumLabel.attributedText = attributedString
      })
      .disposed(by: disposeBag)
    
    textField.xmarkButton.rx.tap
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        self.textField.textField.rx.text.onNext("")
        self.textField.xmarkButton.isHidden = true
        self.textField.becomeFirstResponder()
        self.onChangedTextSubject.onNext(("", self.type))
      })
      .disposed(by: disposeBag)
  }
}
