//
//  HomePopularCollectionViewCell.swift
//  idorm
//
//  Created by 김응철 on 2022/07/09.
//

import UIKit
import SnapKit

class HomePopularCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "HomePopularCollectionViewCell"
    
    // MARK: - Helpers
    func configureUI() {
        layer.cornerRadius = 15
    }
}

