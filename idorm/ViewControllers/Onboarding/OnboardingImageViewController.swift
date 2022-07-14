//
//  OnboardingImageViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/14.
//

import UIKit
import SnapKit

class OnboardingImageViewController: UIViewController {
    // MARK: - Properties
    lazy var backgroundImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "OnboardingBackGround")?.withRenderingMode(.alwaysOriginal)
        iv.contentMode = .scaleToFill
        
        return iv
    }()
    
    lazy var matchingImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "MatchingLabel")?.withRenderingMode(.alwaysOriginal)
        iv.contentMode = .scaleAspectFill
        
        return iv
    }()
    
    lazy var dormLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24.0, weight: .bold)
        label.text = "3 기숙사"
        label.textColor = .black
        
        return label
    }()
    
    lazy var periodLabel: UILabel = {
        let label = UILabel()
        label.text = "16 주"
        label.textColor = .white
        label.font = .systemFont(ofSize: 14.0, weight: .bold)
        
        return label
    }()
    
    lazy var buildingImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "Building")?.withRenderingMode(.alwaysOriginal)
        iv.contentMode = .scaleToFill
        
        return iv
    }()
    
    lazy var freeContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10.0
        
        return view
    }()
    
    lazy var freeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14.0, weight: .regular)
        label.numberOfLines = 0
        label.text = "룸메에게 보내는 한마디 룸메에게 보내는 한마디 룸메에게 보내는 한마디 룸메에게 보내는 한마디 룸메에게 보내는 한마디 룸메에게 보내는 한마디 룸메에게 보내는 한마디"
        
        return label
    }()
    
    lazy var confirmButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("확인", for: .normal)
        button.setTitleColor(UIColor.mainColor, for: .normal)
        button.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
        
        return button
    }()
    
    lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.init(rgb: 0xE3E1EC).cgColor
        
        return view
    }()
    
    lazy var humanImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "Human")
        
        return iv
    }()
    
    lazy var genderLabel: UILabel = {
        let label = UILabel()
        label.text = "성별,"
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 14.0, weight: .bold)
        
        return label
    }()
    
    lazy var ageLabel: UILabel = {
        let label = UILabel()
        label.text = "11세"
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 14.0, weight: .bold)
        
        return label
    }()
    
    lazy var mbtiLabel: UILabel = {
        let label = UILabel()
        label.text = "ISFJ"
        label.textColor = .gray
        label.font = .systemFont(ofSize: 14.0, weight: .bold)
        
        return label
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Selectors
    @objc private func didTapConfirmButton() {
        
    }
 
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "내 프로필 이미지"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: confirmButton)
        
        let nose = createTopComponent(query: "코골이", ox: false)
        let teeth = createTopComponent(query: "이갈이", ox: true)
        let smoke = createTopComponent(query: "흡연", ox: true)
        let food = createTopComponent(query: "실내 음식", ox: true)
        let earphone = createTopComponent(query: "이어폰 착용", ox: true)
        
        [ dormLabel, buildingImageView, periodLabel, nose, teeth, smoke, food, earphone ]
            .forEach { backgroundImage.addSubview($0) }
        
        dormLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(24)
        }
        
        buildingImageView.snp.makeConstraints { make in
            make.trailing.equalTo(periodLabel.snp.leading).offset(-4)
            make.centerY.equalTo(periodLabel)
        }

        periodLabel.snp.makeConstraints { make in
            make.centerY.equalTo(dormLabel)
            make.trailing.equalToSuperview().inset(24)
        }
        
        nose.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.top.equalTo(dormLabel.snp.bottom).offset(20)
        }
        
        teeth.snp.makeConstraints { make in
            make.leading.equalTo(nose.snp.trailing).offset(8)
            make.centerY.equalTo(nose)
        }
        
        smoke.snp.makeConstraints { make in
            make.leading.equalTo(teeth.snp.trailing).offset(8)
            make.centerY.equalTo(nose)
        }
        
        food.snp.makeConstraints { make in
            make.top.equalTo(nose.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(24)
        }
        
        earphone.snp.makeConstraints { make in
            make.leading.equalTo(food.snp.trailing).offset(8)
            make.centerY.equalTo(food)
        }
        
        let wakeup = createComponent(query: "기상시간", contents: "입력 입력 입력 입력 입력 입력 입력")
        let clean = createComponent(query: "정리정돈", contents: "입력 입력 입력 입력 입력 입력 입력")
        let shower = createComponent(query: "샤워시간", contents: "입력 입력 입력 입력 입력 입력 입력")
        let mbti = createComponent(query: "MBTI", contents: "입력 입력 입력 입력 입력 입력 입력")
        
        freeContainerView.addSubview(freeLabel)
        
        freeLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12.0)
        }
        
        [ wakeup, clean, shower, mbti, freeContainerView ]
            .forEach { backgroundImage.addSubview($0) }
        
        wakeup.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalTo(food.snp.bottom).offset(20)
        }
        
        clean.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalTo(wakeup.snp.bottom).offset(8.0)
        }
        
        shower.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalTo(clean.snp.bottom).offset(8)
        }
        
        mbti.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalTo(shower.snp.bottom).offset(8)
        }
        
        freeContainerView.snp.makeConstraints { make in
            make.top.equalTo(mbti.snp.bottom).offset(16.0)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        [ bottomView, backgroundImage, matchingImageView ]
            .forEach { view.addSubview($0) }
        
        backgroundImage.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24.0)
            make.centerY.equalTo(view.safeAreaLayoutGuide)
        }

        matchingImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).inset(8.0)
        }
        
        bottomView.snp.makeConstraints { make in
            make.top.equalTo(backgroundImage.snp.bottom).offset(-20)
            make.leading.equalTo(backgroundImage.snp.leading)
            make.trailing.equalTo(backgroundImage.snp.trailing)
            make.height.equalTo(65.0)
        }
        
        [ humanImageView, genderLabel, ageLabel, mbtiLabel ]
            .forEach { bottomView.addSubview($0) }
        
        humanImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(12.0)
        }
        
        genderLabel.snp.makeConstraints { make in
            make.leading.equalTo(humanImageView.snp.trailing).offset(12.0)
            make.bottom.equalToSuperview().inset(12)
        }
        
        ageLabel.snp.makeConstraints { make in
            make.leading.equalTo(genderLabel.snp.trailing).offset(4)
            make.bottom.equalToSuperview().inset(12)
        }
        
        mbtiLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(12)
        }
    }
    
    func createTopComponent(query: String, ox: Bool) -> UIButton {
        var config = UIButton.Configuration.tinted()
        config.title = query
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 14)
        config.baseBackgroundColor = .white
        config.imagePlacement = .trailing
        config.imagePadding = 4.0
        config.cornerStyle = .capsule
        
        let button = UIButton(configuration: config)
        button.setImage(ox ? UIImage(named: "Omark") : UIImage(named: "Xmark"), for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.tintColor = ox ? .mainColor : .red
        button.backgroundColor = .white
        button.layer.cornerRadius = 16.0
        
        let attributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0, weight: .medium),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        let attributedString = NSAttributedString(string: query, attributes: attributes)
        button.setAttributedTitle(attributedString, for: .normal)
        
        button.snp.makeConstraints { make in
            make.height.equalTo(32.0)
        }
        
        return button
    }
    
    func createComponent(query: String, contents: String) -> UIView {
        let queryLabel = UILabel()
        queryLabel.text = query
        queryLabel.font = .systemFont(ofSize: 12.0, weight: .bold)
        
        let contentsLabel = UILabel()
        contentsLabel.text = contents
        contentsLabel.font = .systemFont(ofSize: 12.0, weight: .bold)
        contentsLabel.textColor = .darkGray
        
        let background = UIView()
        background.backgroundColor = .white
        background.layer.cornerRadius = 13.0
        
        [ queryLabel, contentsLabel ]
            .forEach { background.addSubview($0) }
        
        background.snp.makeConstraints { make in
            make.height.equalTo(30)
        }
        
        queryLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16.0)
            make.centerY.equalToSuperview()
        }

        contentsLabel.snp.makeConstraints { make in
            make.leading.equalTo(queryLabel.snp.trailing).offset(8.0)
            make.bottom.top.equalToSuperview().inset(8)
        }
        
        return background
    }
}
