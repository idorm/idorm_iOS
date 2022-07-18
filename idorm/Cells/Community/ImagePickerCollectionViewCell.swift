//
//  ImagePickerCollectionViewCell.swift
//  idorm
//
//  Created by 김응철 on 2022/07/18.
//

import UIKit
import SnapKit

class ImagePickerCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "ImagePickerCollectionViewCell"
    
    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        
        return iv
    }()

    lazy var circle: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 11
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 3
        
        return view
    }()
    
    lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .mainColor
        label.textColor = .white
        label.font = .init(name: Font.medium.rawValue, size: 12)
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 11
        label.isHidden = true
        
        return label
    }()
    
    // MARK: - LifeCycle
    
    // MARK: - Selectors
    
    // MARK: - Helpers
    func configureUI(image: UIImage?) {
        imageView.image = image
        numberLabel.layer.cornerRadius = circle.frame.height / 2
        
        [ imageView, circle, numberLabel ]
            .forEach { contentView.addSubview($0) }
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        circle.snp.makeConstraints { make in
            make.trailing.top.equalToSuperview().inset(6)
            make.width.height.equalTo(22)
        }
        
        numberLabel.snp.makeConstraints { make in
            make.trailing.top.equalToSuperview().inset(6)
            make.width.height.equalTo(22)
        }
    }
}
