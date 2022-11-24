import UIKit

import SnapKit
import Then
import WebKit
import RxSwift
import RxCocoa

final class AuthViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let envelopeImageView = UIImageView(image: #imageLiteral(resourceName: "envelope"))
  private let confirmButton = idormButton("인증번호 입력")
  
  private let backButton = UIButton().then {
    var config = UIButton.Configuration.plain()
    config.image = #imageLiteral(resourceName: "Xmark_Black")
    config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    $0.configuration = config
  }
  
  private let portalButton = idormButton("메일함 바로가기").then {
    $0.configuration?.baseForegroundColor = .idorm_gray_400
    $0.configuration?.baseBackgroundColor = .white
    $0.configuration?.background.strokeWidth = 1
    $0.configuration?.background.strokeColor = .idorm_gray_200
  }
  
  var pushCompletion: (() -> Void)?
  
  private let viewModel = AuthViewModel()
  private let mailTimer = MailTimerChecker()
    
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    // MARK: - Input
    
    // 뒤로가기 버튼 이벤트
    backButton.rx.tap
      .bind(to: viewModel.input.backButtonDidTap)
      .disposed(by: disposeBag)
    
    // 웹메일 바로 가기 버튼 이벤트
    portalButton.rx.tap
      .bind(to: viewModel.input.portalButtonDidTap)
      .disposed(by: disposeBag)
    
    // 인증번호 입력 버튼 이벤트
    confirmButton.rx.tap
      .bind(to: viewModel.input.confirmButtonDidTap)
      .disposed(by: disposeBag)
        
    // MARK: - Output
    
    // 화면 종료
    viewModel.output.dismissVC
      .asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] in
        self?.dismiss(animated: true)
      })
      .disposed(by: disposeBag)
    
    // 웹메일 페이지 보여주기
    viewModel.output.presentPortalWeb
      .bind(onNext: {
        guard let url = URL(string: "https://webmail.inu.ac.kr/member/login?host_domain=inu.ac.kr") else { return }
        UIApplication.shared.open(url)
      })
      .disposed(by: disposeBag)
    
    // 인증번호 입력 페이지로 넘어가기
    viewModel.output.pushToAuthNumberVC
      .asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [unowned self] in
        let authNumberVC = AuthNumberViewController(timer: self.mailTimer)
        self.navigationController?.pushViewController(authNumberVC, animated: true)
        
        authNumberVC.popCompletion = {
          self.pushCompletion?()
        }
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .white
    navigationController?.navigationBar.tintColor = .black
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [envelopeImageView, portalButton, confirmButton]
      .forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    envelopeImageView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().inset(150)
    }
    
    confirmButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.bottom.equalToSuperview().inset(85)
      make.height.equalTo(50)
    }
    
    portalButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.bottom.equalTo(confirmButton.snp.top).offset(-8)
      make.height.equalTo(50)
    }
  }
}
