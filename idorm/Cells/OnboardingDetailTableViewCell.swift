//
//  OnboardingDetailTableViewCell.swift
//  idorm
//
//  Created by 김응철 on 2022/07/11.
//

import UIKit
import SnapKit

protocol OnboardingDetailTableViewCellDelegate: AnyObject {
    func textFieldIsEmptyFalse(index: Int)
    func textFieldIsEmptyTrue(index: Int)
}

class OnboardingDetailTableViewCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "OnboardingDetailTableViewCell"
    var viewModel: OnboardingDetailViewModel?
    var index: Int = 0
    weak var delegate: OnboardingDetailTableViewCellDelegate?
    
    lazy var textField: UITextField = {
        let tf = UITextField()
        tf.textColor = .black
        tf.font = .systemFont(ofSize: 16.0)
        tf.addTarget(self, action: #selector(textfieldDidChange(_:)), for: .editingChanged)
        
        return tf
    }()
    
    // MARK: - Selectors
    @objc private func textfieldDidChange(_ tf: UITextField) {
        if textField.text?.isEmpty == false {
            delegate?.textFieldIsEmptyFalse(index: index)
        } else {
            delegate?.textFieldIsEmptyTrue(index: index)
        }
    }
    
    // MARK: - Helpers
    func configureUI() {
        contentView.backgroundColor = .white
        guard let viewModel = viewModel else { return }
        
        textField.attributedPlaceholder = NSAttributedString(string: viewModel.question, attributes: [.foregroundColor: UIColor.gray])
        
        contentView.addSubview(textField)
        
        textField.snp.makeConstraints { make in
            make.centerY.leading.trailing.equalToSuperview()
            make.height.equalTo(24.0)
        }
    }
}
