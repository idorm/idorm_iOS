import UIKit

import Then
import SnapKit
import RxSwift
import RxCocoa

final class PutEmailViewController: BaseViewController {
  
  // MARK: - Properties
  
  private lazy var infoLabel = UIFactory.label(
    text: "",
    color: .black,
    font: .init(name: MyFonts.medium.rawValue, size: 14)
  ).then {
    switch vcType {
    case .findPW:
      $0.text = "가입시 사용한 인천대학교 이메일이 필요해요."
    case .signUp, .updatePW:
      $0.text = "이메일"
    }
  }
  
  private let needEmailLabel = UIFactory.label(
    text: "인천대학교 이메일 (@inu.ac.kr)이 필요해요.",
    color: .idorm_gray_400,
    font: .init(name: MyFonts.medium.rawValue, size: 12)
  )
  
  private let indicator = UIActivityIndicatorView()
  private let textField = RegisterTextField("이메일을 입력해주세요")
  private let confirmButton = RegisterBottomButton("인증번호 받기")
  private let inuMark = UIImageView(image: #imageLiteral(resourceName: "INUMark"))
  private var inuStack: UIStackView!
  
  private let viewModel = PutEmailViewModel()
  private let vcType: PutEmailVCType

  // MARK: - LifeCycle
  
  init(_ vcType: PutEmailVCType) {
    self.vcType = vcType
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    // MARK: - Input
    
    // 인증번호 받기 버튼 클릭
    confirmButton.rx.tap
      .bind(to: viewModel.input.confirmButtonTapped)
      .disposed(by: disposeBag)
    
    // 텍스트필드 텍스트 반응
    textField.rx.text
      .orEmpty
      .bind(to: viewModel.input.emailText)
      .disposed(by: disposeBag)
    
    // Logger에 최초 한 번 현재 AuthenticationType 저장
    Observable.just(Void())
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        switch self.vcType {
        case .signUp:
          Logger.instance.authenticationType = .signUp
        case .findPW, .updatePW:
          Logger.instance.authenticationType = .password
        }
      })
      .disposed(by: disposeBag)
    
    // MARK: - Output
    
    // 에러 팝업 창 띄우기
    viewModel.output.showErrorPopupVC
      .bind(onNext: { [weak self] mention in
        let popupVC = PopupViewController(contents: mention)
        popupVC.modalPresentationStyle = .overFullScreen
        self?.present(popupVC, animated: false)
      })
      .disposed(by: disposeBag)
    
    // 인증번호 페이지로 이동
    viewModel.output.showAuthVC
      .asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] in
        guard let self = self else { return }
        let authVC = AuthViewController()
        let navVC = UINavigationController(rootViewController: authVC)
        navVC.modalPresentationStyle = .fullScreen
        self.present(navVC, animated: true)
        
        authVC.pushCompletion = {
          let authenticationType = Logger.instance.authenticationType
          let confirmPasswordVC = ConfirmPasswordViewController(authenticationType)
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.navigationController?.pushViewController(confirmPasswordVC, animated: true)
          }
        }
      })
      .disposed(by: disposeBag)
    
    // 애니메이션 상태 변경
    viewModel.output.animationState
      .bind(onNext: { [weak self] in
        if $0 {
          self?.indicator.startAnimating()
          self?.view.isUserInteractionEnabled = false
        } else {
          self?.indicator.stopAnimating()
          self?.view.isUserInteractionEnabled = true
        }
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: - Setup
  
  override func setupLayouts() {
    super.setupLayouts()
    [infoLabel, textField, confirmButton, inuStack, indicator]
      .forEach { view.addSubview($0) }
  }
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .white
    
    let inustack = UIStackView(arrangedSubviews: [ inuMark, needEmailLabel ])
    inustack.axis = .horizontal
    inustack.spacing = 4.0
    self.inuStack = inustack
    
    switch vcType {
    case .signUp:
      navigationItem.title = "회원가입"
      inuStack.isHidden = false
    case .findPW:
      navigationItem.title = "비밀번호 찾기"
      inuStack.isHidden = true
    case .updatePW:
      navigationItem.title = "비밀번호 변경"
      inustack.isHidden = false
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
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
    
    inuStack.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(textField.snp.bottom).offset(16)
    }
    
    indicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.height.equalTo(20)
    }
  }
  
  // MARK: - Helpers
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
}
