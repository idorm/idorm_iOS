//
//  OnboardingTableViewCell.swift
//  idorm
//
//  Created by 김응철 on 2022/07/08.
//

import UIKit
import SnapKit

protocol OnboardingTableViewCellDelegate: AnyObject {
    func didTapXmarkButton()
    func didTapOmarkButton()
}

class OnboardingTableViewCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "OnboardingTableViewCell"
    var viewModel: OnboardingViewModel?
    weak var delegate: OnboardingTableViewCellDelegate?
    
    lazy var questionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = .systemFont(ofSize: 18.0)
        
        return label
    }()
    
    lazy var xmarkButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .gray
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: 24.0), forImageIn: .normal)
        button.addTarget(self, action: #selector(didTapXmarkButton), for: .touchUpInside)
        
        return button
    }()
    
    lazy var omarkButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.tintColor = .gray
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: 24.0), forImageIn: .normal)
        button.addTarget(self, action: #selector(didTapOmarkButton), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - Selectors
    @objc private func didTapXmarkButton(_ button: UIButton) {
        xmarkButton.isSelected = true; xmarkButton.tintColor = .blue
        omarkButton.isSelected = false; omarkButton.tintColor = .gray
        delegate?.didTapXmarkButton()
    }
    
    @objc private func didTapOmarkButton(_ button: UIButton) {
        xmarkButton.isSelected = false; xmarkButton.tintColor = .gray
        omarkButton.isSelected = true; omarkButton.tintColor = .blue
        delegate?.didTapOmarkButton()
    }
    
    // MARK: - Helpers
    func configureUI() {
        contentView.backgroundColor = .white
        guard let viewModel = viewModel else { return }
        questionLabel.text = viewModel.question
        
        let buttonStack = UIStackView(arrangedSubviews: [ xmarkButton, omarkButton ])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 32.0
        
        [ questionLabel, buttonStack ]
            .forEach { contentView.addSubview($0) }
        
        questionLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(16)
        }
        
        buttonStack.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(32)
        }
    }
}
