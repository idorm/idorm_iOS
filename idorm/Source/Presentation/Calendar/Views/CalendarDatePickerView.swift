//
//  CalendarDatePickerView.swift
//  idorm
//
//  Created by 김응철 on 8/4/23.
//

import UIKit

import SnapKit

protocol CalendarDatePickerViewDelegate: AnyObject {
  func pickerViewDidChangeRow(_ timeString: String)
}

/// `CalendarDateSelectionVC`에서 사용되는 `UIPickerView`
final class CalendarDatePickerView: UIView, BaseViewProtocol {
  
  enum PickerViewItem: Int, CaseIterable {
    case meridians
    case hours
    case minutes
    
    /// `Component`의 갯수를 의미합니다.
    var numbersOfComponents: Int {
      return PickerViewItem.allCases.count
    }
    
    /// 각 `Component`의 원소 갯수를 의미합니다.
    var numberOfRowsInComponent: Int {
      switch self {
      case .meridians: return 2
      case .hours: return 10_000
      case .minutes: return 10_000
      }
    }
  }
  
  // MARK: - UI Components
  
  /// 메인이 되는 `UIPickerView`
  private lazy var pickerView: UIPickerView = {
    let pickerView = UIPickerView()
    pickerView.dataSource = self
    pickerView.delegate = self
    return pickerView
  }()
  
  /// 시간과 분 사이에 있는 `:`이 적혀있는 `UILabel`
  private let colonLabel: UILabel = {
    let label = UILabel()
    label.textColor = .black
    label.font = .iDormFont(.regular, size: 20.0)
    label.text = ":"
    return label
  }()
  
  // MARK: - Properties
  
  /// `UIPickerViewDataSource`에서 사용할 열거형 배열
  private let components: [PickerViewItem] = [.meridians, .hours, .minutes]
  
  /// `오전`, `오후` 값 배열
  private let meridians: [String] = ["오전", "오후"]
  
  /// `1 ~ 12시` 배열
  private let hours: [Int] = Array(1...12)
  
  /// `시`행의 중간 값
  private lazy var hourRowsMiddle: Int = ((hourRows / hours.count) / 2) * hours.count
  
  /// `0 ~ 59분` 배열
  private let minutes: [Int] = Array(0...59)
  
  /// `분`행의 중간 값
  private lazy var minuteRowsMiddle: Int = ((minuteRows / minutes.count) / 2) * minutes.count
  
  /// `시`와 `분`의 행 갯수를 나타내는 값
  private let hourRows: Int = 10_000
  private let minuteRows: Int = 10_000
  
  /// 현재 선택된 `Meridian`
  private var selectedMeridian: Int = 0
  
  /// 현재 선택된 `hour`
  private var selectedHour: Int = 12
  
  /// 현재 선택된 `minute`
  private var selectedMinute: Int = 0
  
  weak var delegate: CalendarDatePickerViewDelegate?
  
