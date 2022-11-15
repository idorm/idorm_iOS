import UIKit

import SnapKit
import RxSwift
import RxCocoa
import Then

final class AuthNumberViewController: BaseViewController {
  // MARK: - Properties
  
  let infoLabel = UILabel().then {
    $0.text = "지금 이메일로 인증번호를 보내드렸어요!"
    $0.textColor = .darkGray
    $0.font = .init(name: MyFonts.medium.rawValue, size: 12.0)
  }
  
  let requestAgainButton = UIButton().then {
    var config = UIButton.Configuration.plain()
    var container = AttributeContainer()
    container.font = .init(name: MyFonts.medium.rawValue, size: 12)
    container.foregroundColor = UIColor.idorm_gray_300
    config.attributedTitle = AttributedString("인증번호 재요청", attributes: container)
    
    $0.configuration = config
  }
  
  let timerLabel = UILabel().then {
    $0.text = "05:00"
    $0.textColor = .idorm_blue
    $0.font = .init(name: MyFonts.medium.rawValue, size: 14.0)
  }
  
  let indicator = UIActivityIndicatorView()
  let confirmButton = RegisterBottomButton("인증 완료")
  let textField = RegisterTextField("인증번호를 입력해주세요.")

  private let viewModel = AuthNumberViewModel()
  private let mailTimer: MailTimerChecker
  
  var popCompletion: (() -> Void)?
  
  // MARK: - LifeCycle
  
  init(timer: MailTimerChecker) {
    self.mailTimer = timer
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    // MARK: - Input
    
    // 인증번호 재요청 버튼 이벤트
    requestAgainButton.rx.tap
      .throttle(.seconds(20), latest: false, scheduler: MainScheduler.instance)
      .bind(to: viewModel.input.requestAgainButtonTapped)
      .disposed(by: disposeBag)
    
    // 인증번호 입력 버튼 이벤트
    confirmButton.rx.tap
      .bind(to: viewModel.input.confirmButtonTapped)
      .disposed(by: disposeBag)
    
    // 텍스트필드 이벤트
    textField.rx.text
      .orEmpty
      .bind(to: viewModel.input.codeString)
      .disposed(by: disposeBag)
    
    rx.viewWillAppear
      .map { _ in }
      .bind(to: viewModel.input.viewWillAppear)
      .disposed(by: disposeBag)
    
    // MARK: - Output
    
    // 남은 인증 시간 텍스트 변화 감지
    mailTimer.leftTime
      .debug()
      .filter { $0 >= 0 }
      .bind(onNext: { [weak self] elapseTime in
        let minutes = elapseTime / 60
        let seconds = elapseTime % 60
        let minutesString = String(format: "%02d", minutes)
        let secondsString = String(format: "%02d", seconds)
        self?.timerLabel.text = "\(minutesString):\(secondsString)"
      })
      .disposed(by: disposeBag)
    
    // 남은 시간 경과 시 작업 수행
    mailTimer.isPassed
      .distinctUntilChanged()
      .bind(onNext: { [weak self] in
        if $0 {
          self?.textField.backgroundColor = .idorm_gray_200
          let popupView = PopupViewController(contents: "인증번호가 만료되었습니다.")
          popupView.modalPresentationStyle = .overFullScreen
          self?.present(popupView, animated: false)
        } else {
          self?.textField.backgroundColor = .white
        }
      })
      .disposed(by: disposeBag)
    
    // 인증번호 재 요청 버튼 클릭 시 타이머 재 설정 및 안내 문구 출력
    viewModel.output.resetTimer
      .bind(onNext: { [weak self] _ in
        self?.mailTimer.restart()
        let popupView = PopupViewController(contents: "인증번호가 재전송 되었습니다.")
        popupView.modalPresentationStyle = .overFullScreen
        self?.present(popupView, animated: false)
      })
      .disposed(by: disposeBag)
    
    // 인증 번호 검증 성공 시 페이지 종료
    viewModel.output.dismissVC
      .bind(onNext: { [weak self] in
        self?.popCompletion?()
        self?.dismiss(animated: true)
      })
      .disposed(by: disposeBag)
    
    // 오류 문구 출력
    viewModel.output.showPopupVC
      .bind(onNext: { [weak self] mention in
        let popupVC = PopupViewController(contents: mention)
        popupVC.modalPresentationStyle = .overFullScreen
        self?.present(popupVC, animated: false)
      })
      .disposed(by: disposeBag)
    
    // 애니메이션 효과 시작
    viewModel.output.startAnimation
      .bind(onNext: { [weak self] in
        self?.indicator.startAnimating()
        self?.view.isUserInteractionEnabled = false
      })
      .disposed(by: disposeBag)
    
    // 애니메이션 효과 종료
    viewModel.output.stopAnimation
      .bind(onNext: { [weak self] in
        self?.indicator.stopAnimating()
        self?.view.isUserInteractionEnabled = true
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    navigationItem.title = "인증번호 입력"
    view.backgroundColor = .white
  }
  
  override func setupLayouts() {
    super.setupLayouts()
      
    [infoLabel, requestAgainButton, textField, confirmButton, timerLabel, indicator]
      .forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    infoLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalTo(view.safeAreaLayoutGuide).offset(50)
    }
    
    requestAgainButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(24)
      make.centerY.equalTo(infoLabel)
    }
    
    textField.snp.makeConstraints { make in
      make.trailing.leading.equalToSuperview().inset(24)
      make.top.equalTo(infoLabel.snp.bottom).offset(14)
      make.height.equalTo(50)
    }
    
    confirmButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-20)
      make.height.equalTo(50)
    }
    
    timerLabel.snp.makeConstraints { make in
      make.trailing.equalTo(textField.snp.trailing).offset(-14)
      make.centerY.equalTo(textField)
    }
    
    indicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.height.equalTo(50)
    }
  }
  
  // MARK: - Helpers
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
}
