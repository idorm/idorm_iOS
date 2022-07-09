//
//  HomeRoommateCollectionViewCell.swift
//  idorm
//
//  Created by 김응철 on 2022/07/09.
//

import UIKit
import SnapKit

class HomeRoommateCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "HomeRoommateCollectionViewCell"
    
    // MARK: - Helpers
    func configureUI() {
        layer.cornerRadius = 15
    }
}
