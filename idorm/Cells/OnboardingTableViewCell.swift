//
//  OnboardingTableViewCell.swift
//  idorm
//
//  Created by 김응철 on 2022/07/08.
//

import UIKit
import SnapKit

enum OnboardingCellType {
    case ox
    case gender
    case period
    case age
}

protocol OnboardingTableViewCellDelegate: AnyObject {
    func didTapXmarkButton(type: OnboardingCellType, index: Int)
    func didTapOmarkButton(type: OnboardingCellType, index: Int)
}

class OnboardingTableViewCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "OnboardingTableViewCell"
    var viewModel: OnboardingViewModel?
    var index: Int = 0
    var type: OnboardingCellType = .ox
    weak var delegate: OnboardingTableViewCellDelegate?
    
    lazy var questionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = .systemFont(ofSize: 16.0)
        
        return label
    }()
    
    lazy var leftButton: UIButton = {
        let button = UIButton(type: .custom)
        button.tintColor = UIColor.init(rgb: 0xE3E1EC)
        button.setTitleColor(UIColor.init(rgb: 0xE3E1EC), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16.0, weight: .bold)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: 20.0), forImageIn: .normal)
        button.addTarget(self, action: #selector(didTapLeftButton), for: .touchUpInside)
        
        return button
    }()
    
    lazy var rightButton: UIButton = {
        let button = UIButton(type: .custom)
        button.tintColor = UIColor.init(rgb: 0xE3E1EC)
        button.setTitleColor(UIColor.init(rgb: 0xE3E1EC), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16.0, weight: .bold)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: 20.0), forImageIn: .normal)
        button.addTarget(self, action: #selector(didTapRightButton), for: .touchUpInside)
        
        return button
    }()
    
    lazy var ageTextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = UIColor.init(rgb: 0xF4F2FA)
        tf.textColor = .mainColor
        tf.font = .systemFont(ofSize: 16.0, weight: .medium)
        tf.textAlignment = .center
        tf.layer.cornerRadius = 8.0
        tf.keyboardType = .numberPad
        tf.delegate = self
        
        return tf
    }()
    
    lazy var ageLabel: UILabel = {
        let label = UILabel()
        label.text = "세"
        label.font = .systemFont(ofSize: 16.0, weight: .bold)
        label.textColor = .gray
        label.setContentHuggingPriority(.init(rawValue: 251), for: .horizontal)
        
        return label
    }()
    
    // MARK: - Selectors
    @objc private func didTapLeftButton(_ button: UIButton) {
        leftButton.isSelected = true
        leftButton.tintColor = .mainColor
        leftButton.setTitleColor(UIColor.mainColor, for: .normal)
        rightButton.isSelected = false
        rightButton.tintColor = .init(rgb: 0xE3E1EC)
        rightButton.setTitleColor(UIColor.init(rgb: 0xE3E1EC), for: .normal)
        delegate?.didTapXmarkButton(type: .ox, index: index)
    }
    
    @objc private func didTapRightButton(_ button: UIButton) {
        leftButton.isSelected = false
        leftButton.tintColor = .init(rgb: 0xE3E1EC)
        leftButton.setTitleColor(UIColor.init(rgb: 0xE3E1EC), for: .normal)
        rightButton.isSelected = true
        rightButton.tintColor = .mainColor
        rightButton.setTitleColor(UIColor.mainColor, for: .normal)
        delegate?.didTapOmarkButton(type: .ox, index: index)
    }
    
    // MARK: - Helpers
    func configureUI(type: OnboardingCellType) {
        self.type = type
        contentView.backgroundColor = .white
        guard let viewModel = viewModel else { return }
        questionLabel.text = viewModel.question
        
        let buttonStack = UIStackView(arrangedSubviews: [ leftButton, rightButton ])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 20.0
        buttonStack.alignment = .leading

        let ageStack = UIStackView(arrangedSubviews: [ ageTextField, ageLabel ])
        ageStack.axis = .horizontal
        ageStack.spacing = 22.0
        ageStack.alignment = .leading
        ageStack.isHidden = true
        
        [ questionLabel, buttonStack, ageStack ]
            .forEach { contentView.addSubview($0) }
        
        questionLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
        }
        
        buttonStack.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview().inset(8.0)
            make.width.equalTo(90.0)
        }
        
        ageStack.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview().inset(8.0)
            make.width.equalTo(90.0)
        }
        
        ageTextField.snp.makeConstraints { make in
            make.width.equalTo(48.0)
            make.height.equalTo(26)
        }
        
        ageLabel.snp.makeConstraints { make in
            make.centerY.equalTo(ageTextField)
        }
        
        if type == .ox {
            leftButton.setImage(UIImage(systemName: "xmark"), for: .normal)
            rightButton.setImage(UIImage(systemName: "circle"), for: .normal)
            buttonStack.spacing = 20.0
        } else if type == .gender {
            leftButton.setTitle("여성", for: .normal)
            rightButton.setTitle("남성", for: .normal)
            buttonStack.spacing = 21.0
        } else if type == .period {
            leftButton.setTitle("24주", for: .normal)
            rightButton.setTitle("16주", for: .normal)
        } else {
            buttonStack.isHidden = true
            ageStack.isHidden = false
        }
    }
}

extension OnboardingTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 2
    }
}

