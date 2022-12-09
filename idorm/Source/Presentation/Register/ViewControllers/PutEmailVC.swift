import UIKit

import Then
import SnapKit
import RxSwift
import RxCocoa

final class PutEmailViewController: BaseViewController {
  
  // MARK: - Properties
  
  private lazy var infoLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .init(name: MyFonts.medium.rawValue, size: 14)
    switch vcType {
    case .findPW:
      $0.text = "가입시 사용한 인천대학교 이메일이 필요해요."
    case .signUp, .updatePW:
      $0.text = "이메일"
    }
  }
  
  private let needEmailLabel = UILabel().then {
    $0.text = "인천대학교 이메일 (@inu.ac.kr)이 필요해요."
    $0.textColor = .idorm_gray_400
    $0.font = .init(name: MyFonts.medium.rawValue, size: 12)
  }
  
  private let indicator = UIActivityIndicatorView().then {
    $0.color = .gray
  }
  
  private lazy var inuStack = UIStackView().then { stack in
    [inuMark, needEmailLabel]
      .forEach { stack.addArrangedSubview($0) }
    stack.axis = .horizontal
    stack.spacing = 4
    
    switch vcType {
    case .signUp, .updatePW:
      stack.isHidden = false
    case .findPW:
      stack.isHidden = true
    }
  }
  
  private let textField = idormTextField("이메일을 입력해주세요")
  private let confirmButton = idormButton("인증번호 받기")
  private let inuMark = UIImageView(image: #imageLiteral(resourceName: "INUMark"))
  
  private let viewModel: PutEmailViewModel
  private let vcType: RegisterVCTypes.PutEmailVCType

  // MARK: - LifeCycle
  
  init(_ vcType: RegisterVCTypes.PutEmailVCType) {
    self.vcType = vcType
    self.viewModel = PutEmailViewModel(vcType)
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    // MARK: - Input
    
    // 텍스트 변화 감지
    textField.rx.text
      .orEmpty
      .bind(to: viewModel.input.textFieldDidChange)
      .disposed(by: disposeBag)

    // 인증번호 받기 버튼 클릭
    confirmButton.rx.tap
      .bind(to: viewModel.input.confirmButtonDidTap)
      .disposed(by: disposeBag)
    
    // MARK: - Output
    
    // 에러 팝업 창 띄우기
    viewModel.output.presentPopupVC
      .bind(onNext: { [weak self] mention in
        let popupVC = BasicPopup(contents: mention)
        popupVC.modalPresentationStyle = .overFullScreen
        self?.present(popupVC, animated: false)
      })
      .disposed(by: disposeBag)
    
    // 인증번호 페이지로 이동
    viewModel.output.presentAuthVC
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        let authVC = AuthViewController()
        let navVC = UINavigationController(rootViewController: authVC)
        navVC.modalPresentationStyle = .fullScreen
        self.present(navVC, animated: true)
        
        authVC.pushCompletion = {
          let viewController: ConfirmPasswordViewController
          switch self.vcType {
          case .findPW:
            viewController = ConfirmPasswordViewController(.findPW)
          case .signUp:
            viewController = ConfirmPasswordViewController(.signUp)
          case .updatePW:
            viewController = ConfirmPasswordViewController(.updatePW)
          }
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.navigationController?.pushViewController(viewController, animated: true)
          }
        }
      })
      .disposed(by: disposeBag)
    
    // 로딩 애니메이션 제어
    viewModel.output.isLoading
      .bind(to: indicator.rx.isAnimating)
      .disposed(by: disposeBag)
    
    // 화면 인터렉션 제어
    viewModel.output.isLoading
      .map { !$0 }
      .bind(to: view.rx.isUserInteractionEnabled)
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
    
    switch vcType {
    case .signUp:
      navigationItem.title = "회원가입"
    case .findPW:
      navigationItem.title = "비밀번호 찾기"
    case .updatePW:
      navigationItem.title = "비밀번호 변경"
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
