//
//  AuthNumberViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/10.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class AuthNumberViewController: BaseViewController {
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
  
  var secondsLeft: Int = 300
  var timer = Timer()
  var popCompletion: (() -> Void)?
  
  let indicator = UIActivityIndicatorView()
  let confirmButton = RegisterBottomButton("인증 완료")
  let textField = RegisterTextField("인증번호를 입력해주세요.")
  
  let viewModel = AuthNumberViewModel()
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    NotificationCenter.default.addObserver(self, selector: #selector(sceneWillEnterForeground), name: NSNotification.Name("sceneWillEnterForeground"), object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(sceneWillEnterBackground), name: NSNotification.Name("sceneWillEnterBackground"), object: nil)
    
    startTimer()
  }
  
  // MARK: - Bind
  override func bind() {
    super.bind()
    
    // --------------------------------
    // --------------INPUT-------------
    // --------------------------------
    
    /// 인증번호 재요청 버튼 이벤트
    requestAgainButton.rx.tap
      .throttle(.seconds(20), latest: false, scheduler: MainScheduler.instance)
      .bind(to: viewModel.input.requestAgainButtonTapped)
      .disposed(by: disposeBag)
    
    /// 인증번호 입력 버튼 이벤트
    confirmButton.rx.tap
      .bind(to: viewModel.input.confirmButtonTapped)
      .disposed(by: disposeBag)
    
    /// 텍스트필드 이벤트
    textField.rx.text
      .orEmpty
      .bind(to: viewModel.input.codeString)
      .disposed(by: disposeBag)
    
    rx.viewWillAppear
      .map { _ in }
      .bind(to: viewModel.input.viewWillAppear)
      .disposed(by: disposeBag)
    
    // --------------------------------
    // -------------OUTPUT-------------
    // --------------------------------
    
    /// 인증번호 재 요청 버튼 클릭 시 타이머 재 설정
    viewModel.output.resetTimer
      .bind(onNext: { [weak self] in
        self?.timer.invalidate()
        self?.secondsLeft = 300
        self?.startTimer()
      })
      .disposed(by: disposeBag)
    
    /// 인증 번호 검증 성공 시 페이지 종료
    viewModel.output.dismissVC
      .bind(onNext: { [weak self] in
        self?.popCompletion?()
        self?.dismiss(animated: true)
      })
      .disposed(by: disposeBag)
    
    /// 오류 문구 출력
    viewModel.output.showPopupVC
      .bind(onNext: { [weak self] mention in
        let popupVC = PopupViewController(contents: mention)
        popupVC.modalPresentationStyle = .overFullScreen
        self?.present(popupVC, animated: false)
      })
      .disposed(by: disposeBag)
    
    /// 애니메이션 효과 시작
    viewModel.output.startAnimation
      .bind(onNext: { [weak self] in
        self?.indicator.startAnimating()
        self?.view.isUserInteractionEnabled = false
      })
      .disposed(by: disposeBag)
    
    /// 애니메이션 효과 종료
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

// MARK: - Utilities

extension AuthNumberViewController {
  private func startTimer() {
    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(startTimer(_:)), userInfo: nil, repeats: true)
  }
  
  @objc private func sceneWillEnterForeground(_ noti: Notification) {
    if secondsLeft > 0 {
      let time = noti.userInfo?["time"] as? Int ?? 0
      secondsLeft = secondsLeft - time
    }
  }
  
  @objc private func sceneWillEnterBackground(_ noti: Notification) {
    timer.invalidate()
  }
  
  @objc private func startTimer(_ timer: Timer) {
    self.secondsLeft -= 1
    
    let minutes = self.secondsLeft / 60
    let seconds = self.secondsLeft % 60
    let minutesString = String(format: "%02d", minutes)
    let secondsString = String(format: "%02d", seconds)
    
    if self.secondsLeft > 0 {
      self.textField.backgroundColor = .white
      self.timerLabel.text = "\(minutesString):\(secondsString)"
    } else {
      timer.invalidate()
      self.textField.backgroundColor = .init(rgb: 0xE3E1EC)
      self.timerLabel.text = "00:00"
      let popupView = PopupViewController(contents: "인증번호가 만료되었습니다.")
      popupView.modalPresentationStyle = .overFullScreen
      self.present(popupView, animated: false)
    }
  }
}
