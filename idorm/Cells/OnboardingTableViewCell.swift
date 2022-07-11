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
    weak var delegate: OnboardingTableViewCellDelegate?
    
    lazy var questionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = .systemFont(ofSize: 16.0)
        
        return label
    }()
    
    lazy var xmarkButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = UIColor.init(rgb: 0xE3E1EC)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: 24.0), forImageIn: .normal)
        button.addTarget(self, action: #selector(didTapXmarkButton), for: .touchUpInside)
        
        return button
    }()
    
    lazy var omarkButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.tintColor = UIColor.init(rgb: 0xE3E1EC)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: 24.0), forImageIn: .normal)
        button.addTarget(self, action: #selector(didTapOmarkButton), for: .touchUpInside)
        
        return button
    }()
    
    lazy var maleButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("남성", for: .normal)
        button.setTitleColor(UIColor.init(rgb: 0xE3E1EC), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16.0)
        button.addTarget(self, action: #selector(didTapMaleButton), for: .touchUpInside)
        
        return button
    }()
    
    lazy var femaleButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("여성", for: .normal)
        button.setTitleColor(UIColor.init(rgb: 0xE3E1EC), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16.0)
        button.addTarget(self, action: #selector(didTapFemaleButton), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - Selectors
    @objc private func didTapXmarkButton(_ button: UIButton) {
        xmarkButton.isSelected = true; xmarkButton.tintColor = .mainColor
        omarkButton.isSelected = false; omarkButton.tintColor = .init(rgb: 0xE3E1EC)
        delegate?.didTapXmarkButton(type: .ox, index: index)
    }
    
    @objc private func didTapOmarkButton(_ button: UIButton) {
        xmarkButton.isSelected = false; xmarkButton.tintColor = .init(rgb: 0xE3E1EC)
        omarkButton.isSelected = true; omarkButton.tintColor = .mainColor
        delegate?.didTapOmarkButton(type: .ox, index: index)
    }
    
    @objc private func didTapMaleButton() {
        maleButton.isSelected = true; maleButton.setTitleColor(UIColor.mainColor, for: .normal)
        femaleButton.isSelected = false; femaleButton.setTitleColor(UIColor.init(rgb: 0xE3E1EC), for: .normal)
        delegate?.didTapOmarkButton(type: .gender, index: index)
    }
    
    @objc private func didTapFemaleButton() {
        maleButton.isSelected = false; maleButton.setTitleColor(UIColor.init(rgb: 0xE3E1EC), for: .normal)
        femaleButton.isSelected = true; femaleButton.setTitleColor(UIColor.mainColor, for: .normal)
        delegate?.didTapXmarkButton(type: .gender, index: index)
    }
    
    // MARK: - Helpers
    func configureUI(type: OnboardingCellType) {
        contentView.backgroundColor = .white
        guard let viewModel = viewModel else { return }
        questionLabel.text = viewModel.question
        
        let buttonStack = UIStackView(arrangedSubviews: [ xmarkButton, omarkButton ])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 32.0
        
        let genderStack = UIStackView(arrangedSubviews: [ femaleButton, maleButton ])
        genderStack.axis = .horizontal
        genderStack.spacing = 14.0
        
        if type == .ox {
            [ questionLabel, buttonStack ]
                .forEach { contentView.addSubview($0) }
            
            xmarkButton.snp.makeConstraints { make in
                make.height.width.equalTo(20)
            }
            
            omarkButton.snp.makeConstraints { make in
                make.height.width.equalTo(20)
            }
            
            buttonStack.snp.makeConstraints { make in
                make.trailing.centerY.equalToSuperview()
            }
        } else {
            [ questionLabel, genderStack ]
                .forEach { contentView.addSubview($0) }
            
            genderStack.snp.makeConstraints { make in
                make.centerY.trailing.equalToSuperview()
            }
        }
        
        questionLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
        }
    }
}
