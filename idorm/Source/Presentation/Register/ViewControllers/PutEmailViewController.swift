//
//  FindPasswordViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/10.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa
import NVActivityIndicatorView

class PutEmailViewController: UIViewController {
  // MARK: - Properties
  lazy var infoLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .init(name: MyFonts.medium.rawValue, size: 14.0)
    if type == .findPW {
      $0.text = "가입시 사용한 인천대학교 이메일이 필요해요."
    } else {
      $0.text = "이메일"
    }
  }
  
  let needEmailLabel = UILabel().then {
    $0.text = "인천대학교 이메일 (@inu.ac.kr)이 필요해요."
    $0.textColor = .idorm_gray_400
    $0.font = .init(name: MyFonts.medium.rawValue, size: 12)
  }
  
  lazy var indicator = NVActivityIndicatorView(
    frame: CGRect(x: view.frame.width / 2, y: view.frame.height / 2, width: 20, height: 20),
    type: .lineSpinFadeLoader,
    color: UIColor.black,
    padding: 0
  )
  
  let textField = RegisterTextField("이메일을 입력해주세요")
  let confirmButton = RegisterBottomButton("인증번호 받기")
  let inuMark = UIImageView(image: UIImage(named: "INUMark"))
  
  let viewModel = PutEmailViewModel()
  let disposeBag = DisposeBag()
  
  let type: LoginType
  
  // MARK: - LifeCycle
  init(type: LoginType) {
    self.type = type
    super.init(nibName: nil, bundle: nil)
    LoginStates.currentLoginType = type
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
  }
  
  // MARK: - Bind
  func bind() {
    // --------------------------------
    // --------------INPUT-------------
    // --------------------------------
    confirmButton.rx.tap
      .bind(to: viewModel.input.confirmButtonTapped)
      .disposed(by: disposeBag)
    
    textField.rx.text
      .orEmpty
      .bind(to: viewModel.input.emailText)
      .disposed(by: disposeBag)
    
    // --------------------------------
    // -------------OUTPUT-------------
    // --------------------------------
    viewModel.output.showErrorPopupVC
      .asDriver(onErrorJustReturn: "")
      .drive(onNext: { [weak self] mention in
        let popupVC = PopupViewController(contents: mention)
        popupVC.modalPresentationStyle = .overFullScreen
        self?.present(popupVC, animated: false)
      })
      .disposed(by: disposeBag)
    
    viewModel.output.showAuthVC
      .asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] in
        guard let self = self else { return }
        let authVC = AuthViewController()
        let navVC = UINavigationController(rootViewController: authVC)
        navVC.modalPresentationStyle = .fullScreen
        self.present(navVC, animated: true)
        
        authVC.dismissCompletion = {
          let confirmPasswordVC = ConfirmPasswordViewController(type: self.type)
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.navigationController?.pushViewController(confirmPasswordVC, animated: true)
          }
        }
      })
      .disposed(by: disposeBag)
    
    // 인디케이터 애니메이션 적용
    viewModel.output.startAnimation
      .asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] in
        self?.confirmButton.isEnabled = false
        self?.indicator.startAnimating()
      })
      .disposed(by: disposeBag)
    
    viewModel.output.stopAnimation
      .asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] in
        self?.confirmButton.isEnabled = true
        self?.indicator.stopAnimating()
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: - Helpers
  private func configureUI() {
    view.backgroundColor = .white
    navigationController?.isNavigationBarHidden = false
    
    let inustack = UIStackView(arrangedSubviews: [ inuMark, needEmailLabel ])
    inustack.axis = .horizontal
    inustack.spacing = 4.0
    
    if type == .findPW {
      navigationItem.title = "비밀번호 찾기"
      inustack.isHidden = true
    } else {
      navigationItem.title = "회원가입"
      inustack.isHidden = false
    }
    
    [ infoLabel, textField, confirmButton, inustack, indicator ]
      .forEach { view.addSubview($0) }
    
    infoLabel.snp.makeConstraints { make in
      make.top.leading.equalTo(view.safeAreaLayoutGuide).inset(24)
    }
    
    textField.snp.makeConstraints { make in
      make.top.equalTo(infoLabel.snp.bottom).offset(8)
      make.leading.trailing.equalToSuperview().inset(24)
      make.height.equalTo(50)
    }
    
    confirmButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-20)
      make.height.equalTo(50)
    }
    
    inustack.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(textField.snp.bottom).offset(16)
    }
    
    indicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
}
