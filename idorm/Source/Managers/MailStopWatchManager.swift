//
//  MailStopWatch.swift
//  idorm
//
//  Created by 김응철 on 2023/02/20.
//

import Foundation

import RxSwift
import RxCocoa
import Network

/// 인증 시간을 관리하는 싱글톤 객체입니다.
final class MailStopWatchManager {
  
  // MARK: - Properties
  
  /// 이 객체는 싱글톤입니다.
  static let shared = MailStopWatchManager()
  
  /// 구독 형식의 Timer
  private var timer: Disposable?
  
  /// 스톱워치의 시간, 기본적으로 5분입니다.
  private var duration: TimeInterval?
  
  /// 현재 시간의 `Date`
  private var startTime: Date?
  
  /// 백그라운드 화면에 나갈 때 기록되는 `Date`
  private var startTimeWhenEnterBackground: Date?
  
  /// 현재 스톱 워치가 작동하고 있는지에 대한 판별 값
  private var isRunning: Bool {
    return self.timer != nil
  }
  
  /// 외부에서 남은 시간에 대한 값을 참조할 수 있는 `Subject`
  var remainingTime = BehaviorSubject<String?>(value: nil)
  
  /// 외부에서 시간이 만료되었는지 확인할 수 있는 `Subject`
  var isFinished = BehaviorSubject<Bool>(value: false)
  
  // MARK: - Initializer
  
  private init() {}
  
  // MARK: - Functions
  
  /// 스톱 워치를 시작합니다.
  func start() {
    guard !self.isRunning else { return }
    self.startTime = Date()
    self.duration = TimeInterval(300)
    self.timer = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
      .subscribe(with: self) { owner, _ in
        owner.updateTime()
      }
  }
  
  /// 스톱 워치를 종료합니다.
  func stop() {
    self.timer?.dispose()
    self.startTime = nil
    self.duration = nil
    self.timer = nil
  }
  
  /// 스톱워치의 시간을 재설정합니다.
  func reset() {
    self.startTime = Date()
    self.start()
  }
  
  /// 백그라운드에서 포어그라운드에 진입할 때의 차이 시간을 계산합니다.
  func willEnterForeground() {
    guard let startTimeWhenEnterBackground else { return }
    let interval = Date().timeIntervalSince(startTimeWhenEnterBackground)
    self.startTime?.addTimeInterval(-interval)
  }
}

// MARK: - Privates

private extension MailStopWatchManager {
  func updateTime() {
    guard let startTime = self.startTime,
          let duration = self.duration
    else {
      self.stop()
      self.remainingTime.onNext(nil)
      return
    }
    
    let elapsedTime = Date().timeIntervalSince(startTime)
    let remainingTime = Int(max(duration - elapsedTime, 0))
    
    if remainingTime <= 0 {
      self.stop()
      self.remainingTime.onNext(nil)
      self.isFinished.onNext(true)
    } else {
      let minutes = remainingTime / 60
      let seconds = remainingTime % 60
      let minutesString = String(format: "%02d", minutes)
      let secondsString = String(format: "%02d", seconds)
      self.remainingTime.onNext("\(minutesString):\(secondsString)")
      self.isFinished.onNext(false)
    }
  }
}
