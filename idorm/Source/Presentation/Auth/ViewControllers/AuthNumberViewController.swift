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
  var secondsLeft: Int = 300
  var timer = Timer()
  var popCompletion: (() -> Void)?
  
  lazy var confirmButton = RegisterBottomButton("인증 완료")
  lazy var textField = RegisterTextField("인증번호를 입력해주세요.")
  
  lazy var infoLabel = UILabel().then {
    $0.text = "지금 이메일로 인증번호를 보내드렸어요!"
    $0.textColor = .darkGray
    $0.font = .init(name: MyFonts.medium.rawValue, size: 12.0)
  }
  
  lazy var requestAgainButton = UIButton().then {
    var config = UIButton.Configuration.plain()
    var container = AttributeContainer()
    container.font = .init(name: MyFonts.medium.rawValue, size: 12)
    container.foregroundColor = UIColor.idorm_gray_300
    config.attributedTitle = AttributedString("인증번호 재요청", attributes: container)
    
    $0.configuration = config
  }
  
  lazy var timerLabel = UILabel().then {
    $0.text = "05:00"
    $0.textColor = .idorm_blue
    $0.font = .init(name: MyFonts.medium.rawValue, size: 14.0)
  }
  
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
    requestAgainButton.rx.tap
      .throttle(.seconds(20), latest: false, scheduler: MainScheduler.instance)
      .bind(to: viewModel.input.requestAgainButtonTapped)
      .disposed(by: disposeBag)
    
    confirmButton.rx.tap
      .throttle(.seconds(2), latest: false, scheduler: MainScheduler.instance)
      .bind(to: viewModel.input.confirmButtonTapped)
      .disposed(by: disposeBag)
    
    rx.viewWillAppear
      .map { _ in }
      .bind(to: viewModel.input.viewWillAppear)
      .disposed(by: disposeBag)
      
    textField.rx.text
      .orEmpty
      .bind(to: viewModel.input.codeString)
      .disposed(by: disposeBag)
    
    // --------------------------------
    // -------------OUTPUT-------------
    // --------------------------------
    viewModel.output.resetTimer
      .asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] in
        self?.timer.invalidate()
        self?.secondsLeft = 300
        self?.startTimer()
      })
      .disposed(by: disposeBag)
    
    viewModel.output.dismissVC
      .asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] in
        self?.popCompletion?()
        self?.dismiss(animated: true)
      })
      .disposed(by: disposeBag)
    
    viewModel.output.showPopupVC
      .asDriver(onErrorJustReturn: "")
      .drive(onNext: { [weak self] mention in
        let popupVC = PopupViewController(contents: mention)
        popupVC.modalPresentationStyle = .overFullScreen
        self?.present(popupVC, animated: false)
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
      
    [infoLabel, requestAgainButton, textField, confirmButton, timerLabel]
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
  }
  
  // MARK: - Helpers
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
}

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