  // MARK: - Life Cycle
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }
  
  // MARK: - Setup
  
  func setupStyles() {
    /// 초기 `UIPickerView` 설정
    self.pickerView.selectRow(
      self.hourRowsMiddle,
      inComponent: PickerViewItem.hours.rawValue,
      animated: false
    )
    self.pickerView.selectRow(
      self.minuteRowsMiddle,
      inComponent: PickerViewItem.minutes.rawValue,
      animated: false
    )
  }
  
  func setupLayouts() {
    [
      self.pickerView,
      self.colonLabel
    ].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.pickerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    self.colonLabel.snp.makeConstraints { make in
      make.centerY.equalTo(self.pickerView)
      make.trailing.equalToSuperview().inset((self.bounds.width / 4) - 8.0)
    }
  }
  
  // MARK: - Functions
  
  /// 주입되는 시간으로 `UIPickerView`의 선택되는 행을 변경합니다.
  ///
  /// - Parameters:
  ///  - time: 원하는 시간
  func updateSelectedRow(_ time: String) {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss"
    let calendar = Calendar.current
    guard let time = formatter.date(from: time) else { return }
    let components = calendar.dateComponents([.hour, .minute], from: time)
    guard
      var hour = components.hour,
      let minute = components.minute
    else { return }
    
    self.selectedMeridian = hour < 12 ? 0 : 1
    
    if hour == 0 {
      hour += 12
    }
    
    if hour >= 13 && hour <= 23 {
      hour -= 12
    }
    
    self.selectedHour = hour
    self.selectedMinute = minute
    let neededHourRowIndex = self.hourRowsMiddle + (hour - 1)
    let neededMinuteRowIndex = self.minuteRowsMiddle + minute
    
    DispatchQueue.main.async {
      self.pickerView.selectRow(
        self.selectedMeridian,
        inComponent: PickerViewItem.meridians.rawValue,
        animated: false
      )
      self.pickerView.selectRow(
        neededHourRowIndex,
        inComponent: PickerViewItem.hours.rawValue,
        animated: false
      )
      self.pickerView.selectRow(
        neededMinuteRowIndex,
        inComponent: PickerViewItem.minutes.rawValue,
        animated: false
      )
    }
  }
}

// MARK: - PickerView

extension CalendarDatePickerView: UIPickerViewDataSource, UIPickerViewDelegate {
  /// `Component`갯수
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return self.components.count
  }
  
  /// `Component`당 줄의 갯수
  func pickerView(
    _ pickerView: UIPickerView,
    numberOfRowsInComponent component: Int
  ) -> Int {
    return self.components[component].numberOfRowsInComponent
  }
  
  /// `Row`당 Custom `UIView` 생성
  func pickerView(
    _ pickerView: UIPickerView,
    viewForRow row: Int,
    forComponent component: Int,
    reusing view: UIView?
  ) -> UIView {
    pickerView.subviews[1].backgroundColor = .clear
    
    // Label
    let label = UILabel()
    label.textColor = .black
    label.font = .iDormFont(.regular, size: 20.0)
    switch self.components[component] {
    case .hours:
      label.textAlignment = .center
      label.text = String(format: "%02d", self.hours[row % hours.count])
    case .minutes:
      label.textAlignment = .center
      label.text = String(format: "%02d", self.minutes[row % minutes.count])
    case .meridians:
      label.textAlignment = .left
      label.text = self.meridians[row]
    }
    return label
  }
  
  /// `Component`당 `Width`값
  func pickerView(
    _ pickerView: UIPickerView,
    widthForComponent component: Int
  ) -> CGFloat {
    let meridiansWidth: CGFloat = self.bounds.width / 2
    switch self.components[component] {
    case .meridians:
      return meridiansWidth
    default:
      return meridiansWidth / 2
    }
  }
  
  /// `RowHeight` 한 줄의 높이
  func pickerView(
    _ pickerView: UIPickerView,
    rowHeightForComponent component: Int
  ) -> CGFloat {
    return 42.0
  }
  
  /// 특정날짜가 선택되었을 때 호출되는 메서드입니다.
  func pickerView(
    _ pickerView: UIPickerView,
    didSelectRow row: Int,
    inComponent component: Int
  ) {
    switch self.components[component] {
    case .hours:
      self.selectedHour = self.hours[row % self.hours.count]
    case .minutes:
      self.selectedMinute = self.minutes[row % self.minutes.count]
    case .meridians:
      self.selectedMeridian = row
    }
    
    var hour = self.selectedHour
    let minute = self.selectedMinute
    
    // 현재 저장된 시간들을 조합하여 새로운 시간을 방출합니다.
    switch self.selectedMeridian {
    case 0 where hour == 12:
      hour -= 12
    case 1 where hour >= 1 && hour <= 11:
      hour += 12
    default:
      break
    }
    
    // 시간을 String으로 변환
    var calendar = Calendar.current
    calendar.timeZone = .current
    guard
      let time = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: Date())
    else { return }
    let timeString = time.toString("HH:mm:ss")
    self.delegate?.pickerViewDidChangeRow(timeString)
  }
}
