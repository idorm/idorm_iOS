//
//  DeviceHeight.swift
//  idorm
//
//  Created by 김응철 on 2022/08/06.
//

import UIKit
import DeviceKit

public enum DeviceGroup {
  case fourInches
  case fiveInches
  case fiveInches_Plus
  case xSeries
  
  public var rawValue: [Device] {
    switch self {
    case .fourInches:
      return [.iPhone5s, .iPhoneSE, .iPodTouch7, .simulator(.iPodTouch7)]
    case .fiveInches:
      return [.iPhone6, .iPhone6s, .iPhone7, .iPhone8, .simulator(.iPhone8)]
    case .fiveInches_Plus:
      return [.iPhone6Plus, .iPhone7Plus, .iPhone8Plus, .iPhone6Plus]
    case .xSeries:
      return Device.allDevicesWithSensorHousing
    }
  }
}

class DeviceManager {
  static let shared: DeviceManager = DeviceManager()
  
  private init() {}
  
  func isFourIncheDevices() -> Bool {
    return Device.current.isOneOf(DeviceGroup.fourInches.rawValue)
  }
  
  func isFiveIncheDevices() -> Bool {
    return Device.current.isOneOf(DeviceGroup.fiveInches.rawValue)
  }
  
  func isFiveInchePlusDevices() -> Bool {
    return Device.current.isOneOf(DeviceGroup.fiveInches_Plus.rawValue)
  }
  
  func isXSeriesDevices() -> Bool {
    return Device.current.isOneOf(DeviceGroup.xSeries.rawValue)
  }
}
