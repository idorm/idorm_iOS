//
//  HomeCollectionHeaderView.swift
//  idorm
//
//  Created by 김응철 on 2022/07/09.
//

import UIKit
import SnapKit

class HomeCollectionHeaderView: UICollectionReusableView {
    // MARK: - Properties
    static let identifier = "HomeCollectionHeaderView"
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 24.0, weight: .bold)
        
        return label
    }()
    
    // MARK: - Helpers
    func configureUI(title: String) {
        backgroundColor = .white
        titleLabel.text = title
        
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(24)
        }
    }
}
