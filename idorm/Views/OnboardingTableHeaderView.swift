//
//  OnboardingTableHeaderView.swift
//  idorm
//
//  Created by 김응철 on 2022/07/08.
//

import UIKit
import SnapKit

class OnboardingTableHeaderView: UIView {
    // MARK: - Properties
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "룸메이트 매칭을 위한 기본정보를 알려주세요!"
        label.textColor = .gray
        label.font = .systemFont(ofSize: 14.0)
        
        return label
    }()
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func configureUI() {
        [ titleLabel ]
            .forEach { addSubview($0) }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}
