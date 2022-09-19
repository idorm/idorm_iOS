//
//  ManageMyInfoViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/08/28.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture
import SnapKit

class ManageMyInfoViewController: UIViewController {
  // MARK: - Properties
  lazy var scrollView: UIScrollView = {
    let sv = UIScrollView()
    sv.bounces = false
    
    return sv
  }()
  
  lazy var contentsView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    
    return view
  }()
  
  lazy var separatorLine1: UIView = {
    let line = UIView()
    line.backgroundColor = .idorm_gray_100
    
    return line
  }()
  
  lazy var separatorLine2: UIView = {
    let line = UIView()
    line.backgroundColor = .idorm_gray_100
    
    return line
  }()
  
  lazy var separatorLine3: UIView = {
    let line = UIView()
    line.backgroundColor = .idorm_gray_100
    
    return line
  }()
  
  lazy var profileImage = UIImageView(image: UIImage(named: "myProfileImage(MyPage)"))
  
  lazy var nickNameView = EachOfManageMyInfoView(type: .both(description: "닉네임닉네임"), title: "닉네임")
  lazy var changePasswordView = EachOfManageMyInfoView(type: .onlyArrow, title: "비밀번호 변경")
  lazy var setupAlarmView = EachOfManageMyInfoView(type: .onlyArrow, title: "알림 설정")
  lazy var emailView = EachOfManageMyInfoView(type: .onlyDescription(description: "asdf@inu.ac.kr"), title: "이메일")
  
  lazy var acceptTheTermView = EachOfManageMyInfoView(type: .onlyArrow, title: "서비스 약관 동의")
  lazy var versionView = EachOfManageMyInfoView(type: .onlyDescription(description: "1.0.0"), title: "버전정보")
  
  lazy var withDrawLabel: UILabel = {
    let label = UILabel()
    label.text = "회원 탈퇴"
    label.font = .init(name: MyFonts.regular.rawValue, size: 14)
    label.textColor = .idorm_gray_300
    
    return label
  }()
  
  let disposeBag = DisposeBag()
  let viewModel = ManageMyInfoViewModel()
  
  // MARK: - LifeCycle
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Bind
  func bind() {
    // --------------------------------
    // --------------INPUT-------------
    // --------------------------------
    rx.viewDidLoad
      .bind(to: viewModel.input.viewDidLoad)
      .disposed(by: disposeBag)
    
    rx.viewWillAppear
      .map { _ in Void() }
      .bind(to: viewModel.input.viewWillAppear)
      .disposed(by: disposeBag)
    
    profileImage.rx.tapGesture()
      .skip(1)
      .map { _ in Void() }
      .bind(to: viewModel.input.profileImageTapped)
      .disposed(by: disposeBag)
    
    // --------------------------------
    // -------------OUTPUT-------------
    // --------------------------------
    viewModel.output.configureUI
      .asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] in
        self?.configureUI()
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: - Helpers
  func configureUI() {
    self.navigationItem.title = "내 정보 관리"
    self.view.backgroundColor = .white
    
    view.addSubview(scrollView)
    view.addSubview(separatorLine1)
    scrollView.addSubview(contentsView)
    [ profileImage, nickNameView, changePasswordView, setupAlarmView, emailView, separatorLine2, acceptTheTermView, versionView, separatorLine3, withDrawLabel ]
      .forEach { contentsView.addSubview($0) }
    
    scrollView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    contentsView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalTo(view.frame.width)
    }
    
    separatorLine1.snp.makeConstraints { make in
      make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
      make.height.equalTo(3)
    }
    
    profileImage.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(24)
      make.centerX.equalToSuperview()
    }
    
    nickNameView.snp.makeConstraints { make in
      make.top.equalTo(profileImage.snp.bottom).offset(50)
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(30)
    }
    
    changePasswordView.snp.makeConstraints { make in
      make.top.equalTo(nickNameView.snp.bottom).offset(20)
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(30)
    }
    
    setupAlarmView.snp.makeConstraints { make in
      make.top.equalTo(changePasswordView.snp.bottom).offset(20)
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(30)
    }
    
    emailView.snp.makeConstraints { make in
      make.top.equalTo(setupAlarmView.snp.bottom).offset(20)
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(30)
    }
    
    separatorLine2.snp.makeConstraints { make in
      make.top.equalTo(emailView.snp.bottom).offset(24)
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(6)
    }
    
    acceptTheTermView.snp.makeConstraints { make in
      make.top.equalTo(separatorLine2.snp.bottom).offset(24)
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(30)
    }
    
    versionView.snp.makeConstraints { make in
      make.top.equalTo(acceptTheTermView.snp.bottom).offset(20)
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(30)
    }
    
    separatorLine3.snp.makeConstraints { make in
      make.top.equalTo(versionView.snp.bottom).offset(24)
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(6)
    }
    
    withDrawLabel.snp.makeConstraints { make in
      make.top.equalTo(separatorLine3.snp.bottom).offset(24)
      make.leading.equalToSuperview().inset(24)
      make.bottom.equalToSuperview().inset(24)
    }
  }
}
