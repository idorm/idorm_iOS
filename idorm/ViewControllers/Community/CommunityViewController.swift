//
//  CommunityViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/17.
//

import UIKit
import SnapKit

class CommunityViewController: UIViewController {
    // MARK: - Properties
    lazy var floatyButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "WriteButton"), for: .normal)
        btn.setImage(UIImage(named: "WriteButtonHover"), for: .highlighted)
        btn.addTarget(self, action: #selector(didTapFloatyButton), for: .touchUpInside)
        
        return btn
    }()
    
    lazy var changeDormButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.imagePadding = 16
        config.imagePlacement = .trailing
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        let button = UIButton(configuration: config)
        let attributedString = returnAttributedString(text: "인천대 3기숙사")
        button.setImage(UIImage(named: "bottomArrowButton"), for: .normal)
        button.setAttributedTitle(attributedString, for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        
        return button
    }()
    
    lazy var bellButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "bell"), for: .normal)
        
        return btn
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Selectors
    @objc private func didTapFloatyButton() {
        let writingVC = WritingViewController()
        navigationController?.pushViewController(writingVC, animated: true)
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: changeDormButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: bellButton)
        
        [ floatyButton ]
            .forEach { view.addSubview($0) }
        
        floatyButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
        }
    }
    
    private func returnAttributedString(text: String) -> NSAttributedString {
        let attributedString = NSAttributedString(
            string: text,
            attributes: [
                NSAttributedString.Key.font: UIFont.init(name: Font.bold.rawValue, size: 20) ?? 0,
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]
        )
        
        return attributedString
    }
}
