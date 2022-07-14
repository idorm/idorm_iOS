//
//  OnboardingDetailTableViewCell.swift
//  idorm
//
//  Created by 김응철 on 2022/07/11.
//

import UIKit
import SnapKit
import RSKPlaceholderTextView

protocol OnboardingDetailTableViewCellDelegate: AnyObject {
    func textFieldIsEmptyFalse(index: Int)
    func textFieldIsEmptyTrue(index: Int)
}

enum OnboardingOptionalType {
    case Essential
    case Optional
    case Free
}

class OnboardingDetailTableViewCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "OnboardingDetailTableViewCell"
    var viewModel: OnboardingDetailViewModel?
    var index: Int = 0
    weak var delegate: OnboardingDetailTableViewCellDelegate?
    
    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 14.0, weight: .medium)
        
        return label
    }()
    
    lazy var optionalLabel: UILabel = {
        let label = UILabel()
        label.textColor = .mainColor
        label.text = "(필수)"
        label.font = .systemFont(ofSize: 14.0, weight: .medium)
        label.isHidden = true
        
        return label
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 10.0
        
        return view
    }()
    
    lazy var textField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "입력", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        tf.textColor = .black
        tf.font = .systemFont(ofSize: 14.0, weight: .medium)
        tf.addLeftPadding()
        tf.backgroundColor = .white
        tf.keyboardType = .default
        tf.returnKeyType = .done
        
        return tf
    }()
    
    lazy var textView: RSKPlaceholderTextView = {
        let tv = RSKPlaceholderTextView()
        tv.placeholder = "입력"
        tv.placeholderColor = .darkGray
        tv.font = .systemFont(ofSize: 14.0, weight: .medium)
        tv.textColor = .darkGray
        tv.delegate = self
        tv.keyboardType = .default
        tv.returnKeyType = .done
        tv.backgroundColor = .clear
        
        return tv
    }()
    
    lazy var textViewContainerView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 10.0
        view.isHidden = true
        
        return view
    }()
    
    lazy var bottomView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    lazy var letterNumLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.isHidden = true
        label.font = .systemFont(ofSize: 14.0, weight: .medium)
        
        return label
    }()
//    
    // MARK: - Selectors
    @objc private func textfieldDidChange(_ tf: UITextField) {
//        if textField.text?.isEmpty == false {
//            delegate?.textFieldIsEmptyFalse(index: index)
//        } else {
//            delegate?.textFieldIsEmptyTrue(index: index)
//        }
    }
    
    // MARK: - Helpers
    func configureUI(type: OnboardingOptionalType) {
        contentView.backgroundColor = .white
        guard let viewModel = viewModel else { return }
        
        if type == .Essential {
            optionalLabel.isHidden = false
        } else if type == .Optional {
            
        } else {
            textViewContainerView.isHidden = false
            letterNumLabel.isHidden = false
            containerView.isHidden = true
        }
        
        infoLabel.text = viewModel.question
        
        textViewContainerView.addSubview(textView)
        containerView.addSubview(textField)
        
        textField.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        [ infoLabel, optionalLabel, letterNumLabel, textViewContainerView, containerView ]
            .forEach { contentView.addSubview($0) }
        
        infoLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.top.equalToSuperview().inset(24.0)
        }
        
        optionalLabel.snp.makeConstraints { make in
            make.leading.equalTo(infoLabel.snp.trailing).offset(6.0)
            make.centerY.equalTo(infoLabel)
        }
        
        textViewContainerView.snp.makeConstraints { make in
            make.top.equalTo(infoLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(50.0)
        }

        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalTo(infoLabel.snp.bottom).offset(8)
            make.height.equalTo(50.0)
        }
        
        letterNumLabel.snp.makeConstraints { make in
            make.centerY.equalTo(infoLabel)
            make.trailing.equalToSuperview().inset(24)
        }
        
    }
}

extension OnboardingDetailTableViewCell: UITextViewDelegate {
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
