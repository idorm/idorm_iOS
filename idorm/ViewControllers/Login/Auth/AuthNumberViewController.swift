//
//  AuthNumberViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/10.
//

import UIKit
import SnapKit

class AuthNumberViewController: UIViewController {
    // MARK: - Properties
    let type: LoginType
    var secondsLeft: Int = 300
    var timer = Timer()
    var popCompletion: (() -> Void)?
    
    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.text = "지금 이메일로 인증번호를 보내드렸어요!"
        label.textColor = .darkGray
        label.font = .init(name: Font.medium.rawValue, size: 12.0)
        
        return label
    }()
    
    lazy var requestAgainButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("인증번호 재요청", for: .normal)
        button.setTitleColor(UIColor.gray, for: .normal)
        button.titleLabel?.font = .init(name: Font.medium.rawValue, size: 12.0)
        button.addTarget(self, action: #selector(didTapRequestButton), for: .touchUpInside)
        
        return button
    }()
    
    lazy var confirmButton: UIButton = {
        let button = LoginUtilities.returnBottonConfirmButton(string: "인증 완료")
        button.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
        
        return button
    }()
    
    lazy var textField: UIView = {
        let tf = LoginUtilities.returnTextField(placeholder: "인증번호를 입력해주세요.")
        
        return tf
    }()
    
    lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.text = "05:00"
        label.textColor = .mainColor
        label.font = .init(name: Font.medium.rawValue, size: 14.0)
        
        return label
    }()
    
    // MARK: - LifeCycle
    init(type: LoginType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        startTimer()
        addNotification()
    }
    
    // MARK: - Selectors
    @objc private func didTapRequestButton() {
        secondsLeft = 300
        startTimer()
    }
    
    @objc private func didTapConfirmButton() {
        popCompletion?()
        navigationController?.popViewController(animated: false)
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
            let popupView = LoginPopupViewController(contents: "인증번호가 만료되었습니다.")
            popupView.modalPresentationStyle = .overFullScreen
            self.present(popupView, animated: false)
        }
    }
    
    // MARK: - Helpers
    private func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(sceneWillEnterForeground), name: NSNotification.Name("sceneWillEnterForeground"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sceneWillEnterBackground), name: NSNotification.Name("sceneWillEnterBackground"), object: nil)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(startTimer(_:)), userInfo: nil, repeats: true)
    }
    
    private func configureUI() {
        navigationItem.title = "인증번호 입력"
        view.backgroundColor = .white
        
        [ infoLabel, requestAgainButton, textField, confirmButton, timerLabel ]
            .forEach { view.addSubview($0) }
                
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
        }
        
        confirmButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-20)
        }
        
        timerLabel.snp.makeConstraints { make in
            make.trailing.equalTo(textField.snp.trailing).offset(-14)
            make.centerY.equalTo(textField)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
