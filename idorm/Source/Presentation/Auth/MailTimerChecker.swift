//
//  MailTimerChecker.swift
//  idorm
//
//  Created by 김응철 on 2022/10/03.
//

import Foundation
import RxSwift
import RxCocoa

final class MailTimerChecker {
  
  enum Keys {
    case sceneWillEnterForeground
    case sceneWillEnterBackground
    
    var value: String {
      switch self {
      case .sceneWillEnterBackground:
        return "sceneWillEnterBackground"
      case .sceneWillEnterForeground:
        return "sceneWillEnterForeground"
      }
    }
  }
  
  // MARK: - Properties
  
  static let shared = MailTimerChecker()
  
  var timer = Timer()
  var secondsLeft: Int = 300
  
  let timerFinishedSubject = BehaviorRelay<Bool>(value: false)
  let timerStringSubject = BehaviorSubject<String>(value: "05:00")
  
  init() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(sceneWillEnterForeground),
      name: NSNotification.Name(MailTimerChecker.Keys.sceneWillEnterForeground.value), object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(sceneWillEnterBackground),
      name: NSNotification.Name(MailTimerChecker.Keys.sceneWillEnterBackground.value), object: nil
    )
  }
  
  // MARK: - Helpers
  
  func start() {
    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerChanged), userInfo: nil, repeats: true)
  }

  func reset() {
    timer.invalidate()
    secondsLeft = 300
    start()
  }
  
  func pause() {
    timer.invalidate()
  }
  
  // MARK: - Selectors
  
  @objc private func timerChanged() {
    secondsLeft -= 1
    
    let minutes = self.secondsLeft / 60
    let seconds = self.secondsLeft % 60
    let minutesString = String(format: "%02d", minutes)
    let secondsString = String(format: "%02d", seconds)
    
    if secondsLeft > 0 {
      timerFinishedSubject.accept(false)
      timerStringSubject.onNext("\(minutesString):\(secondsString)")
    } else {
      timer.invalidate()
      timerStringSubject.onNext("00:00")
      timerFinishedSubject.accept(true)
    }
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
}
