//
//  CompleteSignUpViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/11.
//

import UIKit
import SnapKit

class CompleteSignUpViewController: UIViewController {
  // MARK: - Properties
  lazy var image: UIImageView = {
    let iv = UIImageView()
    iv.image = UIImage(named: "Lion")
    iv.contentMode = .scaleAspectFit
    
    return iv
  }()
  
  lazy var signUpLabel: UILabel = {
    let label = UILabel()
    label.textColor = .idorm_gray_400
    label.text = "안녕하세요! 가입을 축하드려요."
    label.textAlignment = .center
    label.font = .init(name: Font.bold.rawValue, size: 18.0)
    
    return label
  }()
  
  lazy var descriptionLabel1: UILabel = {
    let label = UILabel()
    label.font = .init(name: Font.medium.rawValue, size: 12.0)
    label.textColor = .idorm_gray_300
    label.textAlignment = .center
    label.text = "로그인 후 인천대학교 기숙사 룸메이트 매칭을 위한"
    
    return label
  }()
  
  lazy var descriptionLabel2: UILabel = {
    let label = UILabel()
    label.font = .init(name: Font.medium.rawValue, size: 12.0)
    label.textColor = .idorm_gray_300
    label.textAlignment = .center
    label.text = "기본정보를 알려주세요."
    
    return label
  }()
  
  lazy var continueButton: UIButton = {
    var config = UIButton.Configuration.filled()
    var container = AttributeContainer()
    container.font = UIFont.init(name: Font.medium.rawValue, size: 16)
    container.foregroundColor = UIColor.white
    config.attributedTitle = AttributedString("로그인 후 계속하기", attributes: container)
    config.baseBackgroundColor = .idorm_blue
    config.cornerStyle = .capsule
    config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 40, bottom: 10, trailing: 40)
    let button = UIButton(configuration: config)
    
    return button
  }()
  
  // MARK: - LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bind()
  }
  
  // MARK: - Bind
  func bind() {
    
  }
  
  // MARK: - Helpers
  private func configureUI() {
    view.backgroundColor = .white
    
    [ image, signUpLabel, descriptionLabel1, descriptionLabel2, continueButton ]
      .forEach { view.addSubview($0) }
    
    image.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    
    signUpLabel.snp.makeConstraints { make in
      make.top.equalTo(image.snp.bottom).offset(70)
      make.centerX.equalToSuperview()
    }
    
    descriptionLabel1.snp.makeConstraints { make in
      make.top.equalTo(signUpLabel.snp.bottom).offset(12)
      make.centerX.equalToSuperview()
    }
    
    descriptionLabel2.snp.makeConstraints { make in
      make.top.equalTo(descriptionLabel1.snp.bottom).offset(4)
      make.centerX.equalToSuperview()
    }
    
    continueButton.snp.makeConstraints { make in
      make.bottom.equalToSuperview().inset(50)
      make.centerX.equalToSuperview()
    }
  }
}
